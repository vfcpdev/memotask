import '../../domain/repositories/export_gateway_interface.dart';
import '../../domain/repositories/schedule_repository_interface.dart';
import '../../domain/repositories/user_profile_repository_interface.dart';
import '../datasources/app_database.dart';
import '../repositories/drift_schedule_repository.dart';
import '../repositories/drift_user_profile_repository.dart';
import '../services/local_export_gateway.dart';

AppDatabase? _sharedDb;

AppDatabase _getDb() => _sharedDb ??= AppDatabase();

IScheduleRepository createDefaultScheduleRepository() {
  return DriftScheduleRepository(_getDb());
}

IUserProfileRepository createDefaultUserProfileRepository() {
  return DriftUserProfileRepository(_getDb());
}

IExportGateway createDefaultExportGateway() {
  return LocalExportGateway();
}
