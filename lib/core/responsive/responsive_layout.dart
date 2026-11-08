import 'package:flutter/material.dart';

/// Breakpoint constants and helper utilities for Responsive & Adaptive design.
/// Following standard Material Design 3 guidelines:
/// - Compact / Mobile (< 850px)
/// - Medium / Tablet (850px - 1199px)
/// - Expanded / Desktop (>= 1200px)
class ResponsiveBreakpoints {
  static const double mobileMax = 849;
  static const double tabletMin = 850;
  static const double tabletMax = 1199;
  static const double desktopMin = 1200;

  static const double maxContentWidth = 1140;
}

/// Helper class for responsive checking based on BuildContext
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// True if screen width < 850px (Phones and compact views)
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.tabletMin;

  /// True if screen width is between 850px and 1199px (Tablets / Laptops)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= ResponsiveBreakpoints.tabletMin &&
        width < ResponsiveBreakpoints.desktopMin;
  }

  /// True if screen width >= 1200px (Desktops / Wide Screens)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.desktopMin;

  /// True if screen is Tablet or Desktop (>= 850px, suitable for web sidebars)
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.tabletMin;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktopMin) {
          return desktop;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.tabletMin) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A wrapper widget that constrains content width on wide screens
/// so that it doesn't stretch unnaturally on large desktop/web monitors.
class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
