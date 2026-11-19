import '../config/app_config.dart';
import '../entities/activity.dart';
import '../entities/course.dart';
import 'export_result.dart';
import 'export_strategy.dart';

/// Exportador RFC 4180 a formato CSV en O(n).
class CsvExportStrategy extends ExportStrategy {
  const CsvExportStrategy();

  @override
  String get fileExtension => AppConfig.csvFormatKey;

  @override
  String get mimeType => 'text/csv';

  // {P} activities.isNotEmpty ∧ ∀ a ∈ activities: a.start.isBefore(a.end)
  // C   CsvExportStrategy.export(activities, coursesById)
  // {Q} validCsvCRLF(result.content) ∧ rowCount(result.content) == activities.length + 1
  @override
  ExportResult export(
    List<Activity> activities,
    Map<String, Course> coursesById,
  ) {
    if (activities.isEmpty) {
      throw ArgumentError('Se requiere al menos una actividad');
    }
    final b = StringBuffer()..write('"id","curso","titulo","inicio","fin","prioridad"');
    // Invariante de bucle: cada actividad agrega exactamente 1 fila CRLF escapada.
    for (final a in activities) {
      final courseName = coursesById[a.courseId]?.name ?? a.courseId;
      b
        ..write('\r\n')
        ..write(_quote(a.id))
        ..write(',')
        ..write(_quote(courseName))
        ..write(',')
        ..write(_quote(a.title))
        ..write(',')
        ..write(_quote(a.start.toIso8601String()))
        ..write(',')
        ..write(_quote(a.end.toIso8601String()))
        ..write(',')
        ..write(_quote(a.priority.toString()));
    }
    return ExportResult(
      content: b.toString(),
      fileName: AppConfig.csvDefaultFileName,
      mimeType: mimeType,
    );
  }

  String _quote(String cell) => '"${cell.replaceAll('"', '""')}"';
}
