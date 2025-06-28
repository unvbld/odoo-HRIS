import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Primary Colors - Modern gradient palette
  static const Color primaryColor = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryLight = Color(0xFF8B5CF6); // Violet-500
  
  // Secondary Colors - Complementary warm tones
  static const Color secondaryColor = Color(0xFFEC4899); // Pink-500
  static const Color secondaryDark = Color(0xFFDB2777); // Pink-600
  static const Color secondaryLight = Color(0xFFF472B6); // Pink-400
  
  // Accent Colors
  static const Color accentColor = Color(0xFF10B981); // Emerald-500
  static const Color accentLight = Color(0xFF34D399); // Emerald-400
  
  // Gradient Collections
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1), // Indigo-500
    Color(0xFF8B5CF6), // Violet-500
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFFEC4899), // Pink-500
    Color(0xFFF97316), // Orange-500
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF10B981), // Emerald-500
    Color(0xFF059669), // Emerald-600
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFF59E0B), // Amber-500
    Color(0xFFEAB308), // Yellow-500
  ];
  
  // Neutral Colors - Enhanced gray palette
  static const Color textPrimary = Color(0xFF111827); // Gray-900
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray-400
  static const Color textMuted = Color(0xFFD1D5DB); // Gray-300
  static const Color textWhite = Colors.white;
  
  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFAFAFA); // Gray-50
  static const Color backgroundSecondary = Color(0xFFF9FAFB); // Gray-50
  static const Color backgroundTertiary = Color(0xFFF3F4F6); // Gray-100
  static const Color backgroundWhite = Colors.white;
  
  // Status Colors - Modern vibrant palette
  static const Color successColor = Color(0xFF10B981); // Emerald-500
  static const Color successLight = Color(0xFFD1FAE5); // Emerald-100
  static const Color warningColor = Color(0xFFF59E0B); // Amber-500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber-100
  static const Color errorColor = Color(0xFFEF4444); // Red-500
  static const Color errorLight = Color(0xFFFEE2E2); // Red-100
  static const Color infoColor = Color(0xFF3B82F6); // Blue-500
  static const Color infoLight = Color(0xFFDBEAFE); // Blue-100
  
  // Surface Colors
  static const Color surfacePrimary = Colors.white;
  static const Color surfaceSecondary = Color(0xFFF8FAFC); // Slate-50
  static const Color surfaceTertiary = Color(0xFFF1F5F9); // Slate-100
  
  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB); // Gray-200
  static const Color borderMedium = Color(0xFFD1D5DB); // Gray-300
  static const Color borderDark = Color(0xFF9CA3AF); // Gray-400
  
  // Shadow Colors
  static const Color shadowLight = Color(0x0A000000); // 4% black
  static const Color shadowMedium = Color(0x14000000); // 8% black
  static const Color shadowDark = Color(0x1F000000); // 12% black
  
  // Main Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundPrimary,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfacePrimary,
        error: errorColor,
        onPrimary: textWhite,
        onSecondary: textWhite,
        onSurface: textPrimary,
        onError: textWhite,
        brightness: Brightness.light,
        tertiary: accentColor,
        onTertiary: textWhite,
        surfaceVariant: surfaceSecondary,
        onSurfaceVariant: textSecondary,
        outline: borderMedium,
        outlineVariant: borderLight,
      ),
      
      // App Bar Theme - Modern with gradient effect
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: const TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: textWhite,
          size: 24,
        ),
        toolbarHeight: 64,
      ),
      
      // Enhanced Card Theme
      cardTheme: CardThemeData(
        color: surfacePrimary,
        elevation: 4,
        shadowColor: shadowMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
      ),
      // Enhanced Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textWhite,
          elevation: 2,
          shadowColor: shadowMedium,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),
      
      // Enhanced Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: textTertiary),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      // Enhanced Text Theme
      textTheme: const TextTheme(
        // Display styles - for hero titles
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        
        // Headline styles - for section headers
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        
        // Title styles - for card titles and labels
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        
        // Body styles - for content text
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          height: 1.3,
        ),
        
        // Label styles - for form labels and captions
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundWhite,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Additional theme properties
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
  
  // Helper method to create MaterialColor
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    final int r = (color.r * 255.0).round() & 0xff;
    final int g = (color.g * 255.0).round() & 0xff;
    final int b = (color.b * 255.0).round() & 0xff;

    Map<int, Color> swatch = {};
    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(
      (color.r * 255.0).round() << 16 |
      (color.g * 255.0).round() << 8 |
      (color.b * 255.0).round() << 0 |
      0xFF000000,
      swatch,
    );
  }
  
  // Enhanced Shadow Styles
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: shadowLight,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: shadowMedium,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get largeShadow => [
    BoxShadow(
      color: shadowDark,
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: shadowMedium,
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  // Gradient Styles
  static LinearGradient get primaryLinearGradient => const LinearGradient(
    colors: primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get secondaryLinearGradient => const LinearGradient(
    colors: secondaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get successLinearGradient => const LinearGradient(
    colors: successGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get warningLinearGradient => const LinearGradient(
    colors: warningGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Border Radius Styles
  static BorderRadius get extraSmallRadius => BorderRadius.circular(4);
  static BorderRadius get smallRadius => BorderRadius.circular(8);
  static BorderRadius get mediumRadius => BorderRadius.circular(12);
  static BorderRadius get largeRadius => BorderRadius.circular(16);
  static BorderRadius get extraLargeRadius => BorderRadius.circular(24);
  static BorderRadius get circularRadius => BorderRadius.circular(999);
  
  // Spacing Constants
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing64 = 64;
  
  // Padding Styles
  static const EdgeInsets paddingXS = EdgeInsets.all(4);
  static const EdgeInsets paddingS = EdgeInsets.all(8);
  static const EdgeInsets paddingM = EdgeInsets.all(16);
  static const EdgeInsets paddingL = EdgeInsets.all(24);
  static const EdgeInsets paddingXL = EdgeInsets.all(32);
  
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: 24);
  
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: 24);
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Common UI Constants
  static const double iconSizeS = 16;
  static const double iconSizeM = 24;
  static const double iconSizeL = 32;
  static const double iconSizeXL = 48;
  
  static const double buttonHeightS = 32;
  static const double buttonHeightM = 48;
  static const double buttonHeightL = 56;
  
  static const double inputHeight = 56;
  static const double appBarHeight = 64;
  static const double bottomNavHeight = 80;

  static var mediumPadding;
}

// Custom App Colors Extension
extension AppColorsExtension on BuildContext {
  AppTheme get theme => AppTheme();
}
