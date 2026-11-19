import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'MemoTask · Agenda Estudiantil'**
  String get appTitle;

  /// No description provided for @tabTimeline.
  ///
  /// In es, this message translates to:
  /// **'Timeline'**
  String get tabTimeline;

  /// No description provided for @tabCalendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get tabCalendar;

  /// No description provided for @tabExport.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get tabExport;

  /// No description provided for @emptyTimelineMessage.
  ///
  /// In es, this message translates to:
  /// **'Sin actividades para mostrar.\nToca + para agendar.'**
  String get emptyTimelineMessage;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get filterToday;

  /// No description provided for @nextUrgentLabel.
  ///
  /// In es, this message translates to:
  /// **'Prioritaria: {title}'**
  String nextUrgentLabel(String title);

  /// No description provided for @conflictsBanner.
  ///
  /// In es, this message translates to:
  /// **'{count} conflictos detectados'**
  String conflictsBanner(int count);

  /// No description provided for @weekOfLabel.
  ///
  /// In es, this message translates to:
  /// **'Semana del {date}'**
  String weekOfLabel(String date);

  /// No description provided for @activitiesCountShort.
  ///
  /// In es, this message translates to:
  /// **'{count} act.'**
  String activitiesCountShort(int count);

  /// No description provided for @dayActivitiesSemantics.
  ///
  /// In es, this message translates to:
  /// **'{count} actividades el {day}'**
  String dayActivitiesSemantics(int count, String day);

  /// No description provided for @activityCardSemantics.
  ///
  /// In es, this message translates to:
  /// **'{title}, {course}, de {start} a {end}'**
  String activityCardSemantics(
    String title,
    String course,
    String start,
    String end,
  );

  /// No description provided for @exportTitle.
  ///
  /// In es, this message translates to:
  /// **'Exportar agenda'**
  String get exportTitle;

  /// No description provided for @exportCount.
  ///
  /// In es, this message translates to:
  /// **'{count} actividades'**
  String exportCount(int count);

  /// No description provided for @exportCountSemantics.
  ///
  /// In es, this message translates to:
  /// **'{count} actividades disponibles para exportar'**
  String exportCountSemantics(int count);

  /// No description provided for @exportIcsCta.
  ///
  /// In es, this message translates to:
  /// **'Exportar .ics'**
  String get exportIcsCta;

  /// No description provided for @exportCsvCta.
  ///
  /// In es, this message translates to:
  /// **'Exportar .csv'**
  String get exportCsvCta;

  /// No description provided for @exportedPathLabel.
  ///
  /// In es, this message translates to:
  /// **'Archivo: {path}'**
  String exportedPathLabel(String path);

  /// No description provided for @exportedSnackBar.
  ///
  /// In es, this message translates to:
  /// **'Exportado a: {path}'**
  String exportedSnackBar(String path);

  /// No description provided for @newActivityTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva actividad'**
  String get newActivityTitle;

  /// No description provided for @newActivityTooltip.
  ///
  /// In es, this message translates to:
  /// **'Agendar nueva actividad'**
  String get newActivityTooltip;

  /// No description provided for @deleteActivityTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar actividad'**
  String get deleteActivityTooltip;

  /// No description provided for @manageCourseTooltip.
  ///
  /// In es, this message translates to:
  /// **'Registrar curso'**
  String get manageCourseTooltip;

  /// No description provided for @newCourseTitle.
  ///
  /// In es, this message translates to:
  /// **'Curso'**
  String get newCourseTitle;

  /// No description provided for @courseIdLabel.
  ///
  /// In es, this message translates to:
  /// **'Código del curso'**
  String get courseIdLabel;

  /// No description provided for @courseNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del curso'**
  String get courseNameLabel;

  /// No description provided for @courseProfessorLabel.
  ///
  /// In es, this message translates to:
  /// **'Docente'**
  String get courseProfessorLabel;

  /// No description provided for @saveCourseCta.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get saveCourseCta;

  /// No description provided for @titleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get titleLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get descriptionLabel;

  /// No description provided for @requiredFieldError.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get requiredFieldError;

  /// No description provided for @startLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio: {dateTime}'**
  String startLabel(String dateTime);

  /// No description provided for @endLabel.
  ///
  /// In es, this message translates to:
  /// **'Fin: {dateTime}'**
  String endLabel(String dateTime);

  /// No description provided for @priorityLabel.
  ///
  /// In es, this message translates to:
  /// **'Prioridad'**
  String get priorityLabel;

  /// No description provided for @priorityHigh.
  ///
  /// In es, this message translates to:
  /// **'1 - Alta'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In es, this message translates to:
  /// **'2 - Media'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In es, this message translates to:
  /// **'3 - Baja'**
  String get priorityLow;

  /// No description provided for @reminderLabel.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio'**
  String get reminderLabel;

  /// No description provided for @scheduleCta.
  ///
  /// In es, this message translates to:
  /// **'Agendar'**
  String get scheduleCta;

  /// No description provided for @cancelCta.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelCta;

  /// No description provided for @invalidTimeRangeError.
  ///
  /// In es, this message translates to:
  /// **'El inicio debe ser anterior al fin'**
  String get invalidTimeRangeError;

  /// No description provided for @errorLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar la agenda'**
  String get errorLoadFailed;

  /// No description provided for @errorScheduleConflict.
  ///
  /// In es, this message translates to:
  /// **'Conflicto: \"{incoming}\" solapa con \"{existing}\"'**
  String errorScheduleConflict(String incoming, String existing);

  /// No description provided for @errorScheduleFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al agendar la actividad'**
  String get errorScheduleFailed;

  /// No description provided for @errorDeleteFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar la actividad'**
  String get errorDeleteFailed;

  /// No description provided for @errorCourseSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar el curso'**
  String get errorCourseSaveFailed;

  /// No description provided for @errorEmptyExport.
  ///
  /// In es, this message translates to:
  /// **'No hay actividades para exportar'**
  String get errorEmptyExport;

  /// No description provided for @errorExportFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar la agenda'**
  String get errorExportFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
