import 'dart:collection';

import '../entities/activity.dart';

/// Índice O(1) de actividades por curso mediante HashMap.
class CourseIndex {
  final HashMap<String, List<Activity>> _byCourse =
      HashMap<String, List<Activity>>();

  // {P} a.courseId.isNotEmpty
  // C   add(a)
  // {Q} a ∈ _byCourse[a.courseId] en O(1) amortizado
  void add(Activity a) {
    if (a.courseId.trim().isEmpty) {
      throw ArgumentError('courseId no puede estar vacío');
    }
    _byCourse.putIfAbsent(a.courseId, () => []).add(a);
  }

  // {P} courseId.isNotEmpty
  // C   forCourse(courseId)
  // {Q} result == List.unmodifiable({a ∈ indexed | a.courseId == courseId}) con lookup O(1)
  List<Activity> forCourse(String courseId) =>
      List.unmodifiable(_byCourse[courseId] ?? const <Activity>[]);

  Set<String> get courseIds => _byCourse.keys.toSet();
}
