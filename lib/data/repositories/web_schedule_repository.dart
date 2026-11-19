import 'dart:convert';
import 'dart:js_interop';

import '../../domain/entities/activity.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/schedule_repository_interface.dart';

@JS('localStorage')
external _JsStorage? get _localStorage;

@JS()
extension type _JsStorage(JSObject _) implements JSObject {
  external String? getItem(String key);
  external void setItem(String key, String value);
}

/// Repositorio Web que implementa [IScheduleRepository] sobre `localStorage`.
class WebScheduleRepository implements IScheduleRepository {
  static const String _coursesKey = 'memotask_courses_v1';
  static const String _activitiesKey = 'memotask_activities_v1';

  final Map<String, Course> _memoryCourses = {};
  final Map<String, Activity> _memoryActivities = {};

  // {P} true
  // C   getCourses()
  // {Q} result contiene todos los cursos persistidos en localStorage/memoria
  @override
  Future<List<Course>> getCourses() async {
    final map = _readCoursesMap();
    return map.values.toList(growable: false);
  }

  // {P} course.id.trim().isNotEmpty ∧ course.name.trim().isNotEmpty
  // C   upsertCourse(course)
  // {Q} persisted(course) en localStorage/memoria
  @override
  Future<void> upsertCourse(Course course) async {
    final map = _readCoursesMap();
    map[course.id] = course;
    _writeCoursesMap(map);
  }

  // {P} true
  // C   getActivities()
  // {Q} ∀ a ∈ result: INV-ACT-1..3(a) ∧ isSortedByStart(result)
  @override
  Future<List<Activity>> getActivities() async {
    final list = _readActivitiesMap().values.toList(growable: false)
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  // {P} INV-ACT-1..3(activity)
  // C   insertActivity(activity)
  // {Q} persisted(activity) ∧ curso padre garantizado en almacenamiento
  @override
  Future<void> insertActivity(Activity activity) async {
    final courses = _readCoursesMap();
    courses.putIfAbsent(
      activity.courseId,
      () => Course(id: activity.courseId, name: activity.courseId),
    );
    _writeCoursesMap(courses);

    final activities = _readActivitiesMap();
    activities[activity.id] = activity;
    _writeActivitiesMap(activities);
  }

  // {P} id.trim().isNotEmpty
  // C   deleteActivity(id)
  // {Q} ¬exists(id) en almacenamiento local
  @override
  Future<void> deleteActivity(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('id no puede estar vacío');
    }
    final activities = _readActivitiesMap();
    activities.remove(id);
    _writeActivitiesMap(activities);
  }

  Map<String, Course> _readCoursesMap() {
    try {
      final raw = _localStorage?.getItem(_coursesKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final out = <String, Course>{};
        for (final item in decoded) {
          final m = item as Map<String, dynamic>;
          final c = Course(
            id: m['id'] as String,
            name: m['name'] as String,
            professor: (m['professor'] as String?) ?? '',
          );
          out[c.id] = c;
        }
        return out;
      }
    } catch (_) {
      // Respaldo seguro en memoria si localStorage no está disponible.
    }
    return Map<String, Course>.from(_memoryCourses);
  }

  void _writeCoursesMap(Map<String, Course> map) {
    _memoryCourses
      ..clear()
      ..addAll(map);
    try {
      final payload = jsonEncode([
        for (final c in map.values)
          {'id': c.id, 'name': c.name, 'professor': c.professor},
      ]);
      _localStorage?.setItem(_coursesKey, payload);
    } catch (_) {
      // Ya respaldado en memoria.
    }
  }

  Map<String, Activity> _readActivitiesMap() {
    try {
      final raw = _localStorage?.getItem(_activitiesKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final out = <String, Activity>{};
        for (final item in decoded) {
          final m = item as Map<String, dynamic>;
          final a = Activity.create(
            id: m['id'] as String,
            courseId: m['courseId'] as String,
            title: m['title'] as String,
            description: (m['description'] as String?) ?? '',
            start: DateTime.parse(m['start'] as String),
            end: DateTime.parse(m['end'] as String),
            priority: m['priority'] as int,
            reminderEnabled: (m['reminderEnabled'] as bool?) ?? true,
          );
          out[a.id] = a;
        }
        return out;
      }
    } catch (_) {
      // Respaldo seguro en memoria si localStorage no está disponible.
    }
    return Map<String, Activity>.from(_memoryActivities);
  }

  void _writeActivitiesMap(Map<String, Activity> map) {
    _memoryActivities
      ..clear()
      ..addAll(map);
    try {
      final payload = jsonEncode([
        for (final a in map.values)
          {
            'id': a.id,
            'courseId': a.courseId,
            'title': a.title,
            'description': a.description,
            'start': a.start.toIso8601String(),
            'end': a.end.toIso8601String(),
            'priority': a.priority,
            'reminderEnabled': a.reminderEnabled,
          },
      ]);
      _localStorage?.setItem(_activitiesKey, payload);
    } catch (_) {
      // Ya respaldado en memoria.
    }
  }
}
