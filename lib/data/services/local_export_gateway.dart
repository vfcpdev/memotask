import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/activity.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/export_gateway_interface.dart';
import '../../domain/strategies/export_strategy_factory.dart';
import '../../domain/usecases/build_export_file.dart';

/// Adaptador local que implementa [IExportGateway] mediante Factory + Strategy.
class LocalExportGateway implements IExportGateway {
  final ExportStrategyFactory factory;
  final Future<Directory> Function() _directoryProvider;

  LocalExportGateway({
    this.factory = const ExportStrategyFactory(),
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider =
            directoryProvider ?? getApplicationDocumentsDirectory;

  @override
  Set<String> get availableFormats => factory.availableFormats;

  // {P} formatKey ∈ availableFormats ∧ activities.isNotEmpty ∧ ∀ a ∈ activities: a.start.isBefore(a.end)
  // C   exportToFile(formatKey, activities, coursesById)
  // {Q} archivo escrito con flush en almacenamiento local ∧ result == ruta completa del archivo
  @override
  Future<String> exportToFile(
    String formatKey,
    List<Activity> activities,
    Map<String, Course> coursesById,
  ) async {
    final strategy = factory.strategyFor(formatKey);
    final useCase = BuildExportFile(strategy);
    final result = useCase(activities, coursesById);
    final dir = await _directoryProvider();
    final file = File(p.join(dir.path, result.fileName));
    await file.writeAsString(result.content, flush: true);
    return file.path;
  }
}
