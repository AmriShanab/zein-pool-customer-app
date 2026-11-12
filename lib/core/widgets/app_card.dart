import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.hasShadow = true,
    this.blur = AppGlassBlur.standard,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool hasShadow;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.lg);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultColor =
        color ?? (isDark ? AppColors.darkGlassSurface : AppColors.glassSurface);

    final defaultBorder =
        borderColor ??
        (isDark ? AppColors.darkGlassBorder : AppColors.glassBorder);

    final defaultShadow = isDark ? AppShadows.darkGlassGlow : AppShadows.glass;

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: defaultColor,
        borderRadius: radius,
        border: Border.all(color: defaultBorder, width: 1.2),
      ),
      child: child,
    );

    if (blur > 0) {
      cardContent = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: cardContent,
        ),
      );
    } else {
      cardContent = ClipRRect(borderRadius: radius, child: cardContent);
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: hasShadow ? defaultShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.cyanAqua.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          child: cardContent,
        ),
      ),
    );
  }
}
