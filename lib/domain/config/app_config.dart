/// Constantes operativas centralizadas de la aplicación (Zero Hardcoding).
class AppConfig {
  const AppConfig._();

  static const String databaseFileName = 'memotask.sqlite';
  static const String defaultProfileId = 'primary';
  static const int maxUserNameLength = 60;

  static const int minPriority = 1;
  static const int maxPriority = 3;
  static const int defaultPriority = 3;

  static const Duration defaultInitialLead = Duration(hours: 1);
  static const Duration defaultActivityDuration = Duration(hours: 1);
  static const Duration defaultAlarmLead = Duration(minutes: 30);

  static const String icsFormatKey = 'ics';
  static const String csvFormatKey = 'csv';

  static const String icsProdId = '-//MemoTask//Agenda Estudiantil//ES';
  static const String icsUidDomain = 'memotask.app';
  static const String icsDefaultFileName = 'agenda_memotask.ics';
  static const String csvDefaultFileName = 'agenda_memotask.csv';

  static const int pickerMinYear = 2024;
  static const int pickerMaxYear = 2100;
  static const int calendarDaysInWeek = 7;

  static const String dateTimePattern = 'dd/MM/yyyy HH:mm';
  static const String timePattern = 'HH:mm';
  static const String weekHeaderPattern = 'dd/MM';
  static const String weekDayShortPattern = 'EEE dd';
  static const String weekDayFullPattern = 'EEEE dd';
}
