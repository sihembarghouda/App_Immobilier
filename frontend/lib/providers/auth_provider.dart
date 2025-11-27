import 'package:flutter/material.dart';
import '../models/user.dart';
import '../core/services/api_service.dart';
import '../core/services/token_service.dart';
import '../core/services/storage_service.dart';
import '../core/config/app_config.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  ApiService? _apiService;
  TokenService? _tokenService;
  StorageService? _storageService;

  bool _initialized = false;

  User? get user => _user;
  String? get token => _tokenService?.token;
  bool get isAuthenticated => _tokenService?.hasToken ?? false;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get initialized => _initialized;

  /// Initialiser le provider avec les services
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔄 Initializing AuthProvider...');

      _apiService = await ApiService.getInstance();
      _tokenService = await TokenService.getInstance();
      _storageService = await StorageService.getInstance();

      // Charger l'utilisateur si le token existe
      if (_tokenService!.hasToken) {
        print('✅ Token found, loading user data...');
        await _loadUserData();
      } else {
        print('⚠️  No token found');
      }

      _initialized = true;
      print('✅ AuthProvider initialized successfully');
    } catch (e) {
      print('❌ AuthProvider initialization error: $e');
      _error = 'Initialization failed: $e';
    }

    notifyListeners();
  }

  /// Charger les données utilisateur
  Future<void> _loadUserData() async {
    try {
      // Essayer de charger depuis le cache
      final cachedUser = _storageService!.getJson(AppConfig.userKey);
      if (cachedUser != null) {
        _user = User.fromJson(cachedUser);
        notifyListeners();
        return;
      }

      // Rafraîchir depuis l'API (seulement si pas en mode offline)
      final userData = await _apiService!.getCurrentUser();
      _user = userData;

      // Sauvegarder dans le cache
      await _storageService!.setJson(AppConfig.userKey, _user!.toJson());

      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs réseau en mode test
      // Token invalide, déconnexion
      if (e.toString().contains('Unauthorized')) {
        await logout();
      }
    }
  }

  /// Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService!.login(email, password);

      if (response['success'] == true && response['data'] != null) {
        _user = User.fromJson(response['data']['user']);

        // Le token est déjà sauvegardé par l'ApiService
        // Sauvegarder les données utilisateur
        await _storageService!.setJson(AppConfig.userKey, _user!.toJson());

        print('✅ Login successful: ${_user!.name}');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Login error: $e');
      _error = 'Login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription
  Future<bool> register(
    String name,
    String email,
    String password,
    String role, {
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Attempting registration for: $email');

      final response = await _apiService!.register(
        name,
        email,
        password,
        role,
        phone: phone,
      );

      if (response['success'] == true && response['data'] != null) {
        _user = User.fromJson(response['data']['user']);

        // Le token est déjà sauvegardé par l'ApiService
        // Sauvegarder les données utilisateur
        await _storageService!.setJson(AppConfig.userKey, _user!.toJson());

        print('✅ Registration successful: ${_user!.name}');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Registration error: $e');
      _error = 'Registration error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Mise à jour du profil
  Future<bool> updateProfile(String name, String phone,
      {String? avatar, String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('✏️  Updating profile...');

      final updatedUser = await _apiService!
          .updateProfile(name, phone, avatar: avatar, role: role);
      _user = updatedUser;

      // Sauvegarder dans le cache
      await _storageService!.setJson(AppConfig.userKey, _user!.toJson());

      print('✅ Profile updated successfully');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Update profile error: $e');
      _error = 'Update profile error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      print('🔓 Logging out...');

      // Supprimer le token
      await _tokenService!.deleteToken();

      // Supprimer les données utilisateur
      await _storageService!.remove(AppConfig.userKey);

      _user = null;
      _error = null;

      print('✅ Logout successful');

      notifyListeners();
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  /// Rafraîchir les données utilisateur
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      await _loadUserData();
    } catch (e) {
      print('❌ Refresh user error: $e');
    }
  }

  /// Upload avatar
  Future<bool> uploadAvatar(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📤 Uploading avatar...');

      final response = await _apiService!.uploadProfileImage(imagePath);

      if (response != null && response['imageUrl'] != null) {
        // Refresh user data to get the new avatar
        await _loadUserData();
        print('✅ Avatar uploaded successfully');
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Upload avatar error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🗑️  Deleting account...');

      final response = await _apiService!.deleteAccount();

      if (response != null && response['success'] == true) {
        print('✅ Account deleted successfully');
        // Clear all data
        await logout();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Delete account error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
