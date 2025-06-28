class AppConstants {
  // Application Info
  static const String appName = 'HRIS Application';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:8069';
  static const String apiPrefix = '/api';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/auth/profile';
  static const String attendanceDashboardEndpoint = '/attendance/dashboard';
  static const String attendanceCheckInEndpoint = '/attendance/checkin';
  static const String attendanceCheckOutEndpoint = '/attendance/checkout';
  
  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String sessionTokenKey = 'session_token';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // Timeout Configuration
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  
  // Date & Time Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';
  
  // Messages
  static const String loginSuccessMessage = 'Login successful';
  static const String loginFailedMessage = 'Login failed';
  static const String registerSuccessMessage = 'Registration successful';
  static const String registerFailedMessage = 'Registration failed';
  static const String logoutSuccessMessage = 'Logout successful';
  static const String networkErrorMessage = 'Network error occurred';
  static const String serverErrorMessage = 'Server error occurred';
  static const String unknownErrorMessage = 'An unknown error occurred';
  static const String sessionExpiredMessage = 'Session expired, please login again';
  static const String noDataMessage = 'No data available';
  static const String loadingMessage = 'Loading...';
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]+$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  
  // File & Image Configuration
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
  
  // Default Values
  static const String defaultUserImage = 'assets/images/default_user.png';
  static const String defaultCompanyLogo = 'assets/images/company_logo.png';
  
  // Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableDarkMode = true;
  static const bool enableMultiLanguage = false;
  
  // Routes
  static const String authRoute = '/auth';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String attendanceRoute = '/attendance';
  static const String reportsRoute = '/reports';
  static const String settingsRoute = '/settings';
  
  // Bottom Navigation Labels
  static const String homeLabel = 'Home';
  static const String attendanceLabel = 'Attendance';
  static const String reportsLabel = 'Reports';
  static const String profileLabel = 'Profile';
  
  // Attendance Status
  static const String checkInStatus = 'checked_in';
  static const String checkOutStatus = 'checked_out';
  static const String absentStatus = 'absent';
  static const String lateStatus = 'late';
  static const String onTimeStatus = 'on_time';
  
  // Working Hours
  static const String defaultWorkStartTime = '09:00';
  static const String defaultWorkEndTime = '17:00';
  static const int defaultWorkHours = 8;
  static const int defaultLunchBreakMinutes = 60;
  
  // Notification Types
  static const String reminderNotification = 'reminder';
  static const String attendanceNotification = 'attendance';
  static const String systemNotification = 'system';
  
  // Permissions
  static const String cameraPermission = 'camera';
  static const String locationPermission = 'location';
  static const String storagePermission = 'storage';
  static const String notificationPermission = 'notification';
}
