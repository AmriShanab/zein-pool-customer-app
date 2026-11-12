import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass/glass_app_bar.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../resort_info/presentation/providers/resort_config_provider.dart';
import '../../../services/domain/entities/booking_option.dart';
import '../providers/customer_bookings_provider.dart';

final singleBookingProvider = FutureProvider.family((ref, String id) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBooking(id);
});

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(singleBookingProvider(bookingId));

    return GlassScaffoldBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const GlassAppBar(title: 'Reservation Pass'),
        body: bookingAsync.when(
          loading: () =>
              const AppLoadingIndicator(message: 'Loading booking details...'),
          error: (err, _) => ErrorState(
            message: err.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), ''),
            onRetry: () => ref.refresh(singleBookingProvider(bookingId)),
          ),
          data: (booking) {
            final isConfirmed = booking.isConfirmed;
            final shortRef = booking.id.length >= 8
                ? booking.id.substring(0, 8).toUpperCase()
                : booking.id.toUpperCase();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Luxury White & Burgundy Boarding Pass / Ticket Header Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.burgundy.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top Burgundy Accent Header Strip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(22),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'VERIFIED RESERVATION PASS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                              StatusBadge.fromBookingStatus(booking.status),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PASS REFERENCE',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textMuted,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '#$shortRef',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.burgundy,
                                      letterSpacing: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: AppColors.burgundySoft,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.burgundyMuted,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.qr_code_rounded,
                                  color: AppColors.burgundy,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Perforated ticket divider styling
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: List.generate(
                              28,
                              (index) => Expanded(
                                child: Container(
                                  height: 1.5,
                                  color: index % 2 == 0
                                      ? AppColors.burgundyMuted
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Segmented Triple Stats
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDarkMiniInfo(
                                Icons.calendar_today_rounded,
                                'DATE',
                                DateFormatter.formatShortDate(booking.startAt),
                              ),
                              Container(
                                height: 30,
                                width: 1,
                                color: AppColors.borderSubtle,
                              ),
                              _buildDarkMiniInfo(
                                Icons.access_time_rounded,
                                'TIME',
                                DateFormatter.formatTime(booking.startAt),
                              ),
                              Container(
                                height: 30,
                                width: 1,
                                color: AppColors.borderSubtle,
                              ),
                              _buildDarkMiniInfo(
                                Icons.timelapse_rounded,
                                'DURATION',
                                DateFormatter.formatDuration(
                                  booking.endAt.difference(booking.startAt),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 2. Frosted Session Details Glass Card
                  GlassContainer(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.villa_outlined,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Text(
                              'Session Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildDetailRow(
                          'Service Name',
                          booking.serviceName ?? 'Facility Session',
                        ),
                        _buildDetailRow(
                          'Booking Package',
                          booking.bookingType.displayName,
                        ),
                        _buildDetailRow(
                          'Scheduled Date',
                          DateFormatter.formatFullDate(booking.startAt),
                        ),
                        _buildDetailRow(
                          'Slot Window',
                          DateFormatter.formatTimeRange(
                            booking.startAt,
                            booking.endAt,
                          ),
                        ),
                        _buildDetailRow(
                          'Duration',
                          DateFormatter.formatDuration(
                            booking.endAt.difference(booking.startAt),
                          ),
                        ),
                        if (booking.additionalNote != null &&
                            booking.additionalNote!.isNotEmpty)
                          _buildDetailRow(
                            'Special Request',
                            booking.additionalNote!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Frosted Pricing & Payments Glass Card
                  GlassContainer(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.successSurface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.success.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_outlined,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Text(
                                  'Payment Breakdown',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            StatusBadge.fromPaymentStatus(
                              booking.paymentStatusLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildDetailRow(
                          'Total Session Fee',
                          CurrencyFormatter.formatLkr(booking.totalAmount),
                        ),
                        _buildDetailRow(
                          'Amount Settled',
                          CurrencyFormatter.formatLkr(booking.paidAmount),
                          highlightColor: AppColors.success,
                        ),
                        _buildDetailRow(
                          'Outstanding Balance',
                          CurrencyFormatter.formatLkr(booking.balanceAmount),
                          isHighlight: booking.balanceAmount > 0,
                          highlightColor: booking.balanceAmount > 0
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                        if (booking.isUnderVerification) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7)
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.hourglass_top_rounded,
                                  color: Color(0xFFB45309),
                                  size: 22,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bank Transfer Slip Under Review',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: Color(0xFFB45309),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Your transfer slip is currently being reviewed and verified by staff.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (booking.payments.isNotEmpty) ...[
                          const Divider(height: 24),
                          const Text(
                            'Payment History & Receipts',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...booking.payments.map(
                            (p) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${p.method.toUpperCase()} • ${DateFormatter.formatShortDate(p.paidAt)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        if (p.hasReceipt)
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.attachment_rounded,
                                                size: 13,
                                                color: AppColors.primary,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Receipt Attached',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatLkr(p.amount),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (booking.balanceAmount > 0 &&
                            booking.status != 'cancelled') ...[
                          const SizedBox(height: AppSpacing.md),
                          AppButton.primary(
                            text: 'Pay Online Now',
                            icon: const Icon(
                              Icons.payment_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () async {
                              await context.push('/bookings/${booking.id}/pay');
                              ref.invalidate(singleBookingProvider(bookingId));
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 4. Action Buttons
                  if (isConfirmed) ...[
                    AppButton.danger(
                      text: 'Cancel Reservation',
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () async {
                        final confirmed = await AppDialog.confirm(
                          context,
                          title: 'Cancel Reservation',
                          message: 'Are you sure you want to cancel this booking? This will release the slot for other guests.',
                          confirmText: 'Yes, Cancel',
                          isDestructive: true,
                        );

                        if (confirmed == true) {
                          final success = await ref
                              .read(customerBookingsProvider.notifier)
                              .cancelBooking(booking.id);
                          if (success) {
                            ref.invalidate(singleBookingProvider(booking.id));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Reservation has been cancelled',
                                  ),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  AppButton.outline(
                    text: 'Contact Guest Concierge',
                    icon: const Icon(Icons.support_agent_rounded, size: 18),
                    onPressed: () => _showConciergeSheet(context, ref),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showConciergeSheet(BuildContext context, WidgetRef ref) {
    final configAsync = ref.read(resortConfigProvider);
    final config = configAsync.valueOrNull;

    final phone = config?.businessMobile.isNotEmpty == true
        ? config!.businessMobile
        : '+94 77 123 4567';
    final email = config?.businessEmail.isNotEmpty == true
        ? config!.businessEmail
        : 'concierge@zeinspool.lk';
    final resortName = config?.resortName.isNotEmpty == true
        ? config!.resortName
        : "Zein's Pool & Sports Complex";
    final address = config?.businessAddress.isNotEmpty == true
        ? config!.businessAddress
        : 'Sammanthurai, Ampara District, Sri Lanka';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: AppShadows.glassFloating,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Concierge Desk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Direct support for $resortName',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildContactRow(
              Icons.phone_in_talk_rounded,
              'Direct Hotline',
              phone,
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              Icons.chat_bubble_rounded,
              'WhatsApp Concierge',
              phone,
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              Icons.email_outlined,
              'Customer Support',
              email,
              AppColors.burgundy,
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              Icons.location_on_outlined,
              'Facility Address',
              address,
              AppColors.burgundy,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkMiniInfo(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.burgundy),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
    Color? highlightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                color:
                    highlightColor ??
                    (isHighlight ? AppColors.primary : AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
