import 'package:equatable/equatable.dart';

/// Códigos tipados de fallo en la capa de estado (traducidos en UI vía l10n).
enum AgendaErrorCode {
  loadFailed,
  scheduleConflict,
  scheduleFailed,
  deleteFailed,
  courseSaveFailed,
  emptyExport,
  exportFailed,
  profileSaveFailed,
}

/// Falla estructurada e internacionalizable emitida por [AgendaBloc].
class AgendaFailure extends Equatable {
  final AgendaErrorCode code;
  final String? conflictExistingTitle;
  final String? conflictIncomingTitle;
  final String? detail;

  const AgendaFailure({
    required this.code,
    this.conflictExistingTitle,
    this.conflictIncomingTitle,
    this.detail,
  });

  @override
  List<Object?> get props => [
        code,
        conflictExistingTitle,
        conflictIncomingTitle,
        detail,
      ];
}
