import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../data/models/user_model.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
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
  
  // Attendance data
  final RxInt presentDays = 13.obs;
  final RxInt absentDays = 2.obs;
  final RxInt lateDays = 4.obs;
  
  // Getters
  User? get currentUser => _authService.currentUser;
  
  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
    _updateCurrentTime();
    _loadAttendanceData();
    
    // Update time every second
    _startTimeUpdater();
  }
  
  void _initializeUserData() {
    // Initialize user-specific data
    userName.value = currentUser?.name ?? 'User';
    userLocation.value = 'Your Office Location'; // This could be fetched from user preferences or API
  }
  
  void _updateCurrentTime() {
    final now = DateTime.now();
    currentTime.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
    currentDate.value = '${_getMonthName(now.month)} ${now.day}, ${now.year}';
  }
  
  void _startTimeUpdater() {
    Future.delayed(const Duration(seconds: 1), () {
      _updateCurrentTime();
      _startTimeUpdater();
    });
  }
  
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  void _loadAttendanceData() {
    // Load attendance data from storage or API
    // For now, using mock data
    checkInTime.value = '10:00 AM';
    checkOutTime.value = '06:30 PM';
    workingHours.value = '08:30:00';
  }
  
  // Check In/Out functionality
  void toggleCheckInOut() {
    if (isCheckedIn.value) {
      _checkOut();
    } else {
      _checkIn();
    }
  }
  
  void _checkIn() {
    final now = DateTime.now();
    checkInTime.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
    isCheckedIn.value = true;
    
    Get.snackbar(
      'Check In',
      'You have successfully checked in at ${checkInTime.value}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
  
  void _checkOut() {
    final now = DateTime.now();
    checkOutTime.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
    isCheckedIn.value = false;
    
    // Calculate working hours (mock calculation)
    workingHours.value = '08:30:00';
    
    Get.snackbar(
      'Check Out',
      'You have successfully checked out at ${checkOutTime.value}',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.logout, color: Colors.white),
    );
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
          color: const Color(0xFF667eea).withOpacity(0.1),
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
      await _authService.logout();
      Get.offAllNamed('/auth');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
