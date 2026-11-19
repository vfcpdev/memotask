import '../config/app_config.dart';
import '../entities/activity.dart';
import '../entities/course.dart';
import 'export_result.dart';
import 'export_strategy.dart';

/// Exportador estándar .ics conforme a RFC 5545. Complejidad: O(n).
class IcsExportStrategy extends ExportStrategy {
  static const String _crlf = '\r\n';

  final Duration alarmLead;

  const IcsExportStrategy({this.alarmLead = AppConfig.defaultAlarmLead});

  @override
  String get fileExtension => AppConfig.icsFormatKey;

  @override
  String get mimeType => 'text/calendar';

  // {P} activities.isNotEmpty ∧ ∀ a ∈ activities: a.start.isBefore(a.end)
  // C   IcsExportStrategy.export(activities, coursesById)
  // {Q} validRFC5545(result.content) ∧ count('BEGIN:VEVENT') == activities.length ∧ count('BEGIN:VALARM') == count(a ∈ activities | a.reminderEnabled)
  @override
  ExportResult export(
    List<Activity> activities,
    Map<String, Course> coursesById,
  ) {
    if (activities.isEmpty) {
      throw ArgumentError('Se requiere al menos una actividad');
    }
    final b = StringBuffer()
      ..write('BEGIN:VCALENDAR$_crlf')
      ..write('VERSION:2.0$_crlf')
      ..write('PRODID:${AppConfig.icsProdId}$_crlf')
      ..write('CALSCALE:GREGORIAN$_crlf')
      ..write('METHOD:PUBLISH$_crlf');

    final trigger = '-PT${alarmLead.inMinutes}M';

    // Invariante de bucle: cada actividad procesada emite exactamente 1 VEVENT válido.
    for (final a in activities) {
      final summary = _title(a, coursesById);
      b
        ..write('BEGIN:VEVENT$_crlf')
        ..write('UID:${_escape(a.id)}@${AppConfig.icsUidDomain}$_crlf')
        ..write('DTSTAMP:${_fmt(a.start)}$_crlf')
        ..write('DTSTART:${_fmt(a.start)}$_crlf')
        ..write('DTEND:${_fmt(a.end)}$_crlf')
        ..write('SUMMARY:${_escape(summary)}$_crlf');
      if (a.description.isNotEmpty) {
        b.write('DESCRIPTION:${_escape(a.description)}$_crlf');
      }
      final course = coursesById[a.courseId];
      if (course != null) {
        b.write('CATEGORIES:${_escape(course.name)}$_crlf');
      }
      b.write('PRIORITY:${_rfcPriority(a.priority)}$_crlf');
      if (a.reminderEnabled) {
        b
          ..write('BEGIN:VALARM$_crlf')
          ..write('ACTION:DISPLAY$_crlf')
          ..write('DESCRIPTION:Recordatorio - ${_escape(summary)}$_crlf')
          ..write('TRIGGER:$trigger$_crlf')
          ..write('END:VALARM$_crlf');
      }
      b.write('END:VEVENT$_crlf');
    }

    b.write('END:VCALENDAR$_crlf');

    return ExportResult(
      content: b.toString(),
      fileName: AppConfig.icsDefaultFileName,
      mimeType: mimeType,
    );
  }

  String _title(Activity a, Map<String, Course> courses) {
    final course = courses[a.courseId];
    return course == null ? a.title : '${a.title} · ${course.name}';
  }

  int _rfcPriority(int p) {
    switch (p) {
      case 1:
        return 1;
      case 2:
        return 5;
      default:
        return 9;
    }
  }

  String _fmt(DateTime dt) {
    final u = dt.toUtc();
    final yy = u.year.toString().padLeft(4, '0');
    final mm = u.month.toString().padLeft(2, '0');
    final dd = u.day.toString().padLeft(2, '0');
    final hh = u.hour.toString().padLeft(2, '0');
    final mi = u.minute.toString().padLeft(2, '0');
    final ss = u.second.toString().padLeft(2, '0');
    return '$yy$mm${dd}T$hh$mi${ss}Z';
  }

  String _escape(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n');
  }
}
