import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/facility_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/facility_image_view.dart';
import '../../../../core/widgets/glass/glass_shimmer.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';
import '../../domain/entities/customer_booking.dart';
import '../providers/customer_bookings_provider.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final bookingsAsync = ref.watch(customerBookingsProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.midnightNavy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      size: 30,
                      color: AppColors.electricCyan,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Sign In to View Your Games',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: AppColors.midnightNavy,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Access your upcoming turf and pool reservations, passes, and booking history.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(
                    text: 'Sign In / Register',
                    onPressed: () => context.push('/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A. Distinctive Editorial Page Header (Zero overflow risk)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                14,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESERVATION HUB',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.oceanBlue,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Your games',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.midnightNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // B. Clean Modern Underline Filter Bar (No oversized pill)
                  TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 2.5,
                    indicatorColor: AppColors.deepSportsBlue,
                    dividerColor: AppColors.borderSubtle,
                    labelColor: AppColors.midnightNavy,
                    unselectedLabelColor: AppColors.mutedSteel,
                    labelStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                    tabs: const [
                      Tab(text: 'Upcoming', height: 38),
                      Tab(text: 'Past & Cancelled', height: 38),
                    ],
                  ),
                ],
              ),
            ),

            // C. Bookings List Body
            Expanded(
              child: bookingsAsync.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: 3,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: GlassShimmer(
                      height: 145,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                error: (err, _) => ErrorState(
                  message: err.toString().replaceFirst(
                    RegExp(r'^[^:]*:\s*'),
                    '',
                  ),
                  onRetry: () =>
                      ref.read(customerBookingsProvider.notifier).refresh(),
                ),
                data: (bookings) {
                  final now = DateTime.now();
                  final upcoming = bookings
                      .where((b) => b.isConfirmed && b.endAt.isAfter(now))
                      .toList();
                  final pastOrCancelled = bookings
                      .where((b) => b.isCancelled || b.endAt.isBefore(now))
                      .toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingsList(
                        context,
                        ref,
                        upcoming,
                        emptyTitle: 'Your next game starts here.',
                        emptyMessage:
                            'You have no upcoming turf or pool reservations scheduled yet.',
                      ),
                      _buildBookingsList(
                        context,
                        ref,
                        pastOrCancelled,
                        emptyTitle: 'No past reservations yet.',
                        emptyMessage:
                            'Completed and cancelled bookings will appear here.',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(
    BuildContext context,
    WidgetRef ref,
    List<CustomerBooking> bookings, {
    required String emptyTitle,
    required String emptyMessage,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 220,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const FacilityImageView(
                        assetPath: FacilityAssets.turfGround,
                        isTurf: true,
                        fit: BoxFit.cover,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.midnightNavy.withValues(alpha: 0.45),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.sports_soccer_rounded,
                          size: 38,
                          color: AppColors.electricCyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.midnightNavy,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepSportsBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Explore facilities',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(customerBookingsProvider.notifier).refresh(),
      color: AppColors.deepSportsBlue,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          28,
        ),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BookingCard(booking: booking),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final CustomerBooking booking;

  @override
  Widget build(BuildContext context) {
    final isTurf = booking.serviceName?.toLowerCase().contains('turf') ?? false;
    final displayId = booking.id.length >= 8
        ? booking.id.substring(0, 8).toUpperCase()
        : booking.id.toUpperCase();

    final Color stripeColor = booking.isCancelled
        ? AppColors.error
        : (booking.paymentStatusLabel.toLowerCase() == 'paid'
              ? AppColors.success
              : AppColors.deepSportsBlue);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutral, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/bookings/${booking.id}'),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Vertical Status Accent Stripe
                Container(width: 4, color: stripeColor),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Facility Name, Reference, and Booking Status
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isTurf
                                            ? Icons.sports_soccer_rounded
                                            : Icons.pool_rounded,
                                        size: 13,
                                        color: AppColors.oceanBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '#$displayId · ${booking.bookingType.displayName}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.mutedSteel,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.serviceName ?? 'Facility Session',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.midnightNavy,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge.fromBookingStatus(booking.status),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Row 2: Clean Inline Date & Time Schedule (No nested box)
                        Wrap(
                          spacing: 16,
                          runSpacing: 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13.5,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormatter.formatFullDate(booking.startAt),
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.midnightNavy,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormatter.formatTimeRange(
                                    booking.startAt,
                                    booking.endAt,
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepSportsBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color: AppColors.borderSubtle,
                          ),
                        ),

                        // Row 3: Total Price, Accurate Payment Status & View Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatLkr(
                                        booking.totalAmount,
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.midnightNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge.fromPaymentStatus(
                                      booking.paymentStatusLabel,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View booking',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepSportsBlue,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: AppColors.deepSportsBlue,
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}
