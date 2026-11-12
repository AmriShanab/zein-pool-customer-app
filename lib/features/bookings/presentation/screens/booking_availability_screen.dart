import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/facility_image_view.dart';
import '../../../../core/widgets/glass/glass_app_bar.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';

import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/pool_service.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/service_availability.dart';
import 'package:zain_pool_customer_app/features/services/presentation/providers/availability_provider.dart';
import 'package:zain_pool_customer_app/features/services/presentation/providers/services_provider.dart';

import '../providers/booking_checkout_provider.dart';
import '../widgets/availability_month_calendar_modal.dart';

class BookingAvailabilityScreen extends ConsumerStatefulWidget {
  const BookingAvailabilityScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<BookingAvailabilityScreen> createState() =>
      _BookingAvailabilityScreenState();
}

class _BookingAvailabilityScreenState
    extends ConsumerState<BookingAvailabilityScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    Future.microtask(() async {
      try {
        final service = await ref.read(
          singleServiceProvider(widget.serviceId).future,
        );
        if (mounted) {
          ref.read(bookingCheckoutProvider.notifier).initForService(service);
        }
      } catch (_) {}
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    ref.read(bookingCheckoutProvider.notifier).setDate(date);
    final query = AvailabilityQuery(
      serviceId: widget.serviceId,
      date: DateFormatter.toIsoDate(date),
    );
    ref.invalidate(availabilityProvider(query));
  }

  Future<void> _pickCustomDate() async {
    final picked = await AvailabilityMonthCalendarModal.show(
      context: context,
      serviceId: widget.serviceId,
      initialDate: _selectedDate,
    );
    if (picked != null) {
      _onDateSelected(picked);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final serviceAsync = ref.watch(singleServiceProvider(widget.serviceId));
    final draft = ref.watch(bookingCheckoutProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GlassAppBar(title: 'Reserve Facility'),
      body: GlassScaffoldBackground(
        child: serviceAsync.when(
          loading: () =>
              const AppLoadingIndicator(message: 'Checking availability...'),
          error: (err, _) => ErrorState(
            message: err.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), ''),
            onRetry: () => ref.refresh(singleServiceProvider(widget.serviceId)),
          ),
          data: (service) {
            final query = AvailabilityQuery(
              serviceId: service.id,
              date: DateFormatter.toIsoDate(_selectedDate),
            );
            final availabilityAsync = ref.watch(availabilityProvider(query));

            final monthStr = DateFormat('yyyy-MM').format(_selectedDate);
            final monthQuery = MonthAvailabilityQuery(
              serviceId: service.id,
              month: monthStr,
            );
            final monthAsync = ref.watch(monthAvailabilityProvider(monthQuery));

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(availabilityProvider(query));
                      ref.invalidate(monthAvailabilityProvider(monthQuery));
                      await ref.read(availabilityProvider(query).future);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Facility Header Card (Frosted Luxury Glass)
                          _buildFacilityCard(service),
                          const SizedBox(height: AppSpacing.lg),

                          // 2. Date Selection Header & Strip
                          _buildDateSelectionSection(
                            draft,
                            monthAsync.valueOrNull,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // 3. Booking Type Selection Cards
                          availabilityAsync.when(
                            loading: () => _buildBookingTypeSelector(
                              service,
                              draft,
                              availability: null,
                            ),
                            error: (_, _) => _buildBookingTypeSelector(
                              service,
                              draft,
                              availability: null,
                            ),
                            data: (avail) => _buildBookingTypeSelector(
                              service,
                              draft,
                              availability: avail,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // 4. Time Slots or Session Details
                          availabilityAsync.when(
                            loading: () => GlassContainer(
                              padding: const EdgeInsets.all(AppSpacing.xxl),
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              blur: 14,
                              backgroundColor: AppColors.glassSurface,
                              borderColor: AppColors.glassBorder,
                              child: const Column(
                                children: [
                                  AppLoadingIndicator(
                                    message: 'Loading live availability...',
                                  ),
                                ],
                              ),
                            ),
                            error: (err, _) => ErrorState(
                              message: err.toString().replaceFirst(
                                RegExp(r'^[^:]*:\s*'),
                                '',
                              ),
                              onRetry: () =>
                                  ref.refresh(availabilityProvider(query)),
                            ),
                            data: (availability) {
                              if (draft.bookingType == BookingTypeEnum.hourly) {
                                return _buildHourlySlotsSection(
                                  availability,
                                  draft,
                                );
                              } else {
                                return _buildNonHourlySection(
                                  availability,
                                  draft,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ),

                // 6. Authoritative Sticky Bottom Summary Bar
                _buildBottomSummaryBar(draft, availabilityAsync.valueOrNull),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- A. Photographic Facility Introduction Banner (No small boxed card) ---
  Widget _buildFacilityCard(PoolService service) {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.midnightNavy,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
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
                  AppColors.midnightNavy.withValues(alpha: 0.92),
                  AppColors.midnightNavy.withValues(alpha: 0.45),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            service.isTurf
                                ? Icons.sports_soccer_rounded
                                : Icons.pool_rounded,
                            size: 12,
                            color: AppColors.electricCyan,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            service.isTurf ? 'SPORTS TURF' : 'SWIMMING POOL',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.electricCyan,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.midnightNavy.withValues(
                              alpha: 0.85,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.electricCyan.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Text(
                            'from ${CurrencyFormatter.formatLkr(service.startingPrice)}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.electricCyan,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            service.isTurf
                                ? 'Zein Turf Ground, Sammanthurai'
                                : "Zein's Luxury Pool, Sammanthurai",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  // --- Date Selection Strip ---
  Widget _buildDateSelectionSection(
    BookingDraftState draft,
    MonthAvailability? monthAvail,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateFormatter.formatFullDate(_selectedDate),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: _pickCustomDate,
              icon: const Icon(
                Icons.calendar_month_rounded,
                size: 15,
                color: AppColors.burgundy,
              ),
              label: const Text(
                'Calendar',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.burgundy,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.burgundySoft,
                side: const BorderSide(color: AppColors.burgundyMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 88,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isToday = index == 0;
              final isRestrictedForFullDay =
                  isToday && draft.bookingType == BookingTypeEnum.fullDay;

              final isoDate = DateFormatter.toIsoDate(date);
              final dayStatus = monthAvail?.statusForDate(isoDate);

              Color? dotColor;
              if (dayStatus != null) {
                switch (dayStatus) {
                  case DayAvailabilityStatus.available:
                    dotColor = const Color(0xFF0E9F6E);
                    break;
                  case DayAvailabilityStatus.partial:
                    dotColor = const Color(0xFFFF8A00);
                    break;
                  case DayAvailabilityStatus.booked:
                    dotColor = const Color(0xFFE02424);
                    break;
                  case DayAvailabilityStatus.blocked:
                    dotColor = const Color(0xFF6B7280);
                    break;
                  case DayAvailabilityStatus.past:
                    dotColor = null;
                    break;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: InkWell(
                  onTap: () => _onDateSelected(date),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.burgundy
                            : (isRestrictedForFullDay
                                  ? AppColors.warning.withValues(alpha: 0.6)
                                  : AppColors.border),
                        width: isSelected ? 1.8 : 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.burgundy.withValues(
                                  alpha: 0.28,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: AppColors.burgundy.withValues(
                                  alpha: 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday
                              ? 'TODAY'
                              : index == 1
                              ? 'TMRW'
                              : _weekdayAbbr(date.weekday),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : (isRestrictedForFullDay
                                      ? AppColors.warning
                                      : AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _monthAbbr(date.month),
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.textMuted,
                              ),
                            ),
                            if (dotColor != null) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 5.5,
                                height: 5.5,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (isRestrictedForFullDay &&
                            !isSelected &&
                            dotColor == null) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- C. Session Type Selection Panels (Sleek Architectural Strips) ---
  Widget _buildBookingTypeSelector(
    PoolService service,
    BookingDraftState draft, {
    ServiceAvailability? availability,
  }) {
    final enabledOptions = service.bookingOptions
        .where((opt) => opt.isEnabled)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Session Type',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.midnightNavy,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Column(
          children: enabledOptions.map((opt) {
            final isSelected = draft.bookingType == opt.type;

            OptionAvailability? optAvail;
            if (availability != null) {
              try {
                optAvail = availability.options.firstWhere(
                  (o) => o.bookingType == opt.type,
                );
              } catch (_) {}
            }

            final bool isAdvanceRestricted =
                opt.type == BookingTypeEnum.fullDay &&
                _isToday(_selectedDate) &&
                (optAvail?.unavailableReason == 'advance_required' ||
                    optAvail?.isAvailable == false);

            final bool isConflict =
                optAvail != null &&
                !optAvail.isAvailable &&
                !isAdvanceRestricted;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  ref
                      .read(bookingCheckoutProvider.notifier)
                      .setBookingType(opt.type);

                  if (isAdvanceRestricted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Full-day reservations require at least 1-day advance booking. Please pick tomorrow or later.',
                          style: TextStyle(fontFamily: 'Nunito'),
                        ),
                        backgroundColor: AppColors.warning,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.midnightNavy
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.electricCyan
                          : (isAdvanceRestricted
                                ? AppColors.warning.withValues(alpha: 0.6)
                                : AppColors.borderNeutral),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        size: 19,
                        color: isSelected
                            ? AppColors.electricCyan
                            : AppColors.mutedSteel,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    opt.type.displayName,
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.midnightNavy,
                                    ),
                                  ),
                                ),
                                if (isAdvanceRestricted) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warningSurface,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Advance Req',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ] else if (isConflict) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorSurface,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Reserved',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              opt.timeRange,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.75)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatLkr(opt.price),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? AppColors.electricCyan
                              : AppColors.deepSportsBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- D. Available Hourly Slots Section (Clean Open Canvas, No Heavy Box) ---
  Widget _buildHourlySlotsSection(
    ServiceAvailability availability,
    BookingDraftState draft,
  ) {
    final slots = availability.slots;

    if (slots.isEmpty) {
      return const EmptyState(
        title: 'No Hourly Slots Available',
        message:
            'No hourly slots are available for the selected date. Please choose another date or session type.',
      );
    }

    final availableCount = availability.availableHourlySlots.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Available Hourly Slots',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.midnightNavy,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3.5,
              ),
              decoration: BoxDecoration(
                color: availableCount > 0
                    ? AppColors.successSurface
                    : AppColors.bookedSlot,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$availableCount Available',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: availableCount > 0
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap one or multiple consecutive slots to reserve your session.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Subtle Status Legend
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: 4,
          children: [
            _buildLegendItem(
              AppColors.oceanBlue,
              'Available',
              isOutline: true,
            ),
            _buildLegendItem(
              AppColors.midnightNavy,
              'Selected',
              isSolid: true,
            ),
            _buildLegendItem(AppColors.mutedSteel, 'Booked'),
            _buildLegendItem(
              AppColors.mutedSteel.withValues(alpha: 0.45),
              'Past',
            ),
          ],
        ),

        // Selected Range Banner (when 1 or more slots are chosen)
        if (draft.selectedSlots.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.midnightNavy,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.electricCyan.withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.electricCyan,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${draft.selectedTimeRange} • ${draft.selectedSlotCount} ${draft.selectedSlotCount == 1 ? 'Slot' : 'Slots'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    ref.read(bookingCheckoutProvider.notifier).clearSlot();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.electricCyan,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),

        // Slots Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 500 ? 4 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (context, index) {
                final slot = slots[index];
                final isSelected = draft.isSlotSelected(slot);
                return _buildHourlySlotCard(slot, isSelected, slots);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label, {
    bool isOutline = false,
    bool isSolid = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOutline ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: isOutline ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlySlotCard(
    AvailableSlot slot,
    bool isSelected,
    List<AvailableSlot> allSlots,
  ) {
    if (!slot.isAvailable || slot.isBooked || slot.isPast) {
      final isPast = slot.isPast || slot.unavailableReason == 'past';
      final isBooked = slot.isBooked || slot.unavailableReason == 'booked';

      // Semantic rules:
      // - Past: subdued slate/grey, non-interactive (NOT bright red)
      // - Booked: muted grey with unmistakable disabled state
      // - Other Unavailable: muted red treatment
      final bgColor = isPast
          ? AppColors.pastSlot
          : (isBooked ? AppColors.bookedSlot : AppColors.unavailableSlot);
      final borderColor = isPast || isBooked
          ? AppColors.borderSubtle
          : AppColors.error.withValues(alpha: 0.30);
      final textColor = isPast
          ? AppColors.mutedSteel.withValues(alpha: 0.75)
          : (isBooked ? AppColors.textSecondary : AppColors.error);

      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                slot.timeRange,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  decoration: isPast ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isPast ? 'Past' : 'Booked',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        final message = ref
            .read(bookingCheckoutProvider.notifier)
            .toggleSlot(slot, allSlots: allSlots);
        if (message != null && mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: const TextStyle(fontFamily: 'Nunito'),
                ),
                backgroundColor: AppColors.deepSportsBlue,
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepSportsBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.electricCyan
                : AppColors.oceanBlue.withValues(alpha: 0.35),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 11,
                      color: AppColors.electricCyan,
                    ),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    slot.timeRange,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : AppColors.midnightNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyFormatter.formatLkr(slot.price),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? AppColors.electricCyan
                      : AppColors.oceanBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Non-Hourly Session Section ---
  Widget _buildNonHourlySection(
    ServiceAvailability availability,
    BookingDraftState draft,
  ) {
    if (availability.options.isEmpty) {
      return const SizedBox.shrink();
    }

    OptionAvailability? optAvail;
    try {
      optAvail = availability.options.firstWhere(
        (o) => o.bookingType == draft.bookingType,
      );
    } catch (_) {
      optAvail = availability.options.isNotEmpty
          ? availability.options.first
          : null;
    }

    if (optAvail == null) {
      return const SizedBox.shrink();
    }

    final isAdvanceRestricted =
        draft.bookingType == BookingTypeEnum.fullDay &&
        _isToday(_selectedDate) &&
        (optAvail.unavailableReason == 'advance_required' ||
            !optAvail.isAvailable);

    final isConflict = !optAvail.isAvailable && !isAdvanceRestricted;

    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      blur: 16,
      backgroundColor: AppColors.glassSurface,
      borderColor: isAdvanceRestricted
          ? AppColors.warning.withValues(alpha: 0.5)
          : (isConflict
                ? AppColors.error.withValues(alpha: 0.5)
                : AppColors.glassBorder),
      boxShadow: [
        BoxShadow(
          color: AppColors.deepNavy.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isAdvanceRestricted
                      ? AppColors.warningSurface
                      : (isConflict
                            ? AppColors.errorSurface
                            : AppColors.successSurface),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAdvanceRestricted
                      ? Icons.warning_amber_rounded
                      : (isConflict
                            ? Icons.event_busy_rounded
                            : Icons.verified_rounded),
                  color: isAdvanceRestricted
                      ? AppColors.warning
                      : (isConflict ? AppColors.error : AppColors.success),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAdvanceRestricted
                          ? 'Advance Booking Required'
                          : (isConflict
                                ? 'Session Already Reserved'
                                : 'Session Available'),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isAdvanceRestricted
                            ? AppColors.warning
                            : (isConflict
                                  ? AppColors.error
                                  : AppColors.success),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Timing: ${optAvail.timeRange} (${DateFormatter.formatFullDate(_selectedDate)})',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isAdvanceRestricted
                ? 'Full-day reservations require at least 1-day advance notice so that staff and maintenance can prepare the facility. Same-day full-day reservations are prohibited.'
                : (isConflict
                      ? (optAvail.unavailableMessage ??
                            'This session has already been reserved for another guest. Please choose a different date.')
                      : 'Your group enjoys exclusive and private access to the entire facility during this reservation window.'),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          if (isAdvanceRestricted) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _onDateSelected(
                        DateTime.now().add(const Duration(days: 1)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book for Tomorrow',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(bookingCheckoutProvider.notifier)
                          .setBookingType(BookingTypeEnum.hourly);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Switch to Hourly',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- Bottom Summary Bar (Pure White & Burgundy Bar) ---
  Widget _buildBottomSummaryBar(
    BookingDraftState draft,
    ServiceAvailability? availability,
  ) {
    OptionAvailability? currentOptionAvail;
    if (availability != null) {
      try {
        currentOptionAvail = availability.options.firstWhere(
          (o) => o.bookingType == draft.bookingType,
        );
      } catch (_) {}
    }

    final bool isAdvanceRestricted =
        draft.bookingType == BookingTypeEnum.fullDay &&
        _isToday(_selectedDate) &&
        (currentOptionAvail?.unavailableReason == 'advance_required' ||
            currentOptionAvail?.isAvailable == false);

    final bool isSessionBlocked =
        draft.bookingType != BookingTypeEnum.hourly &&
        currentOptionAvail != null &&
        !currentOptionAvail.isAvailable;

    final String sessionLabel = draft.bookingType == BookingTypeEnum.hourly
        ? (draft.selectedSlots.isNotEmpty
              ? draft.selectedSlotsLabel
              : 'Select a slot')
        : draft.bookingType.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.midnightNavy.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1.2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Flexible(
                        child: Text(
                          sessionLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.formatLkr(draft.totalPrice),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepSportsBlue,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton.primary(
                text: 'Review & Checkout',
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (draft.bookingType == BookingTypeEnum.hourly) {
                    if (draft.selectedSlots.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select an available hourly time slot above to proceed.',
                            style: TextStyle(fontFamily: 'Nunito'),
                          ),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }

                    final hasInvalidSlot = draft.selectedSlots.any(
                      (s) => !s.isAvailable || s.isBooked || s.isPast,
                    );
                    if (hasInvalidSlot) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'One or more selected slots are no longer available. Please select again.',
                            style: TextStyle(fontFamily: 'Nunito'),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      ref
                          .read(bookingCheckoutProvider.notifier)
                          .clearSlot();
                      return;
                    }
                  }

                  if (isAdvanceRestricted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Full-day reservations must be booked at least 1 day in advance. Please choose tomorrow or later.',
                          style: TextStyle(fontFamily: 'Nunito'),
                        ),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                    return;
                  }

                  if (isSessionBlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          currentOptionAvail?.unavailableMessage ??
                              'This session is unavailable on the selected date.',
                          style: const TextStyle(fontFamily: 'Nunito'),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  // Pre-flight check: strictly validate availability before proceeding to checkout
                  final isAvailable = await ref
                      .read(bookingCheckoutProvider.notifier)
                      .validateSlotAvailability();

                  if (!isAvailable) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This slot has just been booked. Please select another available time.',
                          style: TextStyle(fontFamily: 'Nunito'),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;
                  context.push('/services/${widget.serviceId}/checkout');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
  String _weekdayAbbr(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MON';
      case DateTime.tuesday:
        return 'TUE';
      case DateTime.wednesday:
        return 'WED';
      case DateTime.thursday:
        return 'THU';
      case DateTime.friday:
        return 'FRI';
      case DateTime.saturday:
        return 'SAT';
      case DateTime.sunday:
        return 'SUN';
      default:
        return '';
    }
  }

  String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
