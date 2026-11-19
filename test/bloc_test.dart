import 'package:flutter_test/flutter_test.dart';
import 'package:memo_task/domain/config/app_config.dart';
import 'package:memo_task/domain/entities/activity.dart';
import 'package:memo_task/domain/entities/course.dart';
import 'package:memo_task/domain/repositories/export_gateway_interface.dart';
import 'package:memo_task/domain/repositories/schedule_repository_interface.dart';
import 'package:memo_task/presentation/bloc/agenda_bloc.dart';

class _FakeScheduleRepository implements IScheduleRepository {
  final List<Activity> activities = [];
  final Map<String, Course> courses = {};
  bool failOnDelete = false;

  @override
  Future<void> deleteActivity(String id) async {
    if (failOnDelete) throw StateError('db delete failed');
    activities.removeWhere((a) => a.id == id);
  }

  @override
  Future<List<Activity>> getActivities() async => List.unmodifiable(activities);

  @override
  Future<List<Course>> getCourses() async =>
      List.unmodifiable(courses.values.toList());

  @override
  Future<void> insertActivity(Activity activity) async {
    activities.removeWhere((a) => a.id == activity.id);
    activities.add(activity);
  }

  @override
  Future<void> upsertCourse(Course course) async {
    courses[course.id] = course;
  }
}

class _FakeExportGateway implements IExportGateway {
  String? lastFormat;

  @override
  Set<String> get availableFormats =>
      const {AppConfig.icsFormatKey, AppConfig.csvFormatKey};

  @override
  Future<String> exportToFile(
    String formatKey,
    List<Activity> activities,
    Map<String, Course> coursesById,
  ) async {
    lastFormat = formatKey;
    return '/tmp/agenda_memotask.$formatKey';
  }
}

Activity _act(
  String id,
  int hourStart,
  int hourEnd, {
  int day = 20,
  int priority = 3,
}) =>
    Activity.create(
      id: id,
      courseId: 'MAT101',
      title: 'Actividad $id',
      start: DateTime(2026, 11, day, hourStart),
      end: DateTime(2026, 11, day, hourEnd),
      priority: priority,
    );

void main() {
  group('AgendaBloc DIP + Hoare State Transitions', () {
    test('AgendaLoaded ordena actividades y construye índices O(1)', () async {
      final repo = _FakeScheduleRepository();
      repo.activities.addAll([
        _act('late', 14, 15, priority: 3),
        _act('early', 8, 9, priority: 1),
      ]);
      repo.courses['MAT101'] =
          const Course(id: 'MAT101', name: 'Cálculo', professor: 'Dr. Ruiz');

      final bloc = AgendaBloc(
        repository: repo,
        exportGateway: _FakeExportGateway(),
      );

      bloc.add(const AgendaLoaded());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.loading, isFalse);
      expect(bloc.state.activities.map((a) => a.id).toList(), ['early', 'late']);
      expect(bloc.state.nextUrgentActivity?.id, 'early');
      expect(bloc.state.activitiesByDay[DateTime(2026, 11, 20)]?.length, 2);

      await bloc.close();
    });

    test('AgendaActivityCreated rechaza solapamiento y preserva agenda previa',
        () async {
      final repo = _FakeScheduleRepository();
      repo.activities.add(_act('a', 8, 10));
      final bloc = AgendaBloc(
        repository: repo,
        exportGateway: _FakeExportGateway(),
      );
      bloc.add(const AgendaLoaded());
      await Future<void>.delayed(Duration.zero);

      bloc.add(AgendaActivityCreated(_act('b', 9, 11)));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.activities.length, 1);
      expect(bloc.state.failure?.code, AgendaErrorCode.scheduleConflict);
      expect(bloc.state.failure?.conflictExistingTitle, 'Actividad a');
      expect(bloc.state.failure?.conflictIncomingTitle, 'Actividad b');

      await bloc.close();
    });

    test('AgendaCourseUpserted, AgendaDaySelected y AgendaActivityDeleted',
        () async {
      final repo = _FakeScheduleRepository();
      repo.activities.addAll([
        _act('a', 8, 9, day: 20, priority: 2),
        _act('b', 10, 11, day: 21, priority: 1),
      ]);
      final bloc = AgendaBloc(
        repository: repo,
        exportGateway: _FakeExportGateway(),
      );
      bloc.add(const AgendaLoaded());
      await Future<void>.delayed(Duration.zero);

      bloc.add(
        AgendaCourseUpserted(
          Course.create(id: 'MAT101', name: 'Matemáticas', professor: 'Ana'),
        ),
      );
      bloc.add(AgendaDaySelected(DateTime(2026, 11, 20, 15, 30)));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.courses['MAT101']?.name, 'Matemáticas');
      expect(bloc.state.visibleActivities.map((e) => e.id).toList(), ['a']);

      bloc.add(const AgendaActivityDeleted('b'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.nextUrgentActivity?.id, 'a');

      repo.failOnDelete = true;
      bloc.add(const AgendaActivityDeleted('a'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.failure?.code, AgendaErrorCode.deleteFailed);

      await bloc.close();
    });

    test('AgendaExportRequested y limpieza explícita con AgendaFeedbackCleared',
        () async {
      final repo = _FakeScheduleRepository();
      final exportGw = _FakeExportGateway();
      final bloc = AgendaBloc(repository: repo, exportGateway: exportGw);

      bloc.add(const AgendaExportRequested(AppConfig.icsFormatKey));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.failure?.code, AgendaErrorCode.emptyExport);

      bloc.add(AgendaActivityCreated(_act('a', 8, 9)));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const AgendaExportRequested(AppConfig.icsFormatKey));
      await Future<void>.delayed(Duration.zero);

      expect(exportGw.lastFormat, AppConfig.icsFormatKey);
      expect(bloc.state.exportedFilePath, '/tmp/agenda_memotask.ics');

      bloc.add(const AgendaFeedbackCleared());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.exportedFilePath, isNull);
      expect(bloc.state.failure, isNull);

      await bloc.close();
    });
  });
}
