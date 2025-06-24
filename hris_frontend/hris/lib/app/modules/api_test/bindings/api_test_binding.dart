import 'package:get/get.dart';
import '../controllers/api_test_controller.dart';

class ApiTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiTestController>(
      () => ApiTestController(),
    );
  }
}
