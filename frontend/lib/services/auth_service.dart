// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.6:5000/api';
  
  String? _token;
  Map<String, dynamic>? _user;
  
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _user?['role'] == 'admin';
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userStr = prefs.getString('user');
    if (userStr != null) {
      _user = jsonDecode(userStr);
    }
    
    // Verify token if exists
    if (_token != null) {
      try {
        await verifyToken();
      } catch (e) {
        await logout();
      }
    }
  }
  
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        _token = data['token'];
        _user = data['user'];
        await _saveCredentials();
        return {'success': true, 'message': 'Account created successfully'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        _token = data['token'];
        _user = data['user'];
        await _saveCredentials();
        return {'success': true, 'message': 'Login successful'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  
  Future<void> verifyToken() async {
    if (_token == null) throw Exception('No token');
    
    final response = await http.get(
      Uri.parse('$baseUrl/auth/verify'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Invalid token');
    }
    
    final data = jsonDecode(response.body);
    _user = data['user'];
  }
  
  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
  
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('user', jsonEncode(_user));
  }
  
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}