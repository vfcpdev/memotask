import '../entities/activity.dart';
import '../entities/course.dart';

/// Puerto DIP para la escritura de archivos exportados de la agenda.
abstract interface class IExportGateway {
  Set<String> get availableFormats;

  // {P} formatKey ∈ availableFormats ∧ activities.isNotEmpty ∧ ∀ a ∈ activities: INV-ACT-1(a)
  // C   exportToFile(formatKey, activities, coursesById)
  // {Q} archivo válido escrito en disco ∧ result == ruta absoluta del archivo generado
  Future<String> exportToFile(
    String formatKey,
    List<Activity> activities,
    Map<String, Course> coursesById,
  );
}
