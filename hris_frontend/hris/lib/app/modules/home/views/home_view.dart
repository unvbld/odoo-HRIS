import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/app_widgets.dart';
import '../widgets/home_header.dart';
import '../widgets/shift_section.dart';
import '../widgets/time_tracking_section.dart';
import '../widgets/attendance_summary.dart';
import '../widgets/request_button.dart';
import '../widgets/home_bottom_navigation.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: AppGradientBackground(
        colors: AppTheme.primaryGradient,
        child: SafeArea(
          child: Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: RefreshIndicator(
                    onRefresh: controller.refreshDashboard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const ShiftSection(),
                          const SizedBox(height: 24),
                          const TimeTrackingSection(),
                          const SizedBox(height: 24),
                          const AttendanceSummary(),
                          const SizedBox(height: 24),
                          const RequestButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HomeBottomNavigation(),
    );
  }
}
