import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../data/providers/api_service.dart';

class AuthService extends GetxService {
  static const String _sessionKey = 'session_id';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;
  late ApiService _apiService;

  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoading => _isLoading.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _apiService = Get.find<ApiService>();
    await _loadUserFromStorage();
  }

  // Load user data from storage on app start
  Future<void> _loadUserFromStorage() async {
    try {
      final sessionId = await _secureStorage.read(key: _sessionKey);
      final userData = _prefs.getString(_userKey);
      
      if (sessionId != null && userData != null) {
        final userMap = Map<String, dynamic>.from(
          Map.fromEntries(
            userData.split('&').map((e) => MapEntry(
              e.split('=')[0],
              e.split('=')[1],
            )),
          ),
        );
        
        final user = User.fromJson({
          ...userMap,
          'session_id': sessionId,
        });
        
        _currentUser.value = user;
        _isLoggedIn.value = true;
      }
    } catch (e) {
      print('Error loading user from storage: $e');
      await clearUserData();
    }
  }
  // Login
  Future<ApiResponse<User>> login(String email, String password) async {
    _isLoading.value = true;
    
    try {
      final loginRequest = LoginRequest(username: email, password: password);
      final response = await _apiService.login(loginRequest);
      
      if (response.success && response.data != null) {
        final user = response.data!;
        await _saveUserToStorage(user);
        _currentUser.value = user;
        _isLoggedIn.value = true;
      }
      
      return response;
    } finally {
      _isLoading.value = false;
    }
  }

  // Register
  Future<ApiResponse<User>> register(String name, String email, String password) async {
    _isLoading.value = true;
    
    try {
      final registerRequest = RegisterRequest(
        name: name,
        email: email,
        password: password,
      );
      final response = await _apiService.register(registerRequest);
      
      if (response.success && response.data != null) {
        final user = response.data!;
        await _saveUserToStorage(user);
        _currentUser.value = user;
        _isLoggedIn.value = true;
      }
      
      return response;
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout
  Future<ApiResponse<String>> logout() async {
    _isLoading.value = true;
    
    try {
      ApiResponse<String> response = ApiResponse<String>(
        success: true,
        message: 'Logged out successfully',
      );
      
      if (_currentUser.value?.sessionId != null) {
        response = await _apiService.logout(_currentUser.value!.sessionId!);
      }
      
      // Clear local data regardless of API response
      await clearUserData();
      
      return response;
    } finally {
      _isLoading.value = false;
    }
  }

  // Save user to storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      if (user.sessionId != null) {
        await _secureStorage.write(key: _sessionKey, value: user.sessionId!);
      }
      
      // Simple serialization for user data (excluding sensitive session)
      final userData = 'id=${user.id}&name=${user.name}&email=${user.email}';
      await _prefs.setString(_userKey, userData);
    } catch (e) {
      print('Error saving user to storage: $e');
    }
  }

  // Clear user data
  Future<void> clearUserData() async {
    try {
      await _secureStorage.delete(key: _sessionKey);
      await _prefs.remove(_userKey);
      _currentUser.value = null;
      _isLoggedIn.value = false;
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Check if session is still valid
  Future<bool> validateSession() async {
    if (_currentUser.value?.sessionId == null) return false;
    
    try {
      final response = await _apiService.getProfile(_currentUser.value!.sessionId!);
      if (!response.success) {
        await clearUserData();
        return false;
      }
      return true;
    } catch (e) {
      await clearUserData();
      return false;
    }
  }
}
