/// Resultado de una exportación de agenda.
class ExportResult {
  final String content;
  final String fileName;
  final String mimeType;

  const ExportResult({
    required this.content,
    required this.fileName,
    required this.mimeType,
  });
}
