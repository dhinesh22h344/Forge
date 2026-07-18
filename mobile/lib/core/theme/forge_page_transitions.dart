import 'package:flutter/material.dart';

/// The single change point for app-wide navigation motion: every
/// [GoRoute]/[MaterialPageRoute] push and pop goes through
/// [ThemeData.pageTransitionsTheme], so swapping the platform-default slide
/// for this fade + gentle rise gives the whole app one consistent feel
/// without touching individual routes.
class ForgePageTransitionsBuilder extends PageTransitionsBuilder {
  const ForgePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: incoming,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(incoming),
        // The screen being pushed away from settles back slightly and dims,
        // rather than sitting fully opaque under the incoming screen.
        child: FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.88).animate(outgoing),
          child: child,
        ),
      ),
    );
  }
}

const forgePageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: ForgePageTransitionsBuilder(),
    TargetPlatform.iOS: ForgePageTransitionsBuilder(),
    TargetPlatform.macOS: ForgePageTransitionsBuilder(),
    TargetPlatform.linux: ForgePageTransitionsBuilder(),
    TargetPlatform.windows: ForgePageTransitionsBuilder(),
    TargetPlatform.fuchsia: ForgePageTransitionsBuilder(),
  },
);
