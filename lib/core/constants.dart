// Core constants for the AI Copilot Flutter Agent
class AppConstants {
  // App Information
  static const String appName = 'AI Copilot Agent';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.example.com';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Screen Breakpoints for Responsive Design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'Network connection failed. Please check your internet connection.';
  static const String timeoutError = 'Request timed out. Please try again.';
}
