import '../entities/activity.dart';
import 'conflict_report.dart';
import 'heap_queue.dart';

/// Detección de conflictos por sweep-line en O(n log n + k), k = pares solapados.
class ConflictDetector {
  const ConflictDetector();

  // {P} ∀ a ∈ activities: a.start.isBefore(a.end)
  // C   detect(activities)
  // {Q} (∀ i < j en sorted(activities): sorted[i].overlaps(sorted[j]) ⟺ (sorted[i], sorted[j]) ∈ report.conflicts) ∧ report.overloadedMinutes == Σ overlapMinutes(pair)
  ConflictReport detect(List<Activity> activities) {
    if (activities.isEmpty) {
      return const ConflictReport.empty();
    }
    final sorted = [...activities]..sort((a, b) => a.start.compareTo(b.start));

    final conflicts = <(Activity, Activity)>[];
    final openEvents = HeapQueue<Activity>((a, b) => a.end.compareTo(b.end));
    var overloaded = 0;

    // Invariante de bucle: `openEvents` contiene exactamente las actividades previas
    // cuyo `end` es estrictamente posterior a `current.start`.
    for (final current in sorted) {
      while (openEvents.isNotEmpty &&
          !openEvents.peek.end.isAfter(current.start)) {
        openEvents.removeMin();
      }
      for (final open in openEvents.toList()) {
        conflicts.add((open, current));
        final overlapEnd =
            open.end.isBefore(current.end) ? open.end : current.end;
        overloaded += overlapEnd.difference(current.start).inMinutes;
      }
      openEvents.add(current);
    }

    return ConflictReport(
      conflicts: List.unmodifiable(conflicts),
      overloadedMinutes: overloaded,
    );
  }
}
