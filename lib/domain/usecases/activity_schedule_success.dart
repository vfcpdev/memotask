import '../entities/activity.dart';

/// Resultado inmutable de una operación de agendamiento exitosa.
class ActivityScheduleSuccess {
  final List<Activity> newSchedule;

  const ActivityScheduleSuccess({required this.newSchedule});
}
