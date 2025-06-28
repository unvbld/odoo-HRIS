import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class AttendanceSummary extends GetView<HomeController> {
  const AttendanceSummary({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildAttendanceCards(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Attendance for this Month',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'APR',
            style: TextStyle(
              color: Color(0xFF4A90E2),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCards() {
    return Row(
      children: [
        Expanded(
          child: AttendanceCard(
            label: 'Present',
            count: controller.presentDays,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AttendanceCard(
            label: 'Absents',
            count: controller.absentDays,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AttendanceCard(
            label: 'Late In',
            count: controller.lateDays,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String label;
  final RxInt count;
  final Color color;

  const AttendanceCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Text(
          count.value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        )),
      ],
    );
  }
}
