import 'package:flutter_test/flutter_test.dart';
import 'package:memo_task/domain/algorithms/schedule_algorithms.dart';
import 'package:memo_task/domain/config/app_config.dart';
import 'package:memo_task/domain/entities/activity.dart';
import 'package:memo_task/domain/entities/course.dart';
import 'package:memo_task/domain/strategies/csv_export_strategy.dart';
import 'package:memo_task/domain/strategies/export_strategy_factory.dart';
import 'package:memo_task/domain/strategies/ics_export_strategy.dart';
import 'package:memo_task/domain/usecases/build_export_file.dart';
import 'package:memo_task/domain/usecases/schedule_activity.dart';

Activity mk(
  String id,
  DateTime start,
  DateTime end, {
  int priority = 3,
  String courseId = 'C1',
  bool reminderEnabled = true,
}) =>
    Activity.create(
      id: id,
      courseId: courseId,
      title: 'Act $id',
      start: start,
      end: end,
      priority: priority,
      reminderEnabled: reminderEnabled,
    );

DateTime dt(int d, int hh, int mm) => DateTime(2026, 11, d, hh, mm);

void main() {
  group('Hoare: Entidades e Invariantes', () {
    test('Activity.create valida start < end, priority 1..3 y campos no vacíos',
        () {
      expect(
        () => Activity.create(
          id: 'x',
          courseId: 'C1',
          title: 'Test',
          start: dt(1, 5, 0),
          end: dt(1, 5, 0),
        ),
        throwsArgumentError,
      );
      expect(
        () => Activity.create(
          id: 'x',
          courseId: 'C1',
          title: 'Test',
          start: dt(1, 5, 0),
          end: dt(1, 6, 0),
          priority: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => Activity.create(
          id: 'x',
          courseId: 'C1',
          title: 'Test',
          start: dt(1, 5, 0),
          end: dt(1, 6, 0),
          priority: 4,
        ),
        throwsArgumentError,
      );
      expect(
        () => Activity.create(
          id: ' ',
          courseId: 'C1',
          title: 'Test',
          start: dt(1, 5, 0),
          end: dt(1, 6, 0),
        ),
        throwsArgumentError,
      );
    });

    test('Activity.overlaps distingue intervalos contiguos de solapados', () {
      final a = mk('a', dt(20, 8, 0), dt(20, 10, 0));
      final contiguous = mk('b', dt(20, 10, 0), dt(20, 11, 0));
      final overlapping = mk('c', dt(20, 9, 30), dt(20, 11, 0));

      expect(a.overlaps(contiguous), isFalse);
      expect(a.overlaps(overlapping), isTrue);
    });

    test('Course.create normaliza id a mayúsculas y valida campos', () {
      final c = Course.create(id: ' mat101 ', name: ' Cálculo ');
      expect(c.id, 'MAT101');
      expect(c.name, 'Cálculo');
      expect(() => Course.create(id: ' ', name: 'X'), throwsArgumentError);
    });
  });

  group('Hoare: ScheduleActivity', () {
    test('Post: S\' = S ∪ {a} y ordenado por start en O(n)', () {
      final s = [
        mk('a', dt(20, 8, 0), dt(20, 9, 0)),
        mk('c', dt(20, 12, 0), dt(20, 13, 0)),
      ];
      const useCase = ScheduleActivity();
      final r = useCase(s, mk('b', dt(20, 10, 0), dt(20, 11, 0)));
      expect(r.newSchedule.map((e) => e.id).toList(), ['a', 'b', 'c']);
    });

    test('Pre fallida por solapamiento: ScheduleConflictException y S intacta',
        () {
      final s = [mk('a', dt(20, 8, 0), dt(20, 10, 0))];
      const useCase = ScheduleActivity();
      expect(
        () => useCase(s, mk('b', dt(20, 9, 0), dt(20, 11, 0))),
        throwsA(isA<ScheduleConflictException>()),
      );
      expect(s.length, 1);
    });

    test('Actualización de actividad existente por id reemplaza sin auto-conflicto',
        () {
      final s = [mk('a', dt(20, 8, 0), dt(20, 10, 0))];
      const useCase = ScheduleActivity();
      final r = useCase(s, mk('a', dt(20, 8, 30), dt(20, 9, 30)));
      expect(r.newSchedule.length, 1);
      expect(r.newSchedule.first.start, dt(20, 8, 30));
    });
  });

  group('Sweep-line O(n log n + k)', () {
    test('detecta el único solapamiento y calcula duración contenida exacta', () {
      final acts = [
        mk('a', dt(20, 8, 0), dt(20, 12, 0)),
        mk('b', dt(20, 9, 0), dt(20, 10, 0)), // contenida: 60 min, no 180
        mk('c', dt(20, 13, 0), dt(20, 14, 0)),
      ];
      final report = const ConflictDetector().detect(acts);
      expect(report.conflicts.length, 1);
      expect(report.overloadedMinutes, 60);
    });

    test('sin solapamientos ni lista vacía', () {
      expect(const ConflictDetector().detect(const []).conflicts, isEmpty);
      final acts = [
        mk('a', dt(20, 8, 0), dt(20, 9, 0)),
        mk('b', dt(20, 9, 0), dt(20, 10, 0)),
      ];
      final report = const ConflictDetector().detect(acts);
      expect(report.conflicts, isEmpty);
      expect(report.overloadedMinutes, 0);
    });
  });

  group('Estructuras O(log n) y O(1): PriorityMinHeap, CourseIndex, DayScheduleIndex',
      () {
    test('PriorityMinHeap ordena por prioridad y desempata por start', () {
      final heap = PriorityMinHeap();
      heap.add(mk('a', dt(20, 10, 0), dt(20, 11, 0), priority: 3));
      heap.add(mk('b', dt(20, 12, 0), dt(20, 13, 0), priority: 1));
      heap.add(mk('c', dt(20, 8, 0), dt(20, 9, 0), priority: 1));
      heap.add(mk('d', dt(20, 8, 0), dt(20, 9, 0), priority: 2));

      expect(heap.peekNext.id, 'c');
      expect(heap.drain().map((a) => a.id).toList(), ['c', 'b', 'd', 'a']);
      expect(() => heap.popNext(), throwsStateError);
    });

    test('CourseIndex consulta en O(1) por curso', () {
      final idx = CourseIndex();
      idx.add(mk('a', dt(20, 8, 0), dt(20, 9, 0), courseId: 'MAT101'));
      idx.add(mk('b', dt(20, 10, 0), dt(20, 11, 0), courseId: 'FIS101'));
      expect(idx.forCourse('MAT101').map((e) => e.id).toList(), ['a']);
      expect(idx.forCourse('NONE'), isEmpty);
    });

    test('DayScheduleIndex agrupa en O(n) y consulta en O(1) por día', () {
      final idx = DayScheduleIndex.fromActivities([
        mk('a', dt(20, 8, 0), dt(20, 9, 0)),
        mk('b', dt(20, 14, 0), dt(20, 15, 0)),
        mk('c', dt(21, 9, 0), dt(21, 10, 0)),
      ]);
      expect(idx.forDay(dt(20, 23, 59)).length, 2);
      expect(idx.forDay(dt(21, 0, 0)).length, 1);
      expect(idx.forDay(dt(22, 10, 0)), isEmpty);
    });
  });

  group('Hoare: ExportStrategyFactory, BuildExportFile, ICS y CSV', () {
    test('Factory resuelve estrategias registradas y rechaza desconocidas', () {
      const factory = ExportStrategyFactory();
      expect(
        factory.strategyFor(AppConfig.icsFormatKey),
        isA<IcsExportStrategy>(),
      );
      expect(
        factory.strategyFor(AppConfig.csvFormatKey),
        isA<CsvExportStrategy>(),
      );
      expect(() => factory.strategyFor('xml'), throwsArgumentError);
    });

    test('IcsExportStrategy cumple RFC 5545 y count(VEVENT) == |E|', () {
      final courses = {'C1': const Course(id: 'C1', name: 'Matemáticas')};
      final events = [
        mk('a', dt(20, 8, 0), dt(20, 9, 0)),
        mk('b', dt(20, 10, 0), dt(20, 11, 0), reminderEnabled: false),
      ];
      final useCase = BuildExportFile(const IcsExportStrategy());
      final result = useCase(events, courses);

      expect(result.mimeType, 'text/calendar');
      expect(result.fileName, AppConfig.icsDefaultFileName);
      expect(result.content, contains('BEGIN:VCALENDAR'));
      expect(result.content, contains('END:VCALENDAR'));
      expect('BEGIN:VEVENT'.allMatches(result.content).length, 2);
      expect('END:VEVENT'.allMatches(result.content).length, 2);
      expect('BEGIN:VALARM'.allMatches(result.content).length, 1);
      expect(result.content, contains('TRIGGER:-PT30M'));
      expect(result.content, contains('ACTION:DISPLAY'));
    });

    test('IcsExportStrategy escapa caracteres TEXT RFC 5545', () {
      final a = Activity.create(
        id: 'a',
        courseId: 'C1',
        title: 'Taller, parte; uno',
        description: 'línea1\nlínea2',
        start: dt(20, 8, 0),
        end: dt(20, 9, 0),
      );
      final useCase = BuildExportFile(const IcsExportStrategy());
      final r = useCase([a], const {});
      expect(r.content, contains(r'SUMMARY:Taller\, parte\; uno'));
      expect(r.content, contains(r'DESCRIPTION:línea1\nlínea2'));
    });

    test('Pre |E| >= 1: lista vacía lanza ArgumentError', () {
      final useCase = BuildExportFile(const IcsExportStrategy());
      expect(() => useCase(const [], const {}), throwsArgumentError);
    });

    test('CsvExportStrategy genera cabecera + n filas con CRLF y comillas', () {
      final a = Activity.create(
        id: 'a',
        courseId: 'C1',
        title: 'Ensayo "Final"',
        start: dt(20, 8, 0),
        end: dt(20, 9, 0),
      );
      final useCase = BuildExportFile(const CsvExportStrategy());
      final r = useCase([a], const {});
      expect(r.mimeType, 'text/csv');
      expect(r.content.split('\r\n').length, 2);
      expect(r.content, contains('"Ensayo ""Final"""'));
    });
  });
}
