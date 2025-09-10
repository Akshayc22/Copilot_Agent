import 'package:flutter/material.dart';
import 'constants.dart';

// Responsive utility class for AI Copilot Agent
class ResponsiveUtils {
  // Check if the current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  // Check if the current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.tabletBreakpoint;
  }

  // Check if the current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;
  }

  // Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppConstants.defaultPadding);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppConstants.largePadding);
    } else {
      return const EdgeInsets.symmetric(
        horizontal: AppConstants.largePadding * 2,
        vertical: AppConstants.largePadding,
      );
    }
  }

  // Get responsive column count for grids
  static int getResponsiveColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  // Get responsive width percentage
  static double getResponsiveWidth(
    BuildContext context,
    double mobileWidth, {
    double? tabletWidth,
    double? desktopWidth,
  }) {
    if (isMobile(context)) {
      return mobileWidth;
    } else if (isTablet(context)) {
      return tabletWidth ?? mobileWidth * 0.8;
    } else {
      return desktopWidth ?? mobileWidth * 0.6;
    }
  }

  // Get screen type as enum
  static ScreenType getScreenType(BuildContext context) {
    if (isMobile(context)) {
      return ScreenType.mobile;
    } else if (isTablet(context)) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  // Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppConstants.smallPadding);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppConstants.defaultPadding);
    } else {
      return const EdgeInsets.all(AppConstants.largePadding);
    }
  }
}

enum ScreenType { mobile, tablet, desktop }

// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveUtils.getScreenType(context));
  }
}
