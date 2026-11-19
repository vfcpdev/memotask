import '../../domain/repositories/export_gateway_interface.dart';
import '../../domain/repositories/schedule_repository_interface.dart';
import '../../domain/repositories/user_profile_repository_interface.dart';

IScheduleRepository createDefaultScheduleRepository() {
  throw UnsupportedError('Plataforma no soportada para repositorio por defecto');
}

IUserProfileRepository createDefaultUserProfileRepository() {
  throw UnsupportedError('Plataforma no soportada para perfil por defecto');
}

IExportGateway createDefaultExportGateway() {
  throw UnsupportedError('Plataforma no soportada para exportación por defecto');
}
