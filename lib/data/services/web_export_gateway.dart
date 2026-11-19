import 'dart:convert';
import 'dart:js_interop';

import '../../domain/entities/activity.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/export_gateway_interface.dart';
import '../../domain/strategies/export_strategy_factory.dart';
import '../../domain/usecases/build_export_file.dart';

@JS('document')
external _JsDocument? get _document;

@JS()
extension type _JsDocument(JSObject _) implements JSObject {
  external _JsAnchorElement createElement(String tagName);
  external _JsElement? get body;
}

@JS()
extension type _JsElement(JSObject _) implements JSObject {
  external void appendChild(JSObject child);
  external void removeChild(JSObject child);
}

@JS()
extension type _JsAnchorElement(JSObject _) implements JSObject {
  external set href(String value);
  external set download(String value);
  external void click();
}

/// Adaptador Web que implementa [IExportGateway] mediante descarga de navegador.
class WebExportGateway implements IExportGateway {
  final ExportStrategyFactory factory;

  const WebExportGateway({this.factory = const ExportStrategyFactory()});

  @override
  Set<String> get availableFormats => factory.availableFormats;

  // {P} formatKey ∈ availableFormats ∧ activities.isNotEmpty ∧ ∀ a ∈ activities: a.start.isBefore(a.end)
  // C   exportToFile(formatKey, activities, coursesById)
  // {Q} descarga disparada en navegador con contenido RFC válido ∧ result == nombre de archivo
  @override
  Future<String> exportToFile(
    String formatKey,
    List<Activity> activities,
    Map<String, Course> coursesById,
  ) async {
    final strategy = factory.strategyFor(formatKey);
    final result = BuildExportFile(strategy)(activities, coursesById);

    final doc = _document;
    if (doc != null) {
      final encoded = base64.encode(utf8.encode(result.content));
      final anchor = doc.createElement('a')
        ..href = 'data:${result.mimeType};charset=utf-8;base64,$encoded'
        ..download = result.fileName;
      doc.body?.appendChild(anchor);
      anchor.click();
      doc.body?.removeChild(anchor);
    }

    return result.fileName;
  }
}
