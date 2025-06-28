import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../../services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/api_service.dart';
import '../../../utils/time_utils.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();
  
  // Observable variables
  final RxString currentTime = ''.obs;
  final RxString currentDate = ''.obs;
  final RxBool isCheckedIn = false.obs;
  final RxString checkInTime = ''.obs;
  final RxString checkOutTime = ''.obs;
  final RxString workingHours = '00:00:00'.obs;
  final RxInt selectedBottomIndex = 0.obs;
  final RxString userName = 'User'.obs;
  final RxString userLocation = 'Your Office Location'.obs;
  final RxBool isLoading = false.obs;
  
  // Attendance data
  final RxInt presentDays = 0.obs;
  final RxInt absentDays = 0.obs;
  final RxInt lateDays = 0.obs;
  
  // Getters
  User? get currentUser => _authService.currentUser;

  @override
  void onInit() {
    super.onInit();
    developer.log('HomeController onInit started', name: 'HomeController');
    
    // Wait for AuthService to be initialized before checking auth status
    _waitForAuthAndInitialize();
  }
  
  Future<void> _waitForAuthAndInitialize() async {
    try {
      developer.log('Waiting for AuthService to be initialized...', name: 'HomeController');
      
      // Wait for AuthService to be initialized (with timeout)
      int retries = 0;
      const maxRetries = 50; // 5 seconds max wait
      const retryDelay = Duration(milliseconds: 100);
      
      while (!_authService.isInitialized && retries < maxRetries) {
        await Future.delayed(retryDelay);
        retries++;
      }
      
      if (!_authService.isInitialized) {
        developer.log('AuthService initialization timeout, proceeding anyway', name: 'HomeController');
      } else {
        developer.log('AuthService initialized successfully', name: 'HomeController');
      }
      
      await _checkAuthAndInitialize();
      
    } catch (e) {
      developer.log('Error waiting for auth initialization: $e', name: 'HomeController');
      // Fallback to direct check
      await _checkAuthAndInitialize();
    }
  }
  
  Future<void> _checkAuthAndInitialize() async {
    try {
      // Now safe to check authentication since AuthService is initialized
      final isAuthenticated = _authService.isLoggedIn;
      
      developer.log('Auth check - isAuthenticated: $isAuthenticated, currentUser: ${currentUser?.name}', name: 'HomeController');
      
      if (!isAuthenticated) {
        developer.log('Not authenticated, redirecting to auth', name: 'HomeController');
        Get.offAllNamed('/auth');
        return;
      }
      
      // User is authenticated, proceed with initialization
      developer.log('User authenticated, initializing dashboard', name: 'HomeController');
      await _initializeDashboard();
      
    } catch (e) {
      developer.log('Error in auth check: $e', name: 'HomeController');
      // On error, redirect to auth for safety
      Get.offAllNamed('/auth');
    }
  }
  
  Future<void> _initializeDashboard() async {
    try {
      // Initialize user data
      _initializeUserData();
      _updateCurrentTime();
      
      // Start time updater
      _startTimeUpdater();
      
      // Load dashboard data after a short delay
      Future.delayed(Duration(milliseconds: 300), () {
        _loadDashboardData();
      });
      
    } catch (e) {
      developer.log('Error during dashboard initialization: $e', name: 'HomeController');
    }
  }
  
  void _initializeUserData() {
    // Use the current user from AuthService
    final currentUserName = currentUser?.name ?? 'User';
    
    userName.value = currentUserName;
    userLocation.value = 'Your Office Location';
    
    developer.log('Initialized user data. User: $currentUserName', name: 'HomeController');
  }

  Future<void> _loadDashboardData() async {
    if (isLoading.value) return; // Prevent multiple concurrent calls
    
    try {
      isLoading.value = true;
      
      // Check if we have valid session
      if (!_authService.isLoggedIn || _authService.sessionToken.isEmpty) {
        developer.log('No valid session found during dashboard load', name: 'HomeController');
        Get.snackbar(
          'Authentication Error', 
          'Please try logging in again',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final sessionToken = _authService.sessionToken;
      developer.log('Loading dashboard data with session: ${sessionToken.substring(0, 10)}...', name: 'HomeController');
      final response = await _apiService.getAttendanceDashboard(sessionToken);
      
      if (response.success && response.data != null) {
        final dashboard = response.data!;
        
        // Keep the original user name, don't override with dashboard data
        // because dashboard might return admin user data
        if (userName.value == 'User') {
          userName.value = 'zefa'; // Set default name if still User
        }
        
        userLocation.value = dashboard.userInfo.location.isNotEmpty 
            ? dashboard.userInfo.location 
            : 'Office Location';
        
        // Update current status
        isCheckedIn.value = dashboard.currentStatus.isCheckedIn;
        checkInTime.value = dashboard.currentStatus.checkInTime;
        checkOutTime.value = dashboard.currentStatus.checkOutTime;
        workingHours.value = dashboard.currentStatus.workingHours;
        
        // Update monthly summary
        presentDays.value = dashboard.monthlySummary.presentDays;
        absentDays.value = dashboard.monthlySummary.absentDays;
        lateDays.value = dashboard.monthlySummary.lateDays;
        
        developer.log('Dashboard data loaded successfully. User: ${userName.value}', name: 'HomeController');
      } else {
        developer.log('Failed to load dashboard data: ${response.message}', name: 'HomeController');
        
        // Only redirect to login for authentication errors, not other errors
        if (response.message.toLowerCase().contains('authentication required') || 
            response.message.toLowerCase().contains('unauthorized')) {
          developer.log('Authentication error detected, redirecting to login', name: 'HomeController');
          await _authService.logout();
          Get.offAllNamed('/auth');
        } else {
          // For other errors, just show message but don't redirect
          Get.snackbar(
            'Error', 
            response.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      developer.log('Exception while loading dashboard data: $e', name: 'HomeController');
      Get.snackbar(
        'Network Error', 
        'Failed to load dashboard data. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    currentTime.value = TimeUtils.formatTime12Hour(now);
    currentDate.value = TimeUtils.formatDate(now);
  }
  
  void _startTimeUpdater() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {
        _updateCurrentTime();
        _startTimeUpdater();
      }
    });
  }

  // Check In/Out functionality
  Future<void> toggleCheckInOut() async {
    if (isLoading.value) return; // Prevent multiple concurrent calls
    
    try {
      isLoading.value = true;
      
      // Show loading dialog
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      if (!_authService.isLoggedIn || _authService.sessionToken.isEmpty) {
        Get.back(); // Close loading dialog
        developer.log('No valid session found during check-in/out', name: 'HomeController');
        Get.snackbar(
          'Authentication Required', 
          'Please login again',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        Get.offAllNamed('/auth');
        return;
      }

      final sessionToken = _authService.sessionToken;
      final response = await _apiService.toggleCheckInOut(sessionToken);
      
      Get.back(); // Close loading dialog
      
      if (response.success && response.data != null) {
        final result = response.data!;
        
        // Update UI based on the response
        isCheckedIn.value = result.isCheckedIn;
        
        if (result.action == 'check_in') {
          checkInTime.value = result.checkInTime ?? '';
          developer.log('Check-in successful at ${result.checkInTime}', name: 'HomeController');
          Get.snackbar(
            'Check In Successful',
            result.message,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        } else {
          checkOutTime.value = result.checkOutTime ?? '';
          workingHours.value = result.workingHours ?? '00:00:00';
          developer.log('Check-out successful at ${result.checkOutTime}', name: 'HomeController');
          Get.snackbar(
            'Check Out Successful',
            result.message,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: const Icon(Icons.logout, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        }
        
        // Refresh dashboard data to get updated stats
        await _loadDashboardData();
      } else {
        developer.log('Check-in/out failed: ${response.message}', name: 'HomeController');
        Get.snackbar(
          'Error', 
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      developer.log('Exception during check-in/out: $e', name: 'HomeController');
      Get.snackbar(
        'Network Error', 
        'Failed to process check-in/out. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await _loadDashboardData();
  }

  // Bottom navigation
  void onBottomNavTap(int index) {
    selectedBottomIndex.value = index;
    
    switch (index) {
      case 0:
        // Home - already here
        break;
      case 1:
        // Attendance
        Get.toNamed('/attendance');
        break;
      case 2:
        // Reports
        Get.toNamed('/reports');
        break;
      case 3:
        // Profile
        Get.toNamed('/profile');
        break;
    }
  }

  // Request actions
  void onRequestTap() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Request Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildRequestOption(
              icon: Icons.sick,
              title: 'Leave Request',
              subtitle: 'Request time off',
              onTap: () => Get.back(),
            ),
            _buildRequestOption(
              icon: Icons.access_time,
              title: 'Overtime Request',
              subtitle: 'Request overtime work',
              onTap: () => Get.back(),
            ),
            _buildRequestOption(
              icon: Icons.error_outline,
              title: 'Correction Request',
              subtitle: 'Request attendance correction',
              onTap: () => Get.back(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF667eea).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF667eea)),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  // Logout
  Future<void> logout() async {
    try {
      developer.log('Logout initiated', name: 'HomeController');
      await _authService.logout();
      developer.log('Logout successful', name: 'HomeController');
      Get.offAllNamed('/auth');
    } catch (e) {
      developer.log('Logout failed: $e', name: 'HomeController');
      Get.snackbar(
        'Logout Error',
        'Failed to logout properly. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    developer.log('HomeController disposing', name: 'HomeController');
    super.onClose();
  }
}
