// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MemoTask · Student Agenda';

  @override
  String get tabTimeline => 'Timeline';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabExport => 'Export';

  @override
  String get emptyTimelineMessage =>
      'No activities to display.\nTap + to schedule one.';

  @override
  String get filterAll => 'All';

  @override
  String get filterToday => 'Today';

  @override
  String nextUrgentLabel(String title) {
    return 'Priority: $title';
  }

  @override
  String conflictsBanner(int count) {
    return '$count conflicts detected';
  }

  @override
  String weekOfLabel(String date) {
    return 'Week of $date';
  }

  @override
  String activitiesCountShort(int count) {
    return '$count act.';
  }

  @override
  String dayActivitiesSemantics(int count, String day) {
    return '$count activities on $day';
  }

  @override
  String activityCardSemantics(
    String title,
    String course,
    String start,
    String end,
  ) {
    return '$title, $course, from $start to $end';
  }

  @override
  String get exportTitle => 'Export agenda';

  @override
  String exportCount(int count) {
    return '$count activities';
  }

  @override
  String exportCountSemantics(int count) {
    return '$count activities available to export';
  }

  @override
  String get exportIcsCta => 'Export .ics';

  @override
  String get exportCsvCta => 'Export .csv';

  @override
  String exportedPathLabel(String path) {
    return 'File: $path';
  }

  @override
  String exportedSnackBar(String path) {
    return 'Exported to: $path';
  }

  @override
  String get newActivityTitle => 'New activity';

  @override
  String get newActivityTooltip => 'Schedule new activity';

  @override
  String get deleteActivityTooltip => 'Delete activity';

  @override
  String get manageCourseTooltip => 'Add course';

  @override
  String get newCourseTitle => 'Course';

  @override
  String get courseIdLabel => 'Course code';

  @override
  String get courseNameLabel => 'Course name';

  @override
  String get courseProfessorLabel => 'Instructor';

  @override
  String get saveCourseCta => 'Save';

  @override
  String get titleLabel => 'Title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get requiredFieldError => 'Required field';

  @override
  String startLabel(String dateTime) {
    return 'Start: $dateTime';
  }

  @override
  String endLabel(String dateTime) {
    return 'End: $dateTime';
  }

  @override
  String get priorityLabel => 'Priority';

  @override
  String get priorityHigh => '1 - High';

  @override
  String get priorityMedium => '2 - Medium';

  @override
  String get priorityLow => '3 - Low';

  @override
  String get reminderLabel => 'Reminder';

  @override
  String get scheduleCta => 'Schedule';

  @override
  String get cancelCta => 'Cancel';

  @override
  String get invalidTimeRangeError => 'Start must be before end';

  @override
  String get errorLoadFailed => 'Failed to load agenda';

  @override
  String errorScheduleConflict(String incoming, String existing) {
    return 'Conflict: \"$incoming\" overlaps with \"$existing\"';
  }

  @override
  String get errorScheduleFailed => 'Failed to schedule activity';

  @override
  String get errorDeleteFailed => 'Failed to delete activity';

  @override
  String get errorCourseSaveFailed => 'Failed to save course';

  @override
  String get errorEmptyExport => 'No activities to export';

  @override
  String get errorExportFailed => 'Failed to export agenda';
}
