import 'package:equatable/equatable.dart';

import '../../domain/algorithms/conflict_report.dart';
import '../../domain/algorithms/day_schedule_index.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/user_profile.dart';
import 'agenda_failure.dart';

/// Estado inmutable de [AgendaBloc] con índices precalculados O(1).
class AgendaState extends Equatable {
  final List<Activity> activities;
  final Map<String, Course> courses;
  final Map<DateTime, List<Activity>> activitiesByDay;
  final DateTime? selectedDay;
  final Activity? nextUrgentActivity;
  final ConflictReport conflictReport;
  final UserProfile? userProfile;
  final bool loading;
  final AgendaFailure? failure;
  final String? exportedFilePath;

  const AgendaState({
    this.activities = const [],
    this.courses = const {},
    this.activitiesByDay = const {},
    this.selectedDay,
    this.nextUrgentActivity,
    this.conflictReport = const ConflictReport.empty(),
    this.userProfile,
    this.loading = false,
    this.failure,
    this.exportedFilePath,
  });

  // {P} activitiesByDay indexado por DayScheduleIndex.normalizeDay
  // C   visibleActivities
  // {Q} result == (selectedDay == null ? activities : activities del día en O(1))
  List<Activity> get visibleActivities {
    final day = selectedDay;
    if (day == null) return activities;
    return activitiesByDay[DayScheduleIndex.normalizeDay(day)] ??
        const <Activity>[];
  }

  AgendaState copyWith({
    List<Activity>? activities,
    Map<String, Course>? courses,
    Map<DateTime, List<Activity>>? activitiesByDay,
    DateTime? selectedDay,
    bool clearSelectedDay = false,
    Activity? nextUrgentActivity,
    bool clearNextUrgent = false,
    ConflictReport? conflictReport,
    UserProfile? userProfile,
    bool? loading,
    AgendaFailure? failure,
    bool clearFailure = false,
    String? exportedFilePath,
    bool clearExportedFilePath = false,
  }) {
    return AgendaState(
      activities: activities ?? this.activities,
      courses: courses ?? this.courses,
      activitiesByDay: activitiesByDay ?? this.activitiesByDay,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      nextUrgentActivity: clearNextUrgent
          ? null
          : (nextUrgentActivity ?? this.nextUrgentActivity),
      conflictReport: conflictReport ?? this.conflictReport,
      userProfile: userProfile ?? this.userProfile,
      loading: loading ?? this.loading,
      failure: clearFailure ? null : (failure ?? this.failure),
      exportedFilePath: clearExportedFilePath
          ? null
          : (exportedFilePath ?? this.exportedFilePath),
    );
  }

  @override
  List<Object?> get props => [
        activities,
        courses,
        activitiesByDay,
        selectedDay,
        nextUrgentActivity,
        conflictReport,
        userProfile,
        loading,
        failure,
        exportedFilePath,
      ];
}
