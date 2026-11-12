import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/facility_image_view.dart';
import '../../../../core/widgets/glass/glass_app_bar.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/booking_option.dart';
import '../providers/services_provider.dart';

class ServiceDetailsScreen extends ConsumerWidget {
  const ServiceDetailsScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(singleServiceProvider(serviceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GlassAppBar(title: 'Facility Details'),
      body: GlassScaffoldBackground(
        child: serviceAsync.when(
          loading: () =>
              const AppLoadingIndicator(message: 'Loading facility details...'),
          error: (err, _) => ErrorState(
            message: err.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), ''),
            onRetry: () => ref.refresh(singleServiceProvider(serviceId)),
          ),
          data: (service) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Framed Hero Showcase Card (Pure White & Burgundy)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.burgundy.withValues(alpha: 0.06),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              height: 230,
                              width: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  FacilityImageView(
                                    assetPath: service.assetImage,
                                    isTurf: service.isTurf,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  // Top-Left White & Burgundy Category Badge
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.94,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.pill,
                                        ),
                                        border: Border.all(
                                          color: AppColors.burgundyMuted,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            service.isTurf
                                                ? Icons.sports_soccer_rounded
                                                : Icons.pool_rounded,
                                            size: 13,
                                            color: AppColors.burgundy,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            service.isTurf
                                                ? 'SPORTS TURF'
                                                : 'SWIMMING POOL',
                                            style: const TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.burgundy,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Top-Right Burgundy Private Badge
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.burgundy,
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.pill,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified_user_rounded,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '100% Private',
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  color: AppColors.textPrimary,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 15,
                                    color: AppColors.burgundy,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      service.isTurf
                                          ? 'Zein Turf Ground, Sammanthurai'
                                          : "Zein's Luxury Pool, Sammanthurai",
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Divider(
                                height: 1,
                                color: AppColors.borderSubtle,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: AppColors.burgundySoft,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline_rounded,
                                      color: AppColors.burgundy,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'About this Facility',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                service.defaultDescription,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 13.5,
                                  color: AppColors.textSecondary,
                                  height: 1.55,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 2. Available Booking Packages
                  const Text(
                    'Booking Packages & Rates',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  ...service.bookingOptions
                      .where((opt) => opt.isEnabled)
                      .map((opt) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm + 2,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.burgundy.withValues(
                                    alpha: 0.04,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                StatusBadge.fromBookingType(
                                  opt.type.wireValue,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.type.displayName,
                                        style: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Hours: ${opt.timeWindowDisplay}${opt.slotDurationMinutes != null ? ' • ${opt.slotDurationMinutes} min slots' : ''}',
                                        style: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatLkr(opt.price),
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.burgundy,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                  const SizedBox(height: AppSpacing.md),

                  // 3. Included Amenities Section
                  const Text(
                    'Included Amenities',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.burgundy.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: service.amenities.map((amenity) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.burgundySoft,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.burgundy,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  amenity,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 110),
                ],
              ),
            );
          },
        ),
      ),
      bottomSheet: serviceAsync.whenOrNull(
        data: (service) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
              top: BorderSide(
                color: AppColors.border,
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.burgundyDark.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.isTurf && service.hourlyOption != null
                          ? 'STARTING RATE'
                          : 'STARTING FROM',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          CurrencyFormatter.formatLkr(
                            service.isTurf && service.hourlyOption != null
                                ? service.hourlyOption!.price
                                : service.startingPrice,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: AppColors.burgundy,
                            letterSpacing: -0.4,
                          ),
                        ),
                        if (service.isTurf && service.hourlyOption != null)
                          const Text(
                            ' / hr',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: AppButton.primary(
                    text: 'Select Date & Book',
                    icon: const Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        context.push('/services/${service.id}/book'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
