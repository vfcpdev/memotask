import '../../domain/repositories/export_gateway_interface.dart';
import '../../domain/repositories/schedule_repository_interface.dart';
import '../repositories/web_schedule_repository.dart';
import '../services/web_export_gateway.dart';

IScheduleRepository createDefaultScheduleRepository() {
  return WebScheduleRepository();
}

IExportGateway createDefaultExportGateway() {
  return const WebExportGateway();
}
