import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'uninotes_token';
  static const String _userKey = 'uninotes_user';

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Set token
  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get user
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        return User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Set user
  Future<void> setUser(User user) async {
    final userJson = jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
    });
    await _storage.write(key: _userKey, value: userJson);
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Check if authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
