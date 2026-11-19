import '../entities/user_profile.dart';

/// Caso de uso: validar y registrar el nombre del usuario como [UserProfile].
class RegisterUserName {
  const RegisterUserName();

  // {P} rawName.trim().isNotEmpty ∧ rawName.trim().length <= AppConfig.maxUserNameLength
  // C   registerUserName(rawName)
  // {Q} result ∈ UserProfile ∧ result.name == rawName.trim() ∧ INV-USR-1(result)
  UserProfile call(String rawName) {
    return UserProfile.create(name: rawName);
  }
}
