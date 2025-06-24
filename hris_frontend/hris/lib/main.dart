import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/data/providers/api_service.dart';
import 'app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await initServices();
  
  runApp(
    GetMaterialApp(
      title: "HRIS Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ),
  );
}

Future<void> initServices() async {
  // Initialize API Service
  Get.put(ApiService(), permanent: true);
  
  // Initialize Auth Service
  await Get.putAsync(() => AuthService().onInit().then((_) => AuthService()), permanent: true);
}
