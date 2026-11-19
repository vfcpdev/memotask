import 'package:equatable/equatable.dart';

import '../config/app_config.dart';

/// Entidad central del dominio: una actividad académica agendada.
///
/// Invariantes estructurales:
/// - INV-ACT-1: [start] es estrictamente anterior a [end].
/// - INV-ACT-2: [priority] pertenece al rango [AppConfig.minPriority, AppConfig.maxPriority].
/// - INV-ACT-3: [id], [courseId] y [title] son no vacíos tras trim.
class Activity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final int priority;
  final bool reminderEnabled;

  const Activity._({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.priority,
    required this.reminderEnabled,
  });

  // {P} id.trim().isNotEmpty ∧ courseId.trim().isNotEmpty ∧ title.trim().isNotEmpty ∧ start.isBefore(end) ∧ AppConfig.minPriority <= priority <= AppConfig.maxPriority
  // C   Activity.create(id, courseId, title, description, start, end, priority, reminderEnabled)
  // {Q} result ∈ Activity ∧ INV-ACT-1..3(result) (throws ArgumentError sin efectos laterales si ¬P)
  factory Activity.create({
    required String id,
    required String courseId,
    required String title,
    String description = '',
    required DateTime start,
    required DateTime end,
    int priority = AppConfig.defaultPriority,
    bool reminderEnabled = true,
  }) {
    _validate(
      id: id,
      courseId: courseId,
      title: title,
      start: start,
      end: end,
      priority: priority,
    );
    return Activity._(
      id: id.trim(),
      courseId: courseId.trim(),
      title: title.trim(),
      description: description.trim(),
      start: start,
      end: end,
      priority: priority,
      reminderEnabled: reminderEnabled,
    );
  }

  // {P} INV-ACT-1(this) ∧ INV-ACT-1(other)
  // C   overlaps(other)
  // {Q} result ⟺ ([this.start, this.end) ∩ [other.start, other.end) ≠ ∅)
  bool overlaps(Activity other) {
    return start.isBefore(other.end) && other.start.isBefore(end);
  }

  // {P} INV-ACT-1..3 sobre los campos resultantes de aplicar las sustituciones opcionales
  // C   copyWith(...)
  // {Q} result ∈ Activity ∧ INV-ACT-1..3(result) ∧ this inmutable
  Activity copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    int? priority,
    bool? reminderEnabled,
  }) {
    final nextId = id ?? this.id;
    final nextCourseId = courseId ?? this.courseId;
    final nextTitle = title ?? this.title;
    final nextStart = start ?? this.start;
    final nextEnd = end ?? this.end;
    final nextPriority = priority ?? this.priority;

    _validate(
      id: nextId,
      courseId: nextCourseId,
      title: nextTitle,
      start: nextStart,
      end: nextEnd,
      priority: nextPriority,
    );

    return Activity._(
      id: nextId.trim(),
      courseId: nextCourseId.trim(),
      title: nextTitle.trim(),
      description: (description ?? this.description).trim(),
      start: nextStart,
      end: nextEnd,
      priority: nextPriority,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  static void _validate({
    required String id,
    required String courseId,
    required String title,
    required DateTime start,
    required DateTime end,
    required int priority,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError('id no puede estar vacío');
    }
    if (courseId.trim().isEmpty) {
      throw ArgumentError('courseId no puede estar vacío');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError('title no puede estar vacío');
    }
    if (!start.isBefore(end)) {
      throw ArgumentError('start debe ser estrictamente anterior a end');
    }
    if (priority < AppConfig.minPriority || priority > AppConfig.maxPriority) {
      throw ArgumentError(
        'priority debe estar entre ${AppConfig.minPriority} y ${AppConfig.maxPriority}',
      );
    }
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        start,
        end,
        priority,
        reminderEnabled,
      ];
}
