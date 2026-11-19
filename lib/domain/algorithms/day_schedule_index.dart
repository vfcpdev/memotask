import 'dart:collection';

import '../entities/activity.dart';

/// Índice O(1) por día calendario construido en una única pasada O(n).
class DayScheduleIndex {
  final Map<DateTime, List<Activity>> _byDay;

  DayScheduleIndex._(this._byDay);

  /// Normaliza una fecha al inicio de su día local (año, mes, día).
  static DateTime normalizeDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  // {P} ∀ a ∈ activities: a.start.isBefore(a.end)
  // C   DayScheduleIndex.fromActivities(activities)
  // {Q} ∀ day: index.forDay(day) == {a ∈ activities | normalizeDay(a.start) == normalizeDay(day)} en O(n)
  factory DayScheduleIndex.fromActivities(List<Activity> activities) {
    final map = HashMap<DateTime, List<Activity>>();
    // Invariante de bucle: cada actividad leída reside en la cubeta de su día normalizado.
    for (final a in activities) {
      final key = normalizeDay(a.start);
      map.putIfAbsent(key, () => []).add(a);
    }
    final frozen = <DateTime, List<Activity>>{
      for (final entry in map.entries)
        entry.key: List.unmodifiable(entry.value),
    };
    return DayScheduleIndex._(Map.unmodifiable(frozen));
  }

  // {P} true
  // C   forDay(day)
  // {Q} result == actividades del día normalizado en O(1)
  List<Activity> forDay(DateTime day) =>
      _byDay[normalizeDay(day)] ?? const <Activity>[];

  Map<DateTime, List<Activity>> toUnmodifiableMap() => _byDay;
}
