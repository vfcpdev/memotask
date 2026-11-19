/// Borrador de actividad capturado por el formulario de UI.
class ActivityDraft {
  final String courseId;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final int priority;
  final bool reminderEnabled;

  const ActivityDraft({
    required this.courseId,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.priority,
    required this.reminderEnabled,
  });
}
