import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _authToken;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get authToken => _authToken;
  String? get userEmail => _userEmail;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _userEmail = prefs.getString('user_email');
    _isAuthenticated = _authToken != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      // For MVP, using simple credential storage
      // In production, this would authenticate against your backend
      if (email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        
        // Generate a simple token (in production, get this from backend)
        final token = 'mobile_${DateTime.now().millisecondsSinceEpoch}';
        
        await prefs.setString('auth_token', token);
        await prefs.setString('user_email', email);
        
        _authToken = token;
        _userEmail = email;
        _isAuthenticated = true;
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
    
    _authToken = null;
    _userEmail = null;
    _isAuthenticated = false;
    
    notifyListeners();
  }
}