import '../entities/activity.dart';
import '../entities/course.dart';
import 'export_result.dart';

/// Patrón Strategy: abstrae el formato de exportación de la agenda.
/// Toda implementación debe ser determinista y pura respecto a sus entradas.
abstract class ExportStrategy {
  const ExportStrategy();

  // {P} activities.isNotEmpty ∧ ∀ a ∈ activities: a.start.isBefore(a.end)
  // C   export(activities, coursesById)
  // {Q} result ∈ ExportResult ∧ result.content.isNotEmpty ∧ count(recordUnits) == activities.length
  ExportResult export(
    List<Activity> activities,
    Map<String, Course> coursesById,
  );

  String get fileExtension;
  String get mimeType;
}
