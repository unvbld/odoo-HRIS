import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/user_model.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'http://localhost:8069/api';
  
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }

  // Health Check
  Future<ApiResponse<String>> healthCheck() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: data['message'] ?? 'Health check passed',
          data: data['message'],
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: data['message'] ?? 'Health check failed',
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
  // Login
  Future<ApiResponse<User>> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['data']);
        return ApiResponse<User>(
          success: true,
          message: data['message'] ?? 'Login successful',
          data: user,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Register (placeholder for future implementation)
  Future<ApiResponse<User>> register(RegisterRequest request) async {
    try {
      // For now, return a placeholder response since the backend doesn't have register endpoint yet
      return ApiResponse<User>(
        success: false,
        message: 'Register endpoint not implemented yet in backend',
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Logout (with session)
  Future<ApiResponse<String>> logout(String sessionId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $sessionId',
        },
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: data['message'] ?? 'Logout successful',
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: data['message'] ?? 'Logout failed',
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get Profile (with session)
  Future<ApiResponse<User>> getProfile(String sessionId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $sessionId',
        },
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['data']);
        return ApiResponse<User>(
          success: true,
          message: data['message'] ?? 'Profile retrieved',
          data: user,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: data['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
