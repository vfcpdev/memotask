// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MemoTask · Agenda Estudiantil';

  @override
  String get tabTimeline => 'Timeline';

  @override
  String get tabCalendar => 'Calendario';

  @override
  String get tabExport => 'Exportar';

  @override
  String get emptyTimelineMessage =>
      'Sin actividades para mostrar.\nToca + para agendar.';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterToday => 'Hoy';

  @override
  String nextUrgentLabel(String title) {
    return 'Prioritaria: $title';
  }

  @override
  String conflictsBanner(int count) {
    return '$count conflictos detectados';
  }

  @override
  String weekOfLabel(String date) {
    return 'Semana del $date';
  }

  @override
  String activitiesCountShort(int count) {
    return '$count act.';
  }

  @override
  String dayActivitiesSemantics(int count, String day) {
    return '$count actividades el $day';
  }

  @override
  String activityCardSemantics(
    String title,
    String course,
    String start,
    String end,
  ) {
    return '$title, $course, de $start a $end';
  }

  @override
  String get exportTitle => 'Exportar agenda';

  @override
  String exportCount(int count) {
    return '$count actividades';
  }

  @override
  String exportCountSemantics(int count) {
    return '$count actividades disponibles para exportar';
  }

  @override
  String get exportIcsCta => 'Exportar .ics';

  @override
  String get exportCsvCta => 'Exportar .csv';

  @override
  String exportedPathLabel(String path) {
    return 'Archivo: $path';
  }

  @override
  String exportedSnackBar(String path) {
    return 'Exportado a: $path';
  }

  @override
  String get newActivityTitle => 'Nueva actividad';

  @override
  String get newActivityTooltip => 'Agendar nueva actividad';

  @override
  String get deleteActivityTooltip => 'Eliminar actividad';

  @override
  String get manageCourseTooltip => 'Registrar curso';

  @override
  String get newCourseTitle => 'Curso';

  @override
  String get courseIdLabel => 'Código del curso';

  @override
  String get courseNameLabel => 'Nombre del curso';

  @override
  String get courseProfessorLabel => 'Docente';

  @override
  String get saveCourseCta => 'Guardar';

  @override
  String get titleLabel => 'Título';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get requiredFieldError => 'Campo obligatorio';

  @override
  String startLabel(String dateTime) {
    return 'Inicio: $dateTime';
  }

  @override
  String endLabel(String dateTime) {
    return 'Fin: $dateTime';
  }

  @override
  String get priorityLabel => 'Prioridad';

  @override
  String get priorityHigh => '1 - Alta';

  @override
  String get priorityMedium => '2 - Media';

  @override
  String get priorityLow => '3 - Baja';

  @override
  String get reminderLabel => 'Recordatorio';

  @override
  String get scheduleCta => 'Agendar';

  @override
  String get cancelCta => 'Cancelar';

  @override
  String get invalidTimeRangeError => 'El inicio debe ser anterior al fin';

  @override
  String get errorLoadFailed => 'Error al cargar la agenda';

  @override
  String errorScheduleConflict(String incoming, String existing) {
    return 'Conflicto: \"$incoming\" solapa con \"$existing\"';
  }

  @override
  String get errorScheduleFailed => 'Error al agendar la actividad';

  @override
  String get errorDeleteFailed => 'Error al eliminar la actividad';

  @override
  String get errorCourseSaveFailed => 'Error al guardar el curso';

  @override
  String get errorEmptyExport => 'No hay actividades para exportar';

  @override
  String get errorExportFailed => 'Error al exportar la agenda';
}
