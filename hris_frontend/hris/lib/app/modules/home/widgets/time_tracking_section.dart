import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class TimeTrackingSection extends GetView<HomeController> {
  const TimeTrackingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TimeCard(
            icon: Icons.login,
            label: 'Check In',
            time: controller.checkInTime,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TimeCard(
            icon: Icons.logout,
            label: 'Check Out',
            time: controller.checkOutTime,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TimeCard(
            icon: Icons.access_time,
            label: 'Working Hrs',
            time: controller.workingHours,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class TimeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxString time;
  final Color color;

  const TimeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
            time.value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )),
        ],
      ),
    );
  }
}
