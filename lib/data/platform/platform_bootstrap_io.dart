import '../../domain/repositories/export_gateway_interface.dart';
import '../../domain/repositories/schedule_repository_interface.dart';
import '../datasources/app_database.dart';
import '../repositories/drift_schedule_repository.dart';
import '../services/local_export_gateway.dart';

IScheduleRepository createDefaultScheduleRepository() {
  return DriftScheduleRepository(AppDatabase());
}

IExportGateway createDefaultExportGateway() {
  return LocalExportGateway();
}
