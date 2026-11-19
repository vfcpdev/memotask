# Catálogo Canónico de Triplas de Hoare — MemoTask

## 1. Entidades (`lib/domain/entities/`)

### `Activity.create`
```dart
// {P} id.isNotEmpty ∧ courseId.isNotEmpty ∧ title.trim().isNotEmpty ∧ start.isBefore(end) ∧ priority >= 1 ∧ priority <= 3
// C   Activity.create(...)
// {Q} result.start < result.end ∧ 1 <= result.priority <= 3 ∧ (throws ArgumentError without side effects if ¬P)
```

### `Activity.overlaps`
```dart
// {P} this.start < this.end ∧ other.start < other.end
// C   overlaps(other)
// {Q} result == (this.start.isBefore(other.end) && other.start.isBefore(this.end))
```

### `Activity.copyWith`
```dart
// {P} (start ?? this.start).isBefore(end ?? this.end) ∧ 1 <= (priority ?? this.priority) <= 3
// C   copyWith(...)
// {Q} result.start < result.end ∧ 1 <= result.priority <= 3 ∧ this unchanged
```

## 2. Casos de Uso (`lib/domain/usecases/`)

### `ScheduleActivity.call`
```dart
// {P} a.start < a.end ∧ isSortedByStart(S) ∧ ∀ x ∈ S: (x.id != a.id => ¬x.overlaps(a))
// C   scheduleActivity(S, a)
// {Q} S' = (S \ {x ∈ S | x.id == a.id}) ∪ {a} ∧ isSortedByStart(S') ∧ disjoint(S') ∧ S unchanged
```

### `BuildExportFile.call`
```dart
// {P} activities.isNotEmpty ∧ ∀ a ∈ activities: a.start < a.end
// C   buildExportFile(activities, coursesById)
// {Q} result == strategy.export(activities, coursesById) ∧ result.content.isNotEmpty
```

## 3. Algoritmos y Estructuras (`lib/domain/algorithms/`)

### `ConflictDetector.detect`
```dart
// {P} ∀ a ∈ activities: a.start < a.end
// C   detect(activities)
// {Q} (∀ i < j in sorted(activities): sorted[i].overlaps(sorted[j]) ⟺ (sorted[i], sorted[j]) ∈ report.conflicts) ∧ report.overloadedMinutes == Σ overlapMinutes(pair)
```

### `PriorityMinHeap.add` / `popNext` / `drain`
```dart
// {P} a.start < a.end ∧ minHeapInvariant(_heap)
// C   add(a)
// {Q} length' == length + 1 ∧ minHeapInvariant(_heap')

// {P} isNotEmpty ∧ minHeapInvariant(_heap)
// C   popNext()
// {Q} result == min_{(priority, start)}(_heap) ∧ length' == length - 1 ∧ minHeapInvariant(_heap')

// {P} minHeapInvariant(_heap)
// C   drain()
// {Q} result.length == old(length) ∧ isSortedByPriorityThenStart(result) ∧ isEmpty
```

### `CourseIndex.add` / `forCourse`
```dart
// {P} a.courseId.isNotEmpty
// C   add(a)
// {Q} a ∈ _byCourse[a.courseId] in amortized O(1)

// {P} courseId.isNotEmpty
// C   forCourse(courseId)
// {Q} result == List.unmodifiable(_byCourse[courseId] ?? []) in O(1) lookup
```

## 4. Estrategias de Exportación (`lib/domain/strategies/`)

### `IcsExportStrategy.export`
```dart
// {P} activities.isNotEmpty ∧ ∀ a ∈ activities: a.start < a.end
// C   IcsExportStrategy.export(activities, coursesById)
// {Q} validRFC5545(result.content) ∧ count('BEGIN:VEVENT') == activities.length ∧ count('BEGIN:VALARM') == count(a ∈ activities | a.reminderEnabled)
```

### `CsvExportStrategy.export`
```dart
// {P} activities.isNotEmpty ∧ ∀ a ∈ activities: a.start < a.end
// C   CsvExportStrategy.export(activities, coursesById)
// {Q} validCsvCRLF(result.content) ∧ rowCount(result.content) == activities.length + 1
```

## 5. Repositorios y BLoC (`lib/data/repositories/`, `lib/presentation/bloc/`)

### `IScheduleRepository.insertActivity`
```dart
// {P} a.start < a.end ∧ 1 <= a.priority <= 3
// C   insertActivity(a)
// {Q} persisted(a) ∧ (getActivities() contains a)
```

### `AgendaBloc._onActivityCreated`
```dart
// {P} event.activity.start < event.activity.end ∧ isSortedByStart(state.activities)
// C   _onActivityCreated(event, emit)
// {Q} (¬overlap => persisted(event.activity) ∧ isSortedByStart(state'.activities)) ∧ (overlap => state'.activities == state.activities ∧ state'.errorCode != null)
```
