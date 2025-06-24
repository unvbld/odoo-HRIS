import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/api_test_controller.dart';

class ApiTestView extends GetView<ApiTestController> {
  const ApiTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backend Connection Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                      controller.statusMessage.value,
                      style: TextStyle(
                        color: controller.statusMessage.value.contains('passed')
                            ? Colors.green
                            : controller.statusMessage.value.contains('failed')
                                ? Colors.red
                                : Colors.grey[600],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Test Results
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => controller.healthStatus.value.isNotEmpty
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: controller.healthStatus.value.startsWith('✅')
                                            ? Colors.green[50]
                                            : Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: controller.healthStatus.value.startsWith('✅')
                                              ? Colors.green[200]!
                                              : Colors.red[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        controller.healthStatus.value,
                                        style: TextStyle(
                                          color: controller.healthStatus.value.startsWith('✅')
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                        ),
                                      ),
                                    )
                                  : const SizedBox()),
                              
                              Obx(() => controller.loginStatus.value.isNotEmpty
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: controller.loginStatus.value.startsWith('✅')
                                            ? Colors.green[50]
                                            : Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: controller.loginStatus.value.startsWith('✅')
                                              ? Colors.green[200]!
                                              : Colors.red[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        controller.loginStatus.value,
                                        style: TextStyle(
                                          color: controller.loginStatus.value.startsWith('✅')
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                        ),
                                      ),
                                    )
                                  : const SizedBox()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.testHealthCheck,
                    icon: const Icon(Icons.health_and_safety),
                    label: const Text('Health Check'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.testLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Test Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.runAllTests,
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  controller.isLoading.value ? 'Running Tests...' : 'Run All Tests',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Make sure Docker containers are running\n'
                      '2. Backend should be accessible at localhost:8069\n'
                      '3. Test user should exist: apitest@test.com / test123',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
