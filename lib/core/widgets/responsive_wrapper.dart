// Responsive Wrapper - Constrains content width on large screens
import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// A widget that constrains content width and centers it on large screens.
/// 
/// This ensures content doesn't stretch infinitely on desktop/web views,
/// following Material 3 guidelines for Large Screens.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// Extension for easy responsive checks
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  
  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.desktop;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;
  
  /// Returns a value based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}

/// Responsive GridView delegate that adapts columns based on screen width
class ResponsiveGridDelegate extends SliverGridDelegateWithMaxCrossAxisExtent {
  ResponsiveGridDelegate({
    required super.maxCrossAxisExtent,
    super.mainAxisSpacing = 12,
    super.crossAxisSpacing = 12,
    super.childAspectRatio = 1.5,
  });
}
