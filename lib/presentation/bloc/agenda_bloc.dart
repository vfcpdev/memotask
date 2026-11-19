import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/algorithms/schedule_algorithms.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/export_gateway_interface.dart';
import '../../domain/repositories/schedule_repository_interface.dart';
import '../../domain/repositories/user_profile_repository_interface.dart';
import '../../domain/usecases/register_user_name.dart';
import '../../domain/usecases/schedule_activity.dart';
import 'agenda_event.dart';
import 'agenda_failure.dart';
import 'agenda_state.dart';

export 'agenda_event.dart';
export 'agenda_failure.dart';
export 'agenda_state.dart';

/// BLoC de agenda estudiantil desacoplado de Data mediante puertos DIP.
class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final IScheduleRepository repository;
  final IUserProfileRepository userProfileRepository;
  final IExportGateway exportGateway;
  final ScheduleActivity scheduleActivity;
  final RegisterUserName registerUserName;
  final ConflictDetector conflictDetector;

  AgendaBloc({
    required this.repository,
    required this.userProfileRepository,
    required this.exportGateway,
    this.scheduleActivity = const ScheduleActivity(),
    this.registerUserName = const RegisterUserName(),
    this.conflictDetector = const ConflictDetector(),
  }) : super(const AgendaState()) {
    on<AgendaLoaded>(_onLoaded);
    on<AgendaActivityCreated>(_onActivityCreated);
    on<AgendaActivityDeleted>(_onActivityDeleted);
    on<AgendaCourseUpserted>(_onCourseUpserted);
    on<AgendaDaySelected>(_onDaySelected);
    on<AgendaExportRequested>(_onExportRequested);
    on<AgendaFeedbackCleared>(_onFeedbackCleared);
    on<AgendaUserNameRegistered>(_onUserNameRegistered);
  }

  // {P} true
  // C   _onLoaded(event, emit)
  // {Q} isSortedByStart(state'.activities) ∧ indices derivados consistentes ∧ ¬state'.loading
  Future<void> _onLoaded(AgendaLoaded event, Emitter<AgendaState> emit) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final loadedActivities = await repository.getActivities();
      final sorted = [...loadedActivities]
        ..sort((a, b) => a.start.compareTo(b.start));
      final courses = await repository.getCourses();
      final profile = await userProfileRepository.getProfile();
      final courseMap = {for (final c in courses) c.id: c};
      emit(
        _buildDerivedState(sorted, courseMap).copyWith(
          loading: false,
          userProfile: profile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          failure: AgendaFailure(
            code: AgendaErrorCode.loadFailed,
            detail: e.toString(),
          ),
        ),
      );
    }
  }

  // {P} INV-ACT-1..3(event.activity) ∧ isSortedByStart(state.activities)
  // C   _onActivityCreated(event, emit)
  // {Q} (¬overlap => persisted ∧ isSortedByStart(state'.activities)) ∧ (overlap => state.activities intacto ∧ failure.code == scheduleConflict)
  Future<void> _onActivityCreated(
    AgendaActivityCreated event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      final result = scheduleActivity(state.activities, event.activity);
      await repository.insertActivity(event.activity);
      emit(
        _buildDerivedState(
          result.newSchedule,
          state.courses,
        ).copyWith(clearFailure: true),
      );
    } on ScheduleConflictException catch (e) {
      emit(
        state.copyWith(
          failure: AgendaFailure(
            code: AgendaErrorCode.scheduleConflict,
            conflictExistingTitle: e.existing.title,
            conflictIncomingTitle: e.incoming.title,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          failure: AgendaFailure(
            code: AgendaErrorCode.scheduleFailed,
            detail: e.toString(),
          ),
        ),
      );
    }
  }

  // {P} event.activityId.trim().isNotEmpty
  // C   _onActivityDeleted(event, emit)
  // {Q} ¬exists(event.activityId) en repositorio y estado ∧ indices actualizados
  Future<void> _onActivityDeleted(
    AgendaActivityDeleted event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await repository.deleteActivity(event.activityId);
      final updated = state.activities
          .where((a) => a.id != event.activityId)
          .toList(growable: false);
      emit(
        _buildDerivedState(
          updated,
          state.courses,
        ).copyWith(clearFailure: true),
      );
    } catch (e) {
      emit(
        state.copyWith(
          failure: AgendaFailure(
            code: AgendaErrorCode.deleteFailed,
            detail: e.toString(),
          ),
        ),
      );
    }
  }

  // {P} event.course.id.isNotEmpty ∧ event.course.name.isNotEmpty
  // C   _onCourseUpserted(event, emit)
  // {Q} persisted(event.course) ∧ state'.courses[event.course.id] == event.course
  Future<void> _onCourseUpserted(
    AgendaCourseUpserted event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await repository.upsertCourse(event.course);
      final updatedCourses = Map<String, Course>.from(state.courses)
        ..[event.course.id] = event.course;
      emit(
        state.copyWith(
          courses: Map.unmodifiable(updatedCourses),
          clearFailure: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          failure: AgendaFailure(
            code: AgendaErrorCode.courseSaveFailed,
            detail: e.toString(),
          ),
        ),
      );
    }
  }

  // {P} true
  // C   _onDaySelected(event, emit)
  // {Q} state'.selectedDay == (event.day == null ? null : DayScheduleIndex.normalizeDay(event.day!))
  void _onDaySelected(AgendaDaySelected event, Emitter<AgendaState> emit) {
    final day = event.day;
    if (day == null) {
      emit(state.copyWith(clearSelectedDay: true));
    } else {
      emit(state.copyWith(selectedDay: DayScheduleIndex.normalizeDay(day)));
    }
  }

  // {P} event.format ∈ exportGateway.availableFormats
  // C   _onExportRequested(event, emit)
  // {Q} (state.activities.isEmpty => failure.code == emptyExport) ∧ (¬empty => exportedFilePath != null)
  Future<void> _onExportRequested(
    AgendaExportRequested event,
    Emitter<AgendaState> emit,
  ) async {
    if (state.activities.isEmpty) {
      emit(
        state.copyWith(
          failure: const AgendaFailure(code: AgendaErrorCode.emptyExport),
        ),
      );
      return;
    }
    try {
      final path = await exportGateway.exportToFile(
        event.format,
        state.activities,
        state.courses,
      );
      emit(state.copyWith(exportedFilePath: path, clearFailure: true));
    } catch (e) {
      emit(
        state.copyWith(
          failure: AgendaFailure(
            code: AgendaErrorCode.exportFailed,
            detail: e.toString(),
          ),
        ),
      );
    }
  }

  // {P} true
  // C   _onFeedbackCleared(event, emit)
  // {Q} state'.failure == null ∧ state'.exportedFilePath == null
  void _onFeedbackCleared(
    AgendaFeedbackCleared event,
    Emitter<AgendaState> emit,
  ) {
    emit(state.copyWith(clearFailure: true, clearExportedFilePath: true));
  }

  // {P} event.name.trim().isNotEmpty ∧ event.name.trim().length <= AppConfig.maxUserNameLength
  // C   _onUserNameRegistered(event, emit)
  // {Q} (¬P => failure.code == profileSaveFailed) ∧ (P => persisted(profile) ∧ state'.userProfile == profile)
  Future<void> _onUserNameRegistered(
    AgendaUserNameRegistered event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      final UserProfile profile = registerUserName(event.name);
      await userProfileRepository.saveProfile(profile);
      emit(state.copyWith(userProfile: profile, clearFailure: true));
    } catch (e) {
      emit(
        state.copyWith(
          failure: AgendaFailure(
            code: AgendaErrorCode.profileSaveFailed,
            detail: e.toString(),
          ),
        ),
      );
    }
  }

  AgendaState _buildDerivedState(
    List<Activity> activities,
    Map<String, Course> courses,
  ) {
    final frozenActivities = List<Activity>.unmodifiable(activities);
    final dayIndex = DayScheduleIndex.fromActivities(frozenActivities);
    final priorityHeap = PriorityMinHeap();
    for (final a in frozenActivities) {
      priorityHeap.add(a);
    }
    final nextUrgent = priorityHeap.isNotEmpty ? priorityHeap.peekNext : null;
    final conflicts = conflictDetector.detect(frozenActivities);

    return state.copyWith(
      activities: frozenActivities,
      courses: Map<String, Course>.unmodifiable(courses),
      activitiesByDay: dayIndex.toUnmodifiableMap(),
      nextUrgentActivity: nextUrgent,
      clearNextUrgent: nextUrgent == null,
      conflictReport: conflicts,
    );
  }
}
