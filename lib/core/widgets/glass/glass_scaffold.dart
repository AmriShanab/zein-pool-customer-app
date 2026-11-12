import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A clean, luminous White & Burgundy luxury background container with soft warm ambient depth.
class GlassScaffoldBackground extends StatelessWidget {
  const GlassScaffoldBackground({
    super.key,
    required this.child,
    this.isDark = false,
  });

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base Clean White & Warm Ivory Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFAF7F8),
                Color(0xFFF7F1F3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Subtle Ambient Burgundy Rose Glow (Top Right)
        Positioned(
          top: -80,
          right: -50,
          child: Container(
            width: size.width * 0.7,
            height: size.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.burgundy.withValues(alpha: 0.055),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),

        // Subtle Ambient Warm Blush Glow (Middle Left)
        Positioned(
          top: size.height * 0.35,
          left: -90,
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.burgundyLight.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),

        // Child Content
        child,
      ],
    );
  }
}
