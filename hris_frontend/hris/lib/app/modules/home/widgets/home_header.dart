import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/app_widgets.dart';

class HomeHeader extends GetView<HomeController> {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          const SizedBox(height: 4),
          _buildLocationText(),
          const SizedBox(height: 20),
          _buildWelcomeText(),
          const SizedBox(height: 20),
          _buildHomeOfficeButtons(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: AppTheme.textWhite, size: 16),
            const SizedBox(width: 4),
            Text(
              'Location',
              style: TextStyle(
                color: AppTheme.textWhite.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Row(
          children: [
            AppBadge(
              label: '3',
              child: const Icon(Icons.notifications, color: AppTheme.textWhite, size: 20),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: controller.logout,
              child: const Icon(Icons.logout, color: AppTheme.textWhite, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationText() {
    return Obx(() => Text(
      controller.userLocation.value,
      style: const TextStyle(
        color: AppTheme.textWhite,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ));
  }

  Widget _buildWelcomeText() {
    return Obx(() => Text(
      'Welcome, ${controller.userName.value}',
      style: const TextStyle(
        color: AppTheme.textWhite,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ));
  }

  Widget _buildHomeOfficeButtons() {
    return Row(
      children: [
        Expanded(child: _buildLocationButton('Home', Icons.home, true)),
        const SizedBox(width: 12),
        Expanded(child: _buildLocationButton('Office', Icons.business, false)),
      ],
    );
  }

  Widget _buildLocationButton(String label, IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
