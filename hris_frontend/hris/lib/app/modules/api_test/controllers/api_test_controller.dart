import 'package:get/get.dart';
import '../../../data/providers/api_service.dart';
import '../../../data/models/user_model.dart';

class ApiTestController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxBool isLoading = false.obs;
  final RxString statusMessage = 'Ready to test'.obs;
  final RxString healthStatus = ''.obs;
  final RxString loginStatus = ''.obs;
  
  Future<void> testHealthCheck() async {
    isLoading.value = true;
    statusMessage.value = 'Testing health check...';
    
    try {
      final response = await _apiService.healthCheck();
      
      if (response.success) {
        healthStatus.value = '✅ Health Check: ${response.message}';
        statusMessage.value = 'Health check passed!';
      } else {
        healthStatus.value = '❌ Health Check: ${response.message}';
        statusMessage.value = 'Health check failed!';
      }
    } catch (e) {
      healthStatus.value = '❌ Health Check Error: ${e.toString()}';
      statusMessage.value = 'Health check error!';
    }
    
    isLoading.value = false;
  }
  
  Future<void> testLogin() async {
    isLoading.value = true;
    statusMessage.value = 'Testing login...';
    
    try {
      final loginRequest = LoginRequest(
        username: 'apitest@test.com',
        password: 'test123',
      );
      
      final response = await _apiService.login(loginRequest);
      
      if (response.success && response.data != null) {
        loginStatus.value = '✅ Login: ${response.message}\nUser: ${response.data!.name}';
        statusMessage.value = 'Login test passed!';
      } else {
        loginStatus.value = '❌ Login: ${response.message}';
        statusMessage.value = 'Login test failed!';
      }
    } catch (e) {
      loginStatus.value = '❌ Login Error: ${e.toString()}';
      statusMessage.value = 'Login test error!';
    }
    
    isLoading.value = false;
  }
  
  Future<void> runAllTests() async {
    await testHealthCheck();
    await Future.delayed(const Duration(seconds: 1));
    await testLogin();
  }
}
