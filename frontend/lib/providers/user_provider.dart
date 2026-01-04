import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  String _userId = '';
  String _userName = 'User';
  
  String get userId => _userId;
  String get userName => _userName;
  
  UserProvider() {
    _loadUserId();
  }
  
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? '';
    
    if (_userId.isEmpty) {
      _userId = const Uuid().v4();
      await prefs.setString('user_id', _userId);
    }
    
    _userName = prefs.getString('user_name') ?? 'User';
    notifyListeners();
  }
  
  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    notifyListeners();
  }
}