import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart' as shared_prefs;

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  // Initialize - check if user is already logged in
  Future<void> init() async {
    final prefs = await shared_prefs.SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      // TODO: Fetch user data from API
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Call API
      // For now, mock authentication
      await Future.delayed(const Duration(seconds: 2));

      _token = 'mock_token_123';
      _user = User(
        id: '1',
        email: email,
        name: 'John Doe',
        createdAt: DateTime.now(),
      );

      // Save token
      final prefs = await shared_prefs.SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 2));

      _token = 'mock_token_123';
      _user = User(
        id: '1',
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      final prefs = await shared_prefs.SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await shared_prefs.SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
