import '../../domain/entities/activity.dart';
import 'activity_draft.dart';

/// Adaptador de presentación hacia entidad de dominio validada por invariantes.
class ActivityCreateAdapter {
  const ActivityCreateAdapter._();

  static Activity toDomain(ActivityDraft draft, String id) {
    return Activity.create(
      id: id,
      courseId: draft.courseId,
      title: draft.title,
      description: draft.description,
      start: draft.start,
      end: draft.end,
      priority: draft.priority,
      reminderEnabled: draft.reminderEnabled,
    );
  }
}
