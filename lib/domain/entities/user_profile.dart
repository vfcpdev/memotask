import 'package:equatable/equatable.dart';

import '../config/app_config.dart';

/// Perfil de usuario del estudiante.
///
/// Invariante INV-USR-1: [name] no vacío y longitud <= [AppConfig.maxUserNameLength].
class UserProfile extends Equatable {
  final String name;

  const UserProfile._({required this.name});

  // {P} name.trim().isNotEmpty ∧ name.trim().length <= AppConfig.maxUserNameLength
  // C   UserProfile.create(name: name)
  // {Q} result ∈ UserProfile ∧ result.name == name.trim() ∧ INV-USR-1(result) (throws ArgumentError si ¬P)
  factory UserProfile.create({required String name}) {
    final normalized = name.trim();
    if (normalized.isEmpty || normalized.length > AppConfig.maxUserNameLength) {
      throw ArgumentError(
        'name debe tener entre 1 y ${AppConfig.maxUserNameLength} caracteres',
      );
    }
    return UserProfile._(name: normalized);
  }

  @override
  List<Object?> get props => [name];
}
