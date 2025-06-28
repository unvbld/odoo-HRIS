import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../models/user_model.dart';
import '../models/attendance_model.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'http://localhost:8069/api';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
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

  Future<ApiResponse<T>> _handleRequest<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic>) parser,
  ) async {
    try {
      final response = await request().timeout(timeoutDuration);
      
      if (response.body.isEmpty) {
        return ApiResponse<T>(
          success: false,
          message: 'Server returned empty response',
        );
      }

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Handle case where data['data'] might be null (e.g., logout response)
        final rawData = data['data'];
        
        if (rawData != null) {
          final parsedData = parser(rawData);
          return ApiResponse<T>(
            success: true,
            message: data['message'] ?? 'Request successful',
            data: parsedData,
          );
        } else {
          // For responses without data (like logout), return success without parsed data
          return ApiResponse<T>(
            success: true,
            message: data['message'] ?? 'Request successful',
            data: null,
          );
        }
      } else {
        return ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
        );
      }
    } on SocketException {
      developer.log('Network connection error', name: 'ApiService');
      return ApiResponse<T>(
        success: false,
        message: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      developer.log('HTTP error occurred', name: 'ApiService');
      return ApiResponse<T>(
        success: false,
        message: 'Server error occurred. Please try again later.',
      );
    } on FormatException {
      developer.log('Invalid response format', name: 'ApiService');
      return ApiResponse<T>(
        success: false,
        message: 'Invalid response from server.',
      );
    } catch (e) {
      developer.log('Unexpected error: $e', name: 'ApiService');
      return ApiResponse<T>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
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
    return _handleRequest<User>(
      () => _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: json.encode(request.toJson()),
      ),
      (data) => User.fromJson(data),
    );
  }

  // Register
  Future<ApiResponse<User>> register(RegisterRequest request) async {
    return _handleRequest<User>(
      () => _client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: json.encode(request.toJson()),
      ),
      (data) => User.fromJson(data),
    );
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
      ).timeout(timeoutDuration);
      
      if (response.body.isEmpty) {
        return ApiResponse<String>(
          success: false,
          message: 'Server returned empty response',
        );
      }

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<String>(
          success: true,
          message: data['message'] ?? 'Logout successful',
          data: data['message'] ?? 'Logout successful',
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: data['message'] ?? 'Logout failed',
        );
      }
    } on SocketException {
      developer.log('Network connection error during logout', name: 'ApiService');
      return ApiResponse<String>(
        success: false,
        message: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      developer.log('HTTP error during logout', name: 'ApiService');
      return ApiResponse<String>(
        success: false,
        message: 'Server error occurred. Please try again later.',
      );
    } on FormatException {
      developer.log('Invalid response format during logout', name: 'ApiService');
      return ApiResponse<String>(
        success: false,
        message: 'Invalid response from server.',
      );
    } catch (e) {
      developer.log('Unexpected error during logout: $e', name: 'ApiService');
      return ApiResponse<String>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Get Profile (with session)
  Future<ApiResponse<User>> getProfile(String sessionId) async {
    return _handleRequest<User>(
      () => _client.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $sessionId',
        },
      ),
      (data) => User.fromJson(data),
    );
  }

  // Attendance Dashboard
  Future<ApiResponse<AttendanceDashboard>> getAttendanceDashboard(String sessionToken) async {
    return _handleRequest<AttendanceDashboard>(
      () => _client.get(
        Uri.parse('$baseUrl/attendance/dashboard'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $sessionToken',
        },
      ),
      (data) => AttendanceDashboard.fromJson(data),
    );
  }

  // Toggle Check-in/Check-out
  Future<ApiResponse<CheckInOutResponse>> toggleCheckInOut(String sessionToken) async {
    return _handleRequest<CheckInOutResponse>(
      () => _client.post(
        Uri.parse('$baseUrl/attendance/toggle'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $sessionToken',
        },
        body: json.encode({}),
      ),
      (data) => CheckInOutResponse.fromJson(data),
    );
  }
}
