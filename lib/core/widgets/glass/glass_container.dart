import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// A modern, high-performance Glassmorphism container with translucent frosted glass,
/// subtle border reflections, and soft ambient depth.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.blur = AppGlassBlur.standard,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderGradient,
    this.borderWidth = 1.2,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
    this.gradient,
    this.alignment,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double blur;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? borderGradient;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;
  final Gradient? gradient;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadii.lg);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBgColor = isDark
        ? AppColors.darkGlassSurface
        : AppColors.glassSurface;

    final defaultBorderColor = isDark
        ? AppColors.darkGlassBorder
        : AppColors.glassBorder;

    final defaultShadow = isDark ? AppShadows.darkGlassGlow : AppShadows.glass;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? defaultBgColor) : null,
        gradient: gradient,
        borderRadius: effectiveRadius,
        border: borderGradient == null
            ? Border.all(
                color: borderColor ?? defaultBorderColor,
                width: borderWidth,
              )
            : null,
      ),
      child: child,
    );

    // Apply BackdropFilter blur if blur > 0
    if (blur > 0) {
      content = ClipRRect(
        borderRadius: effectiveRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: effectiveRadius,
        clipBehavior: clipBehavior,
        child: content,
      );
    }

    // Outer Container for margin, shadows and gradient borders
    if (borderGradient != null) {
      content = Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: borderGradient,
          boxShadow: boxShadow ?? defaultShadow,
        ),
        padding: EdgeInsets.all(borderWidth),
        child: content,
      );
    } else {
      content = Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: boxShadow ?? defaultShadow,
        ),
        child: content,
      );
    }

    return content;
  }
}

/// A touch-interactive glass card with smooth scale/opacity micro-interactions
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.borderRadius,
    this.blur = AppGlassBlur.standard,
    this.backgroundColor,
    this.borderColor,
    this.borderGradient,
    this.isDarkTheme = false,
    this.glowColor,
    this.elevation = 1.0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? borderGradient;
  final bool isDarkTheme;
  final Color? glowColor;
  final double elevation;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.985).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(AppRadii.lg);

    final card = GlassContainer(
      margin: widget.margin,
      padding: EdgeInsets.zero,
      blur: widget.blur,
      borderRadius: effectiveRadius,
      backgroundColor: widget.backgroundColor,
      borderColor: widget.borderColor,
      borderGradient: widget.borderGradient,
      boxShadow: widget.glowColor != null
          ? [
              BoxShadow(
                color: widget.glowColor!.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              ...AppShadows.glass,
            ]
          : AppShadows.glass,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: effectiveRadius,
          splashColor: AppColors.cyanAqua.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(scale: _scaleAnimation, child: card),
    );
  }
}
