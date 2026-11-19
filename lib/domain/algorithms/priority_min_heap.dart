import '../entities/activity.dart';
import 'heap_queue.dart';

/// Min-Heap de prioridades: expone la actividad más urgente en O(1) (`peekNext`).
class PriorityMinHeap {
  final HeapQueue<Activity> _heap = HeapQueue<Activity>((a, b) {
    final byPriority = a.priority.compareTo(b.priority);
    if (byPriority != 0) return byPriority;
    return a.start.compareTo(b.start);
  });

  bool get isNotEmpty => _heap.isNotEmpty;
  int get length => _heap.length;

  // {P} isNotEmpty ∧ minHeapInvariant(_heap)
  // C   peekNext
  // {Q} result == min_{(priority, start)}(_heap) ∧ _heap intacto en O(1)
  Activity get peekNext => _heap.peek;

  // {P} a.start.isBefore(a.end) ∧ minHeapInvariant(_heap)
  // C   add(a)
  // {Q} length' == length + 1 ∧ minHeapInvariant(_heap') en O(log n)
  void add(Activity a) => _heap.add(a);

  // {P} isNotEmpty ∧ minHeapInvariant(_heap)
  // C   popNext()
  // {Q} result == min_{(priority, start)}(_heap) ∧ length' == length - 1 ∧ minHeapInvariant(_heap')
  Activity popNext() => _heap.removeMin();

  // {P} minHeapInvariant(_heap)
  // C   drain()
  // {Q} result.length == old(length) ∧ sortedByPriorityThenStart(result) ∧ length' == 0
  List<Activity> drain() {
    final out = <Activity>[];
    // Invariante de bucle: `out` está ordenado por (priority, start) y es ≤ que todo elemento en `_heap`.
    while (_heap.isNotEmpty) {
      out.add(_heap.removeMin());
    }
    return out;
  }
}
