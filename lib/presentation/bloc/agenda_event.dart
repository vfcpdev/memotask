import 'package:equatable/equatable.dart';

import '../../domain/entities/activity.dart';
import '../../domain/entities/course.dart';

/// Eventos sellados del ciclo de vida de la agenda estudiantil.
sealed class AgendaEvent extends Equatable {
  const AgendaEvent();

  @override
  List<Object?> get props => [];
}

class AgendaLoaded extends AgendaEvent {
  const AgendaLoaded();
}

class AgendaActivityCreated extends AgendaEvent {
  final Activity activity;

  const AgendaActivityCreated(this.activity);

  @override
  List<Object?> get props => [activity];
}

class AgendaActivityDeleted extends AgendaEvent {
  final String activityId;

  const AgendaActivityDeleted(this.activityId);

  @override
  List<Object?> get props => [activityId];
}

class AgendaCourseUpserted extends AgendaEvent {
  final Course course;

  const AgendaCourseUpserted(this.course);

  @override
  List<Object?> get props => [course];
}

class AgendaDaySelected extends AgendaEvent {
  final DateTime? day;

  const AgendaDaySelected(this.day);

  @override
  List<Object?> get props => [day];
}

class AgendaExportRequested extends AgendaEvent {
  final String format;

  const AgendaExportRequested(this.format);

  @override
  List<Object?> get props => [format];
}

class AgendaFeedbackCleared extends AgendaEvent {
  const AgendaFeedbackCleared();
}
