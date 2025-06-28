import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class RequestButton extends GetView<HomeController> {
  const RequestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.onRequestTap,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Request'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4A90E2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
