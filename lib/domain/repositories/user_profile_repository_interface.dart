import '../entities/user_profile.dart';

/// Puerto DIP de persistencia para el perfil local del usuario.
abstract interface class IUserProfileRepository {
  // {P} true
  // C   getProfile()
  // {Q} result == null ∨ INV-USR-1(result)
  Future<UserProfile?> getProfile();

  // {P} INV-USR-1(profile)
  // C   saveProfile(profile)
  // {Q} persisted(profile) ∧ getProfile() == profile
  Future<void> saveProfile(UserProfile profile);
}
