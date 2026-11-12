import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../services/domain/entities/service_availability.dart';
import '../../../services/presentation/providers/availability_provider.dart';

class AvailabilityMonthCalendarModal extends ConsumerStatefulWidget {
  const AvailabilityMonthCalendarModal({
    super.key,
    required this.serviceId,
    required this.initialDate,
    required this.onDateSelected,
  });

  final String serviceId;
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  static Future<DateTime?> show({
    required BuildContext context,
    required String serviceId,
    required DateTime initialDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvailabilityMonthCalendarModal(
        serviceId: serviceId,
        initialDate: initialDate,
        onDateSelected: (date) => Navigator.pop(ctx, date),
      ),
    );
  }

  @override
  ConsumerState<AvailabilityMonthCalendarModal> createState() =>
      _AvailabilityMonthCalendarModalState();
}

class _AvailabilityMonthCalendarModalState
    extends ConsumerState<AvailabilityMonthCalendarModal> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(widget.initialDate);
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  void _previousMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final prev = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    if (!prev.isBefore(currentMonth)) {
      setState(() => _displayedMonth = prev);
    }
  }

  void _nextMonth() {
    final now = DateTime.now();
    final maxMonth = DateTime(now.year, now.month + 3, 1);
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    if (next.isBefore(maxMonth) || DateUtils.isSameMonth(next, maxMonth)) {
      setState(() => _displayedMonth = next);
    }
  }

  void _jumpToToday() {
    final today = DateUtils.dateOnly(DateTime.now());
    setState(() {
      _selectedDate = today;
      _displayedMonth = DateTime(today.year, today.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthStr = DateFormat('yyyy-MM').format(_displayedMonth);
    final query = MonthAvailabilityQuery(
      serviceId: widget.serviceId,
      month: monthStr,
    );
    final monthAsync = ref.watch(monthAvailabilityProvider(query));

    final today = DateUtils.dateOnly(DateTime.now());
    final currentMonthStart = DateTime(today.year, today.month, 1);
    final canGoPrev = _displayedMonth.isAfter(currentMonthStart);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder, width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepNavy.withValues(alpha: 0.15),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Frosted Handle Bar
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Header Row: Title & Today Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Availability Calendar',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: _jumpToToday,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Month Navigation Strip
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  blur: 10,
                  backgroundColor: AppColors.glassSurfaceSubtle,
                  borderColor: AppColors.glassBorderSubtle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: canGoPrev ? _previousMonth : null,
                        color: AppColors.textPrimary,
                        disabledColor: AppColors.textMuted.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_displayedMonth),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: _nextMonth,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Weekday Headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((
                    day,
                  ) {
                    return SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Calendar Days Grid
                monthAsync.when(
                  loading: () => const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (err, _) => const SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        'Could not load month availability.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  data: (monthAvail) => _buildMonthGrid(monthAvail, today),
                ),
                const SizedBox(height: AppSpacing.md),

                // Legend matching Vendor App & Glass Aesthetics
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  blur: 8,
                  backgroundColor: AppColors.glassSurfaceSubtle,
                  borderColor: AppColors.glassBorderSubtle,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.md,
                    runSpacing: 4,
                    children: [
                      _buildLegendItem(const Color(0xFF0E9F6E), 'Available'),
                      _buildLegendItem(
                        const Color(0xFFFF8A00),
                        'Partial Booking',
                      ),
                      _buildLegendItem(const Color(0xFFE02424), 'Booked'),
                      _buildLegendItem(const Color(0xFF6B7280), 'Blocked'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Selected Date Summary & Confirm
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Date',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            DateFormat('d MMM yyyy (EEEE)')
                                .format(_selectedDate),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppButton.primary(
                      text: 'Select Date',
                      onPressed: () => widget.onDateSelected(_selectedDate),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid(MonthAvailability monthAvail, DateTime today) {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    final leadingBlanks = firstDayOfMonth.weekday % 7;

    final cells = <Widget>[];

    // Leading empty cells
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox(width: 36, height: 38));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isSelected = DateUtils.isSameDay(date, _selectedDate);
      final isPast = date.isBefore(today);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final dayStatus = monthAvail.statusForDate(dateKey);

      cells.add(
        _buildDayCell(
          day: day,
          date: date,
          isSelected: isSelected,
          isPast: isPast,
          status: dayStatus,
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.spaceAround,
      runSpacing: 4,
      children: cells,
    );
  }

  Widget _buildDayCell({
    required int day,
    required DateTime date,
    required bool isSelected,
    required bool isPast,
    required DayAvailabilityStatus status,
  }) {
    Color? dotColor;
    if (!isPast) {
      switch (status) {
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

    return InkWell(
      onTap: isPast ? null : () => setState(() => _selectedDate = date),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.cyanAqua, width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isPast
                    ? AppColors.textMuted.withValues(alpha: 0.4)
                    : (isSelected ? Colors.white : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 2),
            if (dotColor != null)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
}
