import '../entities/activity.dart';
import '../entities/course.dart';

/// Puerto DIP de persistencia para cursos y actividades académicas.
abstract interface class IScheduleRepository {
  // {P} true
  // C   getCourses()
  // {Q} result contiene todos los cursos persistidos
  Future<List<Course>> getCourses();

  // {P} course.id.isNotEmpty ∧ course.name.isNotEmpty
  // C   upsertCourse(course)
  // {Q} persisted(course) en almacenamiento local
  Future<void> upsertCourse(Course course);

  // {P} true
  // C   getActivities()
  // {Q} ∀ a ∈ result: INV-ACT-1..3(a) ∧ isSortedByStart(result)
  Future<List<Activity>> getActivities();

  // {P} INV-ACT-1..3(activity)
  // C   insertActivity(activity)
  // {Q} persisted(activity) ∧ curso referenciado garantizado en almacenamiento
  Future<void> insertActivity(Activity activity);

  // {P} id.isNotEmpty
  // C   deleteActivity(id)
  // {Q} ¬exists(id) en almacenamiento local
  Future<void> deleteActivity(String id);
}
