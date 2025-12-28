import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  User? _user;
  bool _isAuthenticated = false;
  bool _loading = true;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get loading => _loading;

  AuthProvider() {
    _checkAuth();
  }

  // Check authentication on startup
  Future<void> _checkAuth() async {
    try {
      final token = await _authService.getToken();
      final userData = await _authService.getUser();

      if (token != null && userData != null) {
        _user = userData;
        _isAuthenticated = true;
      } else {
        _user = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      _user = null;
      _isAuthenticated = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      final user = await _apiService.login(email, password);
      _user = user;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<void> register(String name, String email, String password) async {
    try {
      final user = await _apiService.register(name, email, password);
      _user = user;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    final userData = await _authService.getUser();
    if (userData != null) {
      _user = userData;
      notifyListeners();
    }
  }
}
