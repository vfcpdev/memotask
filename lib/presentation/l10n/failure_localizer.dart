import '../bloc/agenda_failure.dart';
import '../l10n/generated/app_localizations.dart';

/// Mapea fallas tipadas del BLoC hacia mensajes localizados en UI (Zero Hardcoding).
String localizeAgendaFailure(AppLocalizations l10n, AgendaFailure failure) {
  switch (failure.code) {
    case AgendaErrorCode.loadFailed:
      return l10n.errorLoadFailed;
    case AgendaErrorCode.scheduleConflict:
      return l10n.errorScheduleConflict(
        failure.conflictIncomingTitle ?? '',
        failure.conflictExistingTitle ?? '',
      );
    case AgendaErrorCode.scheduleFailed:
      return l10n.errorScheduleFailed;
    case AgendaErrorCode.deleteFailed:
      return l10n.errorDeleteFailed;
    case AgendaErrorCode.courseSaveFailed:
      return l10n.errorCourseSaveFailed;
    case AgendaErrorCode.emptyExport:
      return l10n.errorEmptyExport;
    case AgendaErrorCode.exportFailed:
      return l10n.errorExportFailed;
    case AgendaErrorCode.profileSaveFailed:
      return l10n.errorProfileSaveFailed;
  }
}
