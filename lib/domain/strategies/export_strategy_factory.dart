import '../config/app_config.dart';
import 'csv_export_strategy.dart';
import 'export_strategy.dart';
import 'ics_export_strategy.dart';

/// Patrón Factory: resuelve dinámicamente la estrategia de exportación por clave.
class ExportStrategyFactory {
  final Map<String, ExportStrategy> _strategies;

  const ExportStrategyFactory({Map<String, ExportStrategy>? strategies})
      : _strategies = strategies ??
            const {
              AppConfig.icsFormatKey: IcsExportStrategy(),
              AppConfig.csvFormatKey: CsvExportStrategy(),
            };

  Set<String> get availableFormats => Set.unmodifiable(_strategies.keys);

  // {P} formatKey.trim().isNotEmpty ∧ formatKey.toLowerCase() ∈ _strategies.keys
  // C   strategyFor(formatKey)
  // {Q} result ∈ ExportStrategy ∧ result.fileExtension == formatKey.toLowerCase() (throws ArgumentError si ¬P)
  ExportStrategy strategyFor(String formatKey) {
    final normalized = formatKey.trim().toLowerCase();
    final strategy = _strategies[normalized];
    if (strategy == null) {
      throw ArgumentError('Estrategia de exportación desconocida: $formatKey');
    }
    return strategy;
  }
}
