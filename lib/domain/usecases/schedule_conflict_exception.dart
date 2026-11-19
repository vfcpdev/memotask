import '../entities/activity.dart';

/// Excepción de dominio lanzada cuando una actividad nueva solapa con una existente.
class ScheduleConflictException implements Exception {
  final Activity existing;
  final Activity incoming;

  const ScheduleConflictException(this.existing, this.incoming);

  @override
  String toString() =>
      'ScheduleConflictException(existing=${existing.id}, incoming=${incoming.id})';
}
