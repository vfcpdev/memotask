import 'package:equatable/equatable.dart';

import '../entities/activity.dart';

/// Resultado del análisis de conflictos por sweep-line.
class ConflictReport extends Equatable {
  final List<(Activity, Activity)> conflicts;
  final int overloadedMinutes;

  const ConflictReport({
    required this.conflicts,
    required this.overloadedMinutes,
  });

  const ConflictReport.empty()
      : conflicts = const [],
        overloadedMinutes = 0;

  @override
  List<Object?> get props => [conflicts, overloadedMinutes];
}
