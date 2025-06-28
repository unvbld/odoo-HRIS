import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/providers/api_service.dart';

class AuthService extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Observable variables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _sessionToken = ''.obs;
  
  // Getters
  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null && _sessionToken.value.isNotEmpty;
  bool get isLoading => _isLoading.value;
  String get sessionToken => _sessionToken.value;
  
  // Storage keys
  static const String _userKey = 'user_data';
  static const String _sessionKey = 'session_token';
  
  @override
  void onInit() {
    super.onInit();
    // Don't call _loadUserFromStorage here since it's async
  }
  
  /// Load initial data - called from main.dart
  Future<void> loadInitialData() async {
    await _loadUserFromStorage();
  }
  
  /// Load user data and session from local storage
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load session token
      final sessionToken = prefs.getString(_sessionKey);
      if (sessionToken != null && sessionToken.isNotEmpty) {
        _sessionToken.value = sessionToken;
        
        // Load user data
        final userJson = prefs.getString(_userKey);
        if (userJson != null && userJson.isNotEmpty) {
          final userData = json.decode(userJson);
          _currentUser.value = User.fromJson(userData);
          
          print('User data loaded from storage: ${_currentUser.value?.name}');
          // Don't validate session during initial load - let user use the app
          // Only validate when making API calls
        }
      }
    } catch (e) {
      print('Error loading user from storage: $e');
      // Don't clear session on error - just log it
    }
  }
  
  /// Save user data and session to local storage
  Future<void> _saveUserToStorage(User user, String sessionToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save session token
      await prefs.setString(_sessionKey, sessionToken);
      _sessionToken.value = sessionToken;
      
      // Save user data
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
      _currentUser.value = user;
      
      print('User data saved to storage: ${user.name}');
    } catch (e) {
      print('Error saving user to storage: $e');
      throw Exception('Failed to save user data');
    }
  }
  
  /// Clear session data from storage
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_sessionKey);
      
      _currentUser.value = null;
      _sessionToken.value = '';
      
      print('Session cleared from storage');
    } catch (e) {
      print('Error clearing session: $e');
    }
  }
  
  /// Validate current session by checking profile
  Future<bool> _validateSession() async {
    if (_sessionToken.value.isEmpty) return false;
    
    try {
      final response = await _apiService.getProfile(_sessionToken.value);
      if (response.success && response.data != null) {
        // Update user data with latest from server
        _currentUser.value = response.data;
        return true;
      } else {
        // Don't clear session immediately - just return false
        // Let the user try to use the app, session will be cleared only on logout
        print('Session validation failed, but keeping session for now');
        return false;
      }
    } catch (e) {
      print('Session validation error: $e');
      // Don't clear session on network error - keep it for offline use
      return false;
    }
  }
  
  /// Login with username/email and password
  Future<ApiResponse<User>> login(String username, String password) async {
    _isLoading.value = true;
    
    try {
      final loginRequest = LoginRequest(
        username: username,
        password: password,
      );
      
      final response = await _apiService.login(loginRequest);
      
      if (response.success && response.data != null) {
        final user = response.data!;
        final sessionToken = user.sessionId ?? '';
        
        if (sessionToken.isNotEmpty) {
          // Save session and user data
          await _saveUserToStorage(user, sessionToken);
          
          print('Login successful for user: ${user.name}');
          return ApiResponse<User>(
            success: true,
            message: 'Login successful',
            data: user,
          );
        } else {
          return ApiResponse<User>(
            success: false,
            message: 'No session token received',
          );
        }
      } else {
        return ApiResponse<User>(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      print('Login error: $e');
      return ApiResponse<User>(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Register new user
  Future<ApiResponse<User>> register(
    String username,
    String name,
    String email,
    String password,
    [String? confirmPassword]
  ) async {
    _isLoading.value = true;
    
    try {
      final registerRequest = RegisterRequest(
        username: username,
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      
      final response = await _apiService.register(registerRequest);
      
      if (response.success) {
        // After successful registration, try to login
        await Future.delayed(Duration(milliseconds: 500));
        return await login(username, password);
      } else {
        return ApiResponse<User>(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      print('Registration error: $e');
      return ApiResponse<User>(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Logout user
  Future<ApiResponse<void>> logout() async {
    _isLoading.value = true;
    
    try {
      // Call logout API if we have a session token
      if (_sessionToken.value.isNotEmpty) {
        try {
          await _apiService.logout(_sessionToken.value);
        } catch (e) {
          print('Logout API call failed: $e');
          // Continue with local logout even if API fails
        }
      }
      
      // Clear local session regardless of API response
      await _clearSession();
      
      print('Logout completed');
      return ApiResponse<void>(
        success: true,
        message: 'Logout successful',
      );
    } catch (e) {
      print('Logout error: $e');
      // Still clear local session even if API call fails
      await _clearSession();
      
      return ApiResponse<void>(
        success: true,
        message: 'Logout completed',
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Get current user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      if (_sessionToken.value.isEmpty) {
        return ApiResponse<User>(
          success: false,
          message: 'No active session',
        );
      }
      
      final response = await _apiService.getProfile(_sessionToken.value);
      
      if (response.success && response.data != null) {
        // Update stored user data
        final user = response.data!;
        _currentUser.value = user;
        
        // Update storage
        await _saveUserToStorage(user, _sessionToken.value);
        
        return response;
      } else {
        // Profile fetch failed, might mean session expired
        if (response.message.toLowerCase().contains('unauthorized') ||
            response.message.toLowerCase().contains('expired')) {
          await _clearSession();
        }
        return response;
      }
    } catch (e) {
      print('Get profile error: $e');
      return ApiResponse<User>(
        success: false,
        message: 'Failed to get profile: ${e.toString()}',
      );
    }
  }
  
  /// Check if user is authenticated
  /// Check if user is authenticated - simple check without API call
  Future<bool> isAuthenticated() async {
    // Simple check: user data exists and session token is present
    return isLoggedIn; // This checks both currentUser != null && sessionToken.isNotEmpty
  }
  
  /// Check if user is authenticated with server validation
  Future<bool> isAuthenticatedWithValidation() async {
    if (!isLoggedIn) return false;
    
    // Validate session with server
    return await _validateSession();
  }
  
  /// Refresh user data
  Future<void> refreshUser() async {
    if (isLoggedIn) {
      await getProfile();
    }
  }
}
