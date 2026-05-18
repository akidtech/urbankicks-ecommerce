import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbankicks/models/user_model.dart';
import 'dart:convert';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserData = 'userData';

  // Save login session
  Future<void> saveLoginSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserData, json.encode(user.toJson()));
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (isLoggedIn) {
      final userData = prefs.getString(_keyUserData);
      if (userData != null) {
        return User.fromJson(json.decode(userData));
      }
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserData);
  }

  // Get user role
  Future<String?> getUserRole() async {
    final user = await getCurrentUser();
    return user?.role;
  }
}
