import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, danger, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.height = 50.0,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.height = 50.0,
  }) : variant = AppButtonVariant.primary;

  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.height = 50.0,
  }) : variant = AppButtonVariant.outline;

  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.height = 50.0,
  }) : variant = AppButtonVariant.danger;

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final bool isFullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;
    Gradient? gradient;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = Colors.white;
        if (isEnabled) {
          gradient = AppColors.primaryGradient;
        }
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.surfaceMuted;
        foregroundColor = AppColors.textPrimary;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? AppColors.primary : AppColors.textMuted;
        borderSide = BorderSide(
          color: isEnabled ? AppColors.primary : AppColors.border,
          width: 1.5,
        );
        break;
      case AppButtonVariant.danger:
        backgroundColor = isEnabled ? AppColors.error : AppColors.errorSurface;
        foregroundColor = isEnabled ? Colors.white : AppColors.error;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.textPrimary;
        break;
    }

    final buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else ...[
          if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.sm)],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    Widget child;
    if (gradient != null && isEnabled) {
      child = Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyanAqua.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
            ...AppShadows.subtle,
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadii.md),
            splashColor: Colors.white.withValues(alpha: 0.25),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: buttonContent,
            ),
          ),
        ),
      );
    } else {
      child = Container(
        height: height,
        decoration: BoxDecoration(
          color: variant == AppButtonVariant.outline
              ? Colors.white.withValues(alpha: 0.6)
              : backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: borderSide != BorderSide.none
              ? Border.fromBorderSide(borderSide)
              : null,
          boxShadow: variant == AppButtonVariant.outline && isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
            splashColor: AppColors.primary.withValues(alpha: 0.12),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: buttonContent,
            ),
          ),
        ),
      );
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}
