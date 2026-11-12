import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/facility_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/facility_image_view.dart';
import '../../../../core/widgets/glass/glass_shimmer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bookings/presentation/providers/booking_checkout_provider.dart';
import '../../domain/entities/pool_service.dart';
import '../providers/services_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedQuickDateIndex = 0;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesListProvider);
    final authState = ref.watch(authStateProvider);

    final rawName = authState.customer?.name.trim() ?? '';
    final firstName = rawName.isNotEmpty
        ? rawName.split(' ').first.toUpperCase()
        : '';
    final greetingKicker = firstName.isNotEmpty
        ? 'GOOD TO SEE YOU, $firstName'
        : "ZEIN'S — THE GAME STARTS HERE";

    final today = DateTime.now();
    final quickDates = List.generate(
      6,
      (i) => DateTime(today.year, today.month, today.day + i),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // A. Compact Editorial Brand Header
          SliverAppBar(
            pinned: true,
            floating: false,
            toolbarHeight: 68,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Compact Brand Mark
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.midnightNavy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        FacilityAssets.logo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.sports_soccer_rounded,
                              size: 20,
                              color: AppColors.electricCyan,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Personalized Greeting & Headline
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greetingKicker,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              color: AppColors.oceanBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const Text(
                            'Book your next session.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: AppColors.midnightNavy,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Compact Notification Icon
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.midnightNavy,
                        size: 22,
                      ),
                      tooltip: 'Notifications',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No new notifications at this time.',
                              style: TextStyle(fontFamily: 'Nunito'),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          servicesAsync.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.lg),
                    child: GlassShimmer(
                      height: 240,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                  childCount: 2,
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: ErrorState(
                message: error.toString().replaceFirst(
                  RegExp(r'^[^:]*:\s*'),
                  '',
                ),
                onRetry: () => ref.refresh(servicesListProvider),
              ),
            ),
            data: (services) {
              final onlineServices = services
                  .where((s) => s.isActive && s.allowOnlineBooking)
                  .toList();

              if (onlineServices.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    title: 'No Facilities Found',
                    message:
                        'No facilities are currently open for online booking.',
                  ),
                );
              }

              final primaryTurfOrService = onlineServices.firstWhere(
                (s) => s.isTurf,
                orElse: () => onlineServices.first,
              );

              return SliverList(
                delegate: SliverChildListDelegate([
                  // B. Cinematic Full-Bleed Editorial Hero Section (No white border)
                  _CinematicSportsHero(
                    onlineCount: onlineServices.length,
                    onBookAction: () {
                      final chosenDate = quickDates[_selectedQuickDateIndex];
                      ref
                          .read(bookingCheckoutProvider.notifier)
                          .setDate(chosenDate);
                      context.push('/services/${primaryTurfOrService.id}/book');
                    },
                  ),

                  // C. Quick Booking Date Strip
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      20,
                      AppSpacing.lg,
                      8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'QUICK SCHEDULE',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.mutedSteel,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, d MMM').format(
                            quickDates[_selectedQuickDateIndex],
                          ),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepSportsBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 62,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: quickDates.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final date = quickDates[index];
                        final isSelected = index == _selectedQuickDateIndex;
                        final dayLabel = index == 0
                            ? 'TODAY'
                            : index == 1
                            ? 'TMRW'
                            : DateFormat('EEE').format(date).toUpperCase();

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setState(() => _selectedQuickDateIndex = index);
                            ref
                                .read(bookingCheckoutProvider.notifier)
                                .setDate(date);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.midnightNavy
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.electricCyan
                                    : AppColors.borderNeutral,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayLabel,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? AppColors.electricCyan
                                        : AppColors.mutedSteel,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.midnightNavy,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // D. Venue Discovery Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      24,
                      AppSpacing.lg,
                      12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Select your ground',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.midnightNavy,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        Text(
                          '${onlineServices.length} ${onlineServices.length == 1 ? 'FACILITY' : 'FACILITIES'}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.oceanBlue,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Featured First Venue (Editorial Spotlight)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: _EditorialFeaturedVenue(
                      service: onlineServices.first,
                    ),
                  ),

                  // Remaining Venues (Architectural Split Layout — No Repetitive Cards)
                  if (onlineServices.length > 1) ...[
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        'MORE BOOKABLE GROUNDS',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.mutedSteel,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...onlineServices.skip(1).map(
                      (service) => Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          14,
                        ),
                        child: _ArchitecturalVenueRow(service: service),
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CinematicSportsHero extends StatelessWidget {
  const _CinematicSportsHero({
    required this.onlineCount,
    required this.onBookAction,
  });

  final int onlineCount;
  final VoidCallback onBookAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      constraints: const BoxConstraints(minHeight: 215),
      decoration: BoxDecoration(
        color: AppColors.midnightNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Genuine Sports Turf Photograph
          const Positioned.fill(
            child: FacilityImageView(
              assetPath: FacilityAssets.turfGround,
              isTurf: true,
              fit: BoxFit.cover,
            ),
          ),
          // Midnight Navy Editorial Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.midnightNavy.withValues(alpha: 0.94),
                    AppColors.midnightNavy.withValues(alpha: 0.78),
                    AppColors.deepSportsBlue.withValues(alpha: 0.45),
                  ],
                  stops: const [0.0, 0.58, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Brand Label + Live Availability Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 2,
                          color: AppColors.electricCyan,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'MATCH & TURF CLUB',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.electricCyan,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.electricCyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$onlineCount ONLINE',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Editorial Headline & CTA
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your game.\nYour ground.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Instant slot reservations with real-time availability.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.80),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: onBookAction,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.electricCyan,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Book Your Next Session',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.midnightNavy,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: AppColors.midnightNavy,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialFeaturedVenue extends StatelessWidget {
  const _EditorialFeaturedVenue({required this.service});

  final PoolService service;

  @override
  Widget build(BuildContext context) {
    final hasHourly = service.hourlyOption != null;
    final displayPrice = hasHourly && service.isTurf
        ? service.hourlyOption!.price
        : service.startingPrice;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderNeutral, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/services/${service.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Edge-to-Edge Featured Image with Overlaid Editorial Title & Price
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FacilityImageView(
                    assetPath: service.assetImage,
                    isTurf: service.isTurf,
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.midnightNavy.withValues(alpha: 0.88),
                        ],
                        stops: const [0.35, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Top-Left Category Tag
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.midnightNavy.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service.isTurf ? 'SPORTS TURF' : 'SWIMMING POOL',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.electricCyan,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  // Bottom-Overlaid Title & Rate
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                service.defaultDescription,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hasHourly && service.isTurf
                                  ? 'HOURLY'
                                  : 'STARTS AT',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.electricCyan,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatLkr(displayPrice),
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Architectural Bottom Action Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Online slots open',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () =>
                            context.push('/services/${service.id}'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.midnightNavy,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: const Text(
                          'Details',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () =>
                            context.push('/services/${service.id}/book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepSportsBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchitecturalVenueRow extends StatelessWidget {
  const _ArchitecturalVenueRow({required this.service});

  final PoolService service;

  @override
  Widget build(BuildContext context) {
    final hasHourly = service.hourlyOption != null;
    final displayPrice = hasHourly && service.isTurf
        ? service.hourlyOption!.price
        : service.startingPrice;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutral, width: 1.0),
      ),
      child: InkWell(
        onTap: () => context.push('/services/${service.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact Square Facility Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: FacilityImageView(
                    assetPath: service.assetImage,
                    isTurf: service.isTurf,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Structured Editorial Info & Actions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          service.isTurf ? 'SPORTS TURF' : 'SWIMMING POOL',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.oceanBlue,
                            letterSpacing: 0.7,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatLkr(displayPrice),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.midnightNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.midnightNavy,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.defaultDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => context.push('/services/${service.id}'),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Text(
                              'Details',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () =>
                              context.push('/services/${service.id}/book'),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.midnightNavy,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
