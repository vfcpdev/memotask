import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memo_task/data/services/local_export_gateway.dart';
import 'package:memo_task/domain/config/app_config.dart';
import 'package:memo_task/domain/entities/activity.dart';
import 'package:memo_task/domain/entities/course.dart';

void main() {
  group('LocalExportGateway (Factory + Strategy + File I/O)', () {
    test('escribe archivo .ics y .csv en directorio configurado', () async {
      final tempDir = await Directory.systemTemp.createTemp('memotask_test_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final gateway = LocalExportGateway(
        directoryProvider: () async => tempDir,
      );
      final activity = Activity.create(
        id: 'exp-1',
        courseId: 'MAT101',
        title: 'Examen Final',
        start: DateTime(2026, 11, 20, 8),
        end: DateTime(2026, 11, 20, 10),
        priority: 1,
      );
      final courses = {
        'MAT101': const Course(id: 'MAT101', name: 'Cálculo'),
      };

      final icsPath = await gateway.exportToFile(
        AppConfig.icsFormatKey,
        [activity],
        courses,
      );
      expect(await File(icsPath).exists(), isTrue);
      final icsContent = await File(icsPath).readAsString();
      expect(icsContent, contains('BEGIN:VCALENDAR'));
      expect(icsContent, contains('SUMMARY:Examen Final · Cálculo'));

      final csvPath = await gateway.exportToFile(
        AppConfig.csvFormatKey,
        [activity],
        courses,
      );
      expect(await File(csvPath).exists(), isTrue);
      final csvContent = await File(csvPath).readAsString();
      expect(csvContent, contains('"Examen Final"'));
    });
  });
}
