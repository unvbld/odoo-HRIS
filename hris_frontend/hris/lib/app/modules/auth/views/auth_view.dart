import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/app_widgets.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        colors: AppTheme.primaryGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: AppCard(
                padding: EdgeInsets.all(32.0),
                margin: EdgeInsets.zero,
                elevation: 8,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo/Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: AppTheme.mediumRadius,
                        ),
                        child: const Icon(
                          Icons.business_center,
                          color: AppTheme.textWhite,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      
                      // Title
                      Text(
                        controller.isLoginMode.value ? 'Welcome Back' : 'Create Account',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      
                      Text(
                        controller.isLoginMode.value 
                            ? 'Sign in to your HRIS account'
                            : 'Join our HRIS platform',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 32.0),
                      
                      // Error Message
                      if (controller.errorMessage.value.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: AppErrorMessage(
                            message: controller.errorMessage.value,
                          ),
                        ),
                      
                      // Form
                      if (controller.isLoginMode.value) 
                        _buildLoginForm()
                      else 
                        _buildRegisterForm(),
                      
                      SizedBox(height: 24.0),
                      
                      // Submit Button
                      AppButton(
                        text: controller.isLoginMode.value ? 'Sign In' : 'Create Account',
                        onPressed: controller.isLoginMode.value 
                            ? controller.login 
                            : controller.register,
                        isLoading: controller.isLoading,
                        width: double.infinity,
                        type: ButtonType.primary,
                      ),
                      
                      SizedBox(height: 32.0),
                      
                      // Toggle Mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.isLoginMode.value
                                ? "Don't have an account? "
                                : "Already have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.toggleAuthMode,
                            child: Text(
                              controller.isLoginMode.value ? 'Sign Up' : 'Sign In',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.0),
                      
                      // API Test Button
                      TextButton.icon(
                        onPressed: () => Get.toNamed('/api-test'),
                        icon: const Icon(Icons.api, size: 16),
                        label: const Text('Test API Connection'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          // Email/Username Field
          AppTextField(
            label: 'Username or Email',
            hint: 'Enter your username or email',
            controller: controller.emailController,
            prefixIcon: Icons.account_circle_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username or email is required';
              }
              return null;
            },
          ),
          
          // Password Field
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: controller.passwordController,
            prefixIcon: Icons.lock_outline,
            suffixIcon: controller.obscurePassword.value 
                ? Icons.visibility_off 
                : Icons.visibility,
            onSuffixTap: controller.togglePasswordVisibility,
            obscureText: controller.obscurePassword.value,
            validator: controller.validatePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: controller.registerFormKey,
      child: Column(
        children: [
          // Name Field
          AppTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: controller.nameController,
            prefixIcon: Icons.person_outline,
            validator: controller.validateName,
          ),
          
          // Username Field
          AppTextField(
            label: 'Username',
            hint: 'Choose a username',
            controller: controller.usernameController,
            prefixIcon: Icons.account_circle_outlined,
            validator: controller.validateUsername,
          ),
          
          // Email Field
          AppTextField(
            label: 'Email',
            hint: 'Enter your email address',
            controller: controller.emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
          ),
          
          // Password Field
          AppTextField(
            label: 'Password',
            hint: 'Create a password',
            controller: controller.passwordController,
            prefixIcon: Icons.lock_outline,
            suffixIcon: controller.obscurePassword.value 
                ? Icons.visibility_off 
                : Icons.visibility,
            onSuffixTap: controller.togglePasswordVisibility,
            obscureText: controller.obscurePassword.value,
            validator: controller.validatePassword,
          ),
          
          // Confirm Password Field
          AppTextField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            controller: controller.confirmPasswordController,
            prefixIcon: Icons.lock_outline,
            suffixIcon: controller.obscureConfirmPassword.value 
                ? Icons.visibility_off 
                : Icons.visibility,
            onSuffixTap: controller.toggleConfirmPasswordVisibility,
            obscureText: controller.obscureConfirmPassword.value,
            validator: controller.validateConfirmPassword,
          ),
        ],
      ),
    );
  }
}
