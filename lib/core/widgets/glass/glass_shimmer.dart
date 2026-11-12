import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// A sleek, shimmering frosted glass skeleton placeholder for loading states.
class GlassShimmer extends StatefulWidget {
  const GlassShimmer({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius,
    this.margin,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  State<GlassShimmer> createState() => _GlassShimmerState();
}

class _GlassShimmerState extends State<GlassShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadii.sm);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1.0, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0xFFFFFFFF),
                Color(0xFFF7ECEF),
                Color(0xFFFFFFFF),
              ],
            ),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
        );
      },
    );
  }
}
