/// Min-heap genérico (binary heap). Inserción y extracción O(log n); peek O(1).
class HeapQueue<T> {
  final Comparator<T> _compare;
  final List<T> _heap = [];

  HeapQueue(this._compare);

  int get length => _heap.length;
  bool get isNotEmpty => _heap.isNotEmpty;
  bool get isEmpty => _heap.isEmpty;

  // {P} isNotEmpty ∧ minHeapInvariant(_heap)
  // C   peek
  // {Q} result == min(_heap) ∧ _heap inmutable en O(1)
  T get peek {
    if (_heap.isEmpty) {
      throw StateError('HeapQueue vacío');
    }
    return _heap.first;
  }

  List<T> toList() => List.unmodifiable(_heap);

  // {P} minHeapInvariant(_heap)
  // C   add(item)
  // {Q} length' == length + 1 ∧ minHeapInvariant(_heap') en O(log n)
  void add(T item) {
    _heap.add(item);
    _siftUp(_heap.length - 1);
  }

  // {P} isNotEmpty ∧ minHeapInvariant(_heap)
  // C   removeMin()
  // {Q} result == min(_heap) ∧ length' == length - 1 ∧ minHeapInvariant(_heap') en O(log n)
  T removeMin() {
    if (_heap.isEmpty) {
      throw StateError('HeapQueue vacío');
    }
    final min = _heap.first;
    final last = _heap.removeLast();
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _siftDown(0);
    }
    return min;
  }

  void _siftUp(int i) {
    // Invariante de bucle: todos los subárboles cumplen min-heap excepto posiblemente (parent(i), i).
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (_compare(_heap[i], _heap[parent]) < 0) {
        _swap(i, parent);
        i = parent;
      } else {
        break;
      }
    }
  }

  void _siftDown(int i) {
    final n = _heap.length;
    // Invariante de bucle: propiedad min-heap restaurada por encima de i.
    while (true) {
      final l = 2 * i + 1;
      final r = 2 * i + 2;
      var smallest = i;
      if (l < n && _compare(_heap[l], _heap[smallest]) < 0) smallest = l;
      if (r < n && _compare(_heap[r], _heap[smallest]) < 0) smallest = r;
      if (smallest == i) break;
      _swap(i, smallest);
      i = smallest;
    }
  }

  void _swap(int a, int b) {
    final t = _heap[a];
    _heap[a] = _heap[b];
    _heap[b] = t;
  }
}
