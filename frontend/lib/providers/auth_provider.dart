import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isInitialized = false;
  bool _isLoading = false;
  
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isAdmin => _authService.isAdmin;
  
  String? get token => _authService.token;
  Map<String, dynamic>? get user => _authService.user;
  String get userName => user?['name'] ?? 'User';
  String get userEmail => user?['email'] ?? '';
  
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.init();
    
    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }
  
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await _authService.signup(
      email: email,
      password: password,
      name: name,
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await _authService.login(
      email: email,
      password: password,
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
  
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
  
  Map<String, String> getHeaders() {
    return _authService.getHeaders();
  }
}