import 'package:drift/drift.dart' as drift;

import '../../domain/entities/activity.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/schedule_repository_interface.dart';
import '../datasources/app_database.dart';

/// Repositorio Drift que implementa el puerto DIP [IScheduleRepository].
class DriftScheduleRepository implements IScheduleRepository {
  final AppDatabase _db;

  DriftScheduleRepository(this._db);

  // {P} true
  // C   getCourses()
  // {Q} result contiene todos los cursos persistidos mapeados al dominio
  @override
  Future<List<Course>> getCourses() async {
    final rows = await _db.select(_db.courses).get();
    return rows
        .map((r) => Course(id: r.id, name: r.name, professor: r.professor))
        .toList(growable: false);
  }

  // {P} course.id.isNotEmpty ∧ course.name.isNotEmpty
  // C   upsertCourse(course)
  // {Q} persisted(course) en tabla Courses
  @override
  Future<void> upsertCourse(Course course) {
    return _db.into(_db.courses).insertOnConflictUpdate(
          CoursesCompanion.insert(
            id: course.id,
            name: course.name,
            professor: course.professor,
          ),
        );
  }

  // {P} true
  // C   getActivities()
  // {Q} ∀ a ∈ result: INV-ACT-1..3(a) ∧ isSortedByStart(result)
  @override
  Future<List<Activity>> getActivities() async {
    final query = _db.select(_db.activities)
      ..orderBy([(t) => drift.OrderingTerm.asc(t.start)]);
    final rows = await query.get();
    return rows.map(_toDomain).toList(growable: false);
  }

  // {P} INV-ACT-1..3(activity)
  // C   insertActivity(activity)
  // {Q} persisted(activity) ∧ curso padre garantizado para integridad referencial FK
  @override
  Future<void> insertActivity(Activity activity) {
    return _db.transaction(() async {
      await _db.into(_db.courses).insert(
            CoursesCompanion.insert(
              id: activity.courseId,
              name: activity.courseId,
              professor: '',
            ),
            mode: drift.InsertMode.insertOrIgnore,
          );
      await _db.into(_db.activities).insertOnConflictUpdate(
            ActivitiesCompanion.insert(
              id: activity.id,
              courseId: activity.courseId,
              title: activity.title,
              description: drift.Value(activity.description),
              start: activity.start,
              end: activity.end,
              priority: drift.Value(activity.priority),
              reminderEnabled: drift.Value(activity.reminderEnabled),
            ),
          );
    });
  }

  // {P} id.trim().isNotEmpty
  // C   deleteActivity(id)
  // {Q} ¬exists(id) en tabla Activities
  @override
  Future<void> deleteActivity(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('id no puede estar vacío');
    }
    return (_db.delete(_db.activities)..where((t) => t.id.equals(id))).go();
  }

  Activity _toDomain(ActivityRow row) {
    return Activity.create(
      id: row.id,
      courseId: row.courseId,
      title: row.title,
      description: row.description,
      start: row.start,
      end: row.end,
      priority: row.priority,
      reminderEnabled: row.reminderEnabled,
    );
  }
}
