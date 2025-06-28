import 'package:flutter/material.dart';
import '../config/app_theme.dart';

// Custom Button Components
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final double? width;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    Widget button;
    
    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.textWhite,
            padding: padding ?? AppTheme.mediumPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.smallRadius,
            ),
            elevation: 2,
          ),
          child: child,
        );
        break;
      case ButtonType.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: const BorderSide(color: AppTheme.primaryColor),
            padding: padding ?? AppTheme.mediumPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.smallRadius,
            ),
          ),
          child: child,
        );
        break;
      case ButtonType.success:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            foregroundColor: AppTheme.textWhite,
            padding: padding ?? AppTheme.mediumPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.smallRadius,
            ),
            elevation: 2,
          ),
          child: child,
        );
        break;
      case ButtonType.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            foregroundColor: AppTheme.textWhite,
            padding: padding ?? AppTheme.mediumPadding,
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.smallRadius,
            ),
            elevation: 2,
          ),
          child: child,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: child,
        );
        break;
    }

    return SizedBox(
      width: width,
      child: button,
    );
  }
}

enum ButtonType { primary, secondary, success, danger, text }

// Custom Card Component
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? AppTheme.smallPadding,
      child: Material(
        color: backgroundColor ?? AppTheme.cardBackground,
        borderRadius: borderRadius ?? AppTheme.mediumRadius,
        elevation: elevation ?? 2,
        shadowColor: AppTheme.shadowLight,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppTheme.mediumRadius,
          child: Padding(
            padding: padding ?? AppTheme.mediumPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

// Custom Input Field Component
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final int? maxLines;
  final EdgeInsets? margin;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppTheme.mediumSpacing),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        keyboardType: keyboardType,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon),
                  onPressed: onSuffixTap,
                )
              : null,
          filled: true,
          fillColor: AppTheme.backgroundWhite,
          border: OutlineInputBorder(
            borderRadius: AppTheme.smallRadius,
            borderSide: const BorderSide(color: AppTheme.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTheme.smallRadius,
            borderSide: const BorderSide(color: AppTheme.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTheme.smallRadius,
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppTheme.smallRadius,
            borderSide: const BorderSide(color: AppTheme.errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppTheme.smallRadius,
            borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
          ),
        ),
      ),
    );
  }
}

// Custom App Bar Component
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor ?? AppTheme.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      foregroundColor: foregroundColor ?? AppTheme.textWhite,
      elevation: elevation,
      actions: actions,
      leading: leading,
      iconTheme: IconThemeData(
        color: foregroundColor ?? AppTheme.textWhite,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Loading Indicator Component
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryColor,
            ),
            strokeWidth: 2,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppTheme.smallSpacing),
          Text(
            message!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

// Empty State Component
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppTheme.largePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: AppTheme.mediumSpacing),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.smallSpacing),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppTheme.largeSpacing),
              AppButton(
                text: actionText!,
                onPressed: onActionPressed,
                type: ButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Error Message Component
class AppErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const AppErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppTheme.errorColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: AppTheme.smallSpacing),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppTheme.smallSpacing),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

// Success Message Component
class AppSuccessMessage extends StatelessWidget {
  final String message;
  final IconData? icon;

  const AppSuccessMessage({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppTheme.successColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.check_circle_outline,
            color: AppTheme.successColor,
            size: 20,
          ),
          const SizedBox(width: AppTheme.smallSpacing),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.successColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Gradient Background Component
class AppGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
          colors: colors ?? AppTheme.primaryGradient,
        ),
      ),
      child: child,
    );
  }
}
