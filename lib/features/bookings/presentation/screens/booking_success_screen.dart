import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final displayId = bookingId.length >= 8
        ? bookingId.substring(0, 8).toUpperCase()
        : bookingId.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Green Confirmed Booking Shield (#DDF7E8 + #15803D)
                Center(
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.confirmedBooking,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.4),
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 62,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                const Center(
                  child: Text(
                    'Reservation Confirmed!',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Your private session at Zein\'s Pool has been successfully reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Pure White & Burgundy Boarding Pass Card
                GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  borderRadius: BorderRadius.circular(24),
                  blur: 0,
                  backgroundColor: AppColors.surface,
                  borderColor: AppColors.border,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.burgundy.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  child: Column(
                    children: [
                      const Text(
                        'BOOKING REFERENCE',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '#$displayId',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepNavy,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const Divider(height: 28, color: AppColors.borderSubtle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.burgundySoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sms_outlined,
                              size: 15,
                              color: AppColors.burgundy,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text(
                            'Confirmation SMS queued to your phone',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                AppButton.primary(
                  text: 'View Booking Details',
                  icon: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => context.go('/bookings/$bookingId'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.outline(
                  text: 'Back to Home',
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
