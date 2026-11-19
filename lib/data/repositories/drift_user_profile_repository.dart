import '../../domain/config/app_config.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository_interface.dart';
import '../datasources/app_database.dart';

/// Repositorio Drift que implementa [IUserProfileRepository].
class DriftUserProfileRepository implements IUserProfileRepository {
  final AppDatabase _db;

  DriftUserProfileRepository(this._db);

  // {P} true
  // C   getProfile()
  // {Q} result == null ∨ INV-USR-1(result)
  @override
  Future<UserProfile?> getProfile() async {
    final query = _db.select(_db.userProfiles)
      ..where((t) => t.id.equals(AppConfig.defaultProfileId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return UserProfile.create(name: row.name);
  }

  // {P} INV-USR-1(profile)
  // C   saveProfile(profile)
  // {Q} persisted(profile) en tabla UserProfiles con id == AppConfig.defaultProfileId
  @override
  Future<void> saveProfile(UserProfile profile) {
    return _db.into(_db.userProfiles).insertOnConflictUpdate(
          UserProfilesCompanion.insert(
            id: AppConfig.defaultProfileId,
            name: profile.name,
          ),
        );
  }
}
