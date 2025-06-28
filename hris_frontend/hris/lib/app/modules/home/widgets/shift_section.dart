import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class ShiftSection extends GetView<HomeController> {
  const ShiftSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildShiftInfo(),
          _buildCheckButton(),
        ],
      ),
    );
  }

  Widget _buildShiftInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GENERAL SHIFT',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Obx(() => Text(
          controller.currentTime.value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        )),
      ],
    );
  }

  Widget _buildCheckButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.toggleCheckInOut,
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.isCheckedIn.value ? Colors.orange : const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: controller.isLoading.value
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              controller.isCheckedIn.value ? 'Check Out' : 'Check In',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
    ));
  }
}
