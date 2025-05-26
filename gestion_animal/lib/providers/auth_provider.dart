import 'package:flutter/material.dart';
import 'package:gestion_animal/models/user.dart';
import 'package:gestion_animal/services/auth_service.dart';
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService();
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  Future checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _authService.login(email, password);
      if (success) {
        _currentUser = await _authService.getCurrentUser();
        notifyListeners();
        return true;
      } else {
        _error = 'Échec de connexion. Vérifiez vos identifiants.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _authService.register(name, email, password);
      if (user != null) {
        // Après l'inscription, connectez l'utilisateur
        return await login(email, password);
      } else {
        _error = 'Échec de l\'inscription. Veuillez réessayer.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
