import '../entities/activity.dart';
import 'activity_schedule_success.dart';
import 'schedule_conflict_exception.dart';

export 'activity_schedule_success.dart';
export 'schedule_conflict_exception.dart';

/// Caso de uso: agendar una actividad en una agenda existente preservando orden.
class ScheduleActivity {
  const ScheduleActivity();

  // {P} a.start.isBefore(a.end) ∧ ∀ x ∈ schedule: (x.id == a.id ∨ ¬x.overlaps(a))
  // C   scheduleActivity(schedule, a)
  // {Q} newSchedule == ((schedule \ {x | x.id == a.id}) ∪ {a}) ∧ isSortedByStart(newSchedule) ∧ schedule intacto
  ActivityScheduleSuccess call(List<Activity> schedule, Activity a) {
    if (!a.start.isBefore(a.end)) {
      throw ArgumentError('La actividad debe cumplir start < end');
    }

    final filtered = <Activity>[];
    var alreadySorted = true;
    var insertIndex = 0;
    DateTime? prevStart;

    // Invariante de bucle: todos los elementos en `filtered` tienen id != a.id y ¬x.overlaps(a).
    for (final existing in schedule) {
      if (existing.id == a.id) continue;
      if (existing.overlaps(a)) {
        throw ScheduleConflictException(existing, a);
      }
      if (prevStart != null && existing.start.isBefore(prevStart)) {
        alreadySorted = false;
      }
      prevStart = existing.start;
      filtered.add(existing);
      if (!existing.start.isAfter(a.start)) {
        insertIndex = filtered.length;
      }
    }

    if (alreadySorted) {
      // Inserción en O(n) preservando isSortedByStart sin reordenar todo el arreglo.
      filtered.insert(insertIndex, a);
    } else {
      filtered.add(a);
      filtered.sort((x, y) => x.start.compareTo(y.start));
    }

    return ActivityScheduleSuccess(newSchedule: List.unmodifiable(filtered));
  }
}
