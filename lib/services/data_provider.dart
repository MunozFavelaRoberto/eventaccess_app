import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventaccess_app/models/user.dart';
import 'package:eventaccess_app/services/api_service.dart';
import 'package:eventaccess_app/services/auth_service.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService? _authService;

  // Clave para SharedPreferences
  static const String _userDataKey = 'cached_user_data';

  DataProvider({AuthService? authService, ApiService? apiService})
    : _authService = authService,
      _apiService = apiService ?? ApiService() {
    // Cargar datos de usuario desde cache al iniciar
    _loadCachedUser();
  }

  User? _user;
  bool _isLoading = false;
  bool _isUnauthorized = false;
  bool _isInitialLoading = true;
  bool _hasAttemptedFetch = false; // Track si ya intentamos obtener datos

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isUnauthorized => _isUnauthorized;
  bool get isInitialLoading => _isInitialLoading;
  bool get hasAttemptedFetch => _hasAttemptedFetch;

  // Cargar usuario desde cache local
  Future<void> _loadCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userDataKey);
      if (userJson != null) {
        final Map<String, dynamic> userMap =
            json.decode(userJson) as Map<String, dynamic>;
        _user = User.fromJson(userMap);
        _isInitialLoading = false;
        debugPrint('Usuario cargado desde cache: ${_user?.fullName}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error cargando usuario desde cache: $e');
    }
  }

  // Guardar usuario en cache local
  Future<void> _cacheUser() async {
    if (_user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = _user!.toJson();
      await prefs.setString(_userDataKey, json.encode(userJson));
      debugPrint('Usuario guardado en cache');
    } catch (e) {
      debugPrint('Error guardando usuario en cache: $e');
    }
  }

  // Limpiar cache de usuario (logout)
  Future<void> _clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      debugPrint('Cache de usuario limpiada');
    } catch (e) {
      debugPrint('Error limpiando cache: $e');
    }
  }

  Future<void> fetchUser() async {
    _isLoading = true;
    _hasAttemptedFetch = true;
    // No llamar notifyListeners() aquí para evitar error de build durante la construcción del widget

    try {
      final token = await _authService?.getToken();
      if (token != null) {
        // Obtener datos del perfil desde la API
        final data = await _apiService.get(
          '/client/profile',
          headers: {'Authorization': 'Bearer $token'},
        );
        debugPrint('Profile API response: $data');

        // Verificar estructura de la respuesta
        if (data == null) {
          debugPrint('Profile API returned null');
          _isLoading = false;
          notifyListeners();
          return;
        }

        // Obtener los datos del perfil directamente de la respuesta API
        final profileData = data['data']?['item'];
        if (profileData == null) {
          debugPrint('Profile data structure unexpected: $data');
          _isLoading = false;
          notifyListeners();
          return;
        }

        // La estructura es: data['data']['item']['user'] con full_name y email
        final userData = profileData['user'];
        if (userData == null) {
          debugPrint('User data not found in profile: $data');
          _isLoading = false;
          notifyListeners();
          return;
        }

        _user = User(
          clientNumber: profileData['client_number'] as String? ?? 'N/A',
          status: 'Activo',
          balance: 0.0,
          fullName: userData['full_name'] as String? ?? 'Usuario',
          email: userData['email'] as String? ?? 'email@desconocido.com',
        );
        _isInitialLoading = false;
        // Éxito - usuario válido
        _isUnauthorized = false;
        debugPrint(
          'Usuario obtenido de perfil: ${_user!.fullName} - Cliente: ${_user!.clientNumber}',
        );

        // Guardar en cache para persistencia
        await _cacheUser();
      } else {
        _isInitialLoading = false;
        // Token null - no hay sesión
        _isUnauthorized = true;
        _user = null;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      _isInitialLoading = false;

      // Solo marcar como no autorizado si es error explícito de autenticación
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('no autorizado') ||
          errorMsg.contains('401') ||
          errorMsg.contains('unauthorized')) {
        _isUnauthorized = true;
        _user = null;
      } else {
        // Error de red u otro tipo - no marcar como no autorizado
        // Mantener el estado actual pero asegurar que se intentó
        _isUnauthorized = false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para actualizar el usuario
  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  // Resetear estado de autorización (para cuando usuario hace logout o inicia sesión)
  void resetUnauthorized() {
    _isUnauthorized = false;
    _user = null;
    _hasAttemptedFetch = false;
    _clearUserCache(); // Limpiar cache al hacer logout
    notifyListeners();
  }

  // Método para establecer usuario manualmente (después de login exitoso)
  void setUser(User user) {
    _user = user;
    _isUnauthorized = false;
    _isInitialLoading = false;
    notifyListeners();
  }

  // Refresh completo para pull-to-refresh (usa notifyListeners)
  Future<void> refreshAllData() async {
    _isInitialLoading = false;

    await fetchUser();

    // Solo hacer notifyListeners() después de que todo termine
    notifyListeners();
  }
}
