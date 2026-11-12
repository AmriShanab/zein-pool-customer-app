import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.fromBookingStatus(String status) {
    final clean = status.toLowerCase();
    switch (clean) {
      case 'confirmed':
        return const StatusBadge(
          label: 'Confirmed',
          backgroundColor: AppColors.successSurface,
          textColor: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case 'cancelled':
        return const StatusBadge(
          label: 'Cancelled',
          backgroundColor: AppColors.errorSurface,
          textColor: AppColors.error,
          icon: Icons.cancel_rounded,
        );
      case 'completed':
        return const StatusBadge(
          label: 'Completed',
          backgroundColor: AppColors.infoSurface,
          textColor: AppColors.deepSportsBlue,
          icon: Icons.task_alt_rounded,
        );
      default:
        return StatusBadge(
          label: status.toUpperCase(),
          backgroundColor: AppColors.surfaceMuted,
          textColor: AppColors.textSecondary,
        );
    }
  }

  factory StatusBadge.fromPaymentStatus(String status) {
    final clean = status.toLowerCase();
    switch (clean) {
      case 'paid':
        return const StatusBadge(
          label: 'Paid',
          backgroundColor: AppColors.successSurface,
          textColor: AppColors.success,
          icon: Icons.paid_rounded,
        );
      case 'partial':
        return const StatusBadge(
          label: 'Partially Paid',
          backgroundColor: AppColors.warningSurface,
          textColor: AppColors.warning,
          icon: Icons.pie_chart_rounded,
        );
      case 'under_verification':
        return const StatusBadge(
          label: 'Under Verification',
          backgroundColor: AppColors.infoSurface,
          textColor: AppColors.oceanBlue,
          icon: Icons.hourglass_top_rounded,
        );
      case 'unpaid':
      default:
        return const StatusBadge(
          label: 'Payment Pending',
          backgroundColor: AppColors.warningSurface,
          textColor: AppColors.warning,
          icon: Icons.schedule_rounded,
        );
    }
  }

  factory StatusBadge.fromBookingType(String type) {
    final clean = type.toLowerCase();
    switch (clean) {
      case 'hourly':
        return const StatusBadge(
          label: 'Hourly Session',
          backgroundColor: AppColors.surfaceMuted,
          textColor: AppColors.deepSportsBlue,
          icon: Icons.schedule_rounded,
        );
      case 'day':
        return const StatusBadge(
          label: 'Day Session',
          backgroundColor: AppColors.surfaceMuted,
          textColor: AppColors.deepSportsBlue,
          icon: Icons.wb_sunny_rounded,
        );
      case 'night':
        return const StatusBadge(
          label: 'Night Session',
          backgroundColor: AppColors.surfaceMuted,
          textColor: AppColors.midnightNavy,
          icon: Icons.nightlight_round,
        );
      case 'full_day':
        return const StatusBadge(
          label: 'Full-Day Session',
          backgroundColor: AppColors.midnightNavy,
          textColor: Colors.white,
          icon: Icons.stars_rounded,
        );
      default:
        return StatusBadge(
          label: type,
          backgroundColor: AppColors.surfaceMuted,
          textColor: AppColors.textSecondary,
        );
    }
  }

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: textColor.withValues(alpha: 0.22),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
