import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventaccess_app/services/api_service.dart';
import 'package:eventaccess_app/models/user.dart';

/// Servicio de autenticación que gestiona login, logout y persistencia de sesión
class AuthService {
  final ApiService _apiService = ApiService();
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Session Persistence

  Future<void> saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  // Authentication Methods

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('authToken');
    _currentUser = null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await _apiService.get(
        '/user',
        headers: {'Authorization': 'Bearer $token'},
      );

      return response != null;
    } catch (e) {
      debugPrint('Error verificando token: $e');
      if (e is SocketException || e is http.ClientException) {
        return true;
      }
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/login',
        body: {'email': email, 'password': password},
      );

      if (response != null) {
        await _saveToken(response['data']['auth']['token']);
        _currentUser = User.fromJson(response['data']['auth']['user']);
        await saveLoginState();
        return response;
      }
      return null;
    } catch (e) {
      debugPrint('Error en login: $e');
      return null;
    }
  }
}
