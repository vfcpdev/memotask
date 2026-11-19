import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memo_task/app.dart';
import 'package:memo_task/domain/config/app_config.dart';
import 'package:memo_task/domain/entities/activity.dart';
import 'package:memo_task/domain/entities/course.dart';
import 'package:memo_task/domain/repositories/export_gateway_interface.dart';
import 'package:memo_task/domain/repositories/schedule_repository_interface.dart';

class _TestScheduleRepository implements IScheduleRepository {
  final List<Activity> _activities = [];
  final Map<String, Course> _courses = {
    'FIS101': const Course(id: 'FIS101', name: 'Física', professor: 'Dr. León'),
  };

  _TestScheduleRepository({List<Activity> initial = const []}) {
    _activities.addAll(initial);
  }

  @override
  Future<void> deleteActivity(String id) async {
    _activities.removeWhere((a) => a.id == id);
  }

  @override
  Future<List<Activity>> getActivities() async =>
      List.unmodifiable(_activities);

  @override
  Future<List<Course>> getCourses() async =>
      List.unmodifiable(_courses.values.toList());

  @override
  Future<void> insertActivity(Activity activity) async {
    _activities.add(activity);
  }

  @override
  Future<void> upsertCourse(Course course) async {
    _courses[course.id] = course;
  }
}

class _TestExportGateway implements IExportGateway {
  final List<String> requestedFormats = [];

  @override
  Set<String> get availableFormats =>
      const {AppConfig.icsFormatKey, AppConfig.csvFormatKey};

  @override
  Future<String> exportToFile(
    String formatKey,
    List<Activity> activities,
    Map<String, Course> coursesById,
  ) async {
    requestedFormats.add(formatKey);
    return '/docs/agenda_memotask.$formatKey';
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('Renderiza estado vacío, agenda actividad desde modal y exporta',
      (tester) async {
    final repo = _TestScheduleRepository();
    final exportGw = _TestExportGateway();

    await tester.pumpWidget(
      App(
        repository: repo,
        exportGateway: exportGw,
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Sin actividades'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Parcial Álgebra');
    await tester.enterText(find.byType(TextFormField).at(1), 'FIS101');
    final scheduleBtn = find.text('Agendar');
    await tester.ensureVisible(scheduleBtn);
    await tester.tap(scheduleBtn);
    await tester.pumpAndSettle();

    expect(find.text('Parcial Álgebra'), findsOneWidget);

    await tester.tap(find.text('Exportar'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Exportar .ics'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Exportar .csv'), findsOneWidget);

    await tester.tap(find.text('Exportar .ics'));
    await tester.pumpAndSettle();

    expect(exportGw.requestedFormats, [AppConfig.icsFormatKey]);
    expect(
      find.textContaining('/docs/agenda_memotask.ics'),
      findsWidgets,
    );
  });

  testWidgets('Calendario semanal renderiza en español sin LocaleDataException',
      (tester) async {
    final now = DateTime.now();
    final activity = Activity.create(
      id: 'today-1',
      courseId: 'FIS101',
      title: 'Laboratorio',
      start: DateTime(now.year, now.month, now.day, 10),
      end: DateTime(now.year, now.month, now.day, 11),
      priority: 1,
    );
    final repo = _TestScheduleRepository(initial: [activity]);

    await tester.pumpWidget(
      App(
        repository: repo,
        exportGateway: _TestExportGateway(),
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Semana del'), findsOneWidget);
    expect(find.text('1 act.'), findsWidgets);
  });
}
