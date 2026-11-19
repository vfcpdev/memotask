import '../entities/activity.dart';
import '../entities/course.dart';
import '../strategies/export_result.dart';
import '../strategies/export_strategy.dart';

/// Caso de uso: serializar la agenda a un formato de exportación vía Strategy.
class BuildExportFile {
  final ExportStrategy strategy;

  const BuildExportFile(this.strategy);

  // {P} activities.isNotEmpty ∧ ∀ a ∈ activities: a.start.isBefore(a.end)
  // C   buildExportFile(activities, coursesById)
  // {Q} result == strategy.export(activities, coursesById) ∧ result.content.isNotEmpty
  ExportResult call(
    List<Activity> activities,
    Map<String, Course> coursesById,
  ) {
    if (activities.isEmpty) {
      throw ArgumentError('Se requiere al menos una actividad (|E| >= 1)');
    }
    return strategy.export(activities, coursesById);
  }
}
