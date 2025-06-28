import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import 'app/routes/app_pages.dart';
import 'app/data/providers/api_service.dart';
import 'app/services/auth_service.dart';
import 'app/config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await initServices();
  
  runApp(
    GetMaterialApp(
      title: "HRIS Application",
      initialRoute: Routes.AUTH, // Always start with AUTH, let AuthService handle routing
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Use centralized theme
    ),
  );
}

Future<void> initServices() async {
  developer.log('Initializing services...', name: 'Main');
  
  // Initialize API Service
  Get.put(ApiService(), permanent: true);
  developer.log('API Service initialized', name: 'Main');
  
  // Initialize Auth Service
  final authService = AuthService();
  Get.put(authService, permanent: true);
  
  // Load initial data
  await authService.loadInitialData();
  developer.log('Auth Service initialized', name: 'Main');
}
