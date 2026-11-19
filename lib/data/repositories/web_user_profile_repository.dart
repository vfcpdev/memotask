import 'dart:convert';
import 'dart:js_interop';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository_interface.dart';

@JS('localStorage')
external _JsStorage? get _localStorage;

@JS()
extension type _JsStorage(JSObject _) implements JSObject {
  external String? getItem(String key);
  external void setItem(String key, String value);
}

/// Repositorio Web que implementa [IUserProfileRepository] sobre `localStorage`.
class WebUserProfileRepository implements IUserProfileRepository {
  static const String _profileKey = 'memotask_user_profile_v1';

  UserProfile? _memoryProfile;

  // {P} true
  // C   getProfile()
  // {Q} result == null ∨ INV-USR-1(result)
  @override
  Future<UserProfile?> getProfile() async {
    try {
      final raw = _localStorage?.getItem(_profileKey);
      if (raw != null && raw.isNotEmpty) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final name = m['name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          return UserProfile.create(name: name);
        }
      }
    } catch (_) {
      // Respaldo seguro en memoria si localStorage no está disponible.
    }
    return _memoryProfile;
  }

  // {P} INV-USR-1(profile)
  // C   saveProfile(profile)
  // {Q} persisted(profile) en localStorage/memoria
  @override
  Future<void> saveProfile(UserProfile profile) async {
    _memoryProfile = profile;
    try {
      final payload = jsonEncode({'name': profile.name});
      _localStorage?.setItem(_profileKey, payload);
    } catch (_) {
      // Ya respaldado en memoria.
    }
  }
}
