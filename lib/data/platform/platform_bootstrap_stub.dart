import '../../domain/repositories/export_gateway_interface.dart';
import '../../domain/repositories/schedule_repository_interface.dart';

IScheduleRepository createDefaultScheduleRepository() {
  throw UnsupportedError('Plataforma no soportada para repositorio por defecto');
}

IExportGateway createDefaultExportGateway() {
  throw UnsupportedError('Plataforma no soportada para exportación por defecto');
}
