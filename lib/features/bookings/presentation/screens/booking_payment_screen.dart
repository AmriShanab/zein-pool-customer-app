import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass/glass_app_bar.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/customer_bookings_provider.dart';
import '../services/payhere_native_service.dart';
import '../widgets/payment_method_selector.dart';
import 'booking_details_screen.dart';

class BookingPaymentScreen extends ConsumerStatefulWidget {
  const BookingPaymentScreen({
    super.key,
    required this.bookingId,
    this.initialMethod,
    this.isCancelled = false,
  });

  final String bookingId;
  final String? initialMethod;
  final bool isCancelled;

  @override
  ConsumerState<BookingPaymentScreen> createState() =>
      _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends ConsumerState<BookingPaymentScreen> {
  bool _isProcessingPayHere = false;
  late bool _isPaymentCancelled;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isPaymentCancelled = widget.isCancelled;
  }

  Future<void> _handlePayHerePayment() async {
    setState(() {
      _isProcessingPayHere = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(bookingRepositoryProvider);
      final checkoutData = await repo.initiatePayHere(widget.bookingId);

      if (!mounted) return;

      await PayHereNativeService.startPayment(
        context: context,
        checkoutData: checkoutData,
        onSuccess: (paymentId, orderId) async {
          await _onPayHereSuccess(paymentId, orderId);
        },
        onError: (error) {
          _onPayHereError(error);
        },
        onDismissed: () {
          _onPayHereCanceled();
        },
      );
    } catch (e) {
      setState(() {
        _isProcessingPayHere = false;
        _errorMessage = e.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), '');
      });
    }
  }

  Future<void> _onPayHereSuccess(String paymentId, String orderId) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(strokeWidth: 2.5),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Verifying Payment...',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Awaiting server webhook confirmation from PayHere...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final repo = ref.read(bookingRepositoryProvider);

    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final verifyResult = await repo.verifyPayHere(
          bookingId: widget.bookingId,
          orderId: orderId,
          paymentId: paymentId,
        );

        if (verifyResult['verified'] == true ||
            verifyResult['status'] == 'success') {
          break;
        }
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 500));
    }

    ref.invalidate(singleBookingProvider(widget.bookingId));
    ref.read(customerBookingsProvider.notifier).refresh();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    setState(() {
      _isProcessingPayHere = false;
      _isPaymentCancelled = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment confirmed! Your reservation is booked.',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: AppColors.success,
      ),
    );

    context.go('/home');
  }

  void _onPayHereError(String error) {
    setState(() {
      _isProcessingPayHere = false;
      _isPaymentCancelled = true;
      _errorMessage = error;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment Error: $error',
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _onPayHereCanceled() {
    setState(() {
      _isProcessingPayHere = false;
      _isPaymentCancelled = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment was canceled. You can retry paying anytime.',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(singleBookingProvider(widget.bookingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GlassAppBar(title: 'Online Payment'),
      body: GlassScaffoldBackground(
        child: bookingAsync.when(
          loading: () =>
              const AppLoadingIndicator(message: 'Loading booking details...'),
          error: (err, _) => ErrorState(
            message: err.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), ''),
            onRetry: () => ref.refresh(singleBookingProvider(widget.bookingId)),
          ),
          data: (booking) {
            final balance = booking.balanceAmount;
            final displayId = booking.id.length >= 8
                ? booking.id.substring(0, 8).toUpperCase()
                : booking.id.toUpperCase();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Payment Cancelled Banner Card (shown when payment was cancelled)
                  if (_isPaymentCancelled && !booking.isFullyPaid) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.burgundyMuted,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.burgundy.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.burgundySoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cancel_outlined,
                              color: AppColors.burgundy,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Cancelled',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.burgundyDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Your online payment was cancelled and has not been completed yet. You can retry your online payment below or return to the Home screen.',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Booking Summary Header Card
                  GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: BorderRadius.circular(20),
                    blur: 16,
                    backgroundColor: AppColors.glassSurface,
                    borderColor: AppColors.glassBorder,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.burgundy.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.serviceName ??
                                        "Zein's Pool Session",
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '#$displayId',
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.burgundy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge.fromPaymentStatus(
                              booking.paymentStatusLabel,
                            ),
                          ],
                        ),
                        Divider(height: 22, color: AppColors.glassBorderSubtle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildAmountStat(
                                'Total Fee',
                                booking.totalAmount,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: _buildAmountStat(
                                'Paid Amount',
                                booking.paidAmount,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: _buildAmountStat(
                                'Balance Due',
                                balance,
                                isHighlight: balance > 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (_errorMessage != null) ...[
                    GlassContainer(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: BorderRadius.circular(14),
                      blur: 12,
                      backgroundColor: AppColors.errorSurface,
                      borderColor: AppColors.error.withValues(alpha: 0.3),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  if (booking.isFullyPaid || balance <= 0) ...[
                    GlassContainer(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      borderRadius: BorderRadius.circular(20),
                      blur: 16,
                      backgroundColor: AppColors.glassSurface,
                      borderColor: AppColors.success.withValues(alpha: 0.4),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 48,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Booking Fully Paid',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'No further payment is required for this booking. You can return to the Home screen anytime.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.primary(
                      text: 'Back to Home',
                      icon: const Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => context.go('/home'),
                    ),
                  ] else ...[
                    // Online Payment Section Only
                    const Text(
                      'Online Payment',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PaymentMethodSelector(
                      selectedMethod: 'online',
                      onMethodChanged: (_) {},
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppButton.primary(
                      text: _isProcessingPayHere
                          ? 'Connecting to PayHere...'
                          : (_isPaymentCancelled
                                ? 'Retry Payment (${CurrencyFormatter.formatLkr(balance > 0 ? balance : booking.totalAmount)})'
                                : 'Pay ${CurrencyFormatter.formatLkr(balance > 0 ? balance : booking.totalAmount)} with PayHere'),
                      icon: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      isLoading: _isProcessingPayHere,
                      onPressed: !_isProcessingPayHere
                          ? _handlePayHerePayment
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton.outline(
                      text: 'Back to Home',
                      onPressed: () => context.go('/home'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAmountStat(
    String title,
    double amount, {
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            CurrencyFormatter.formatLkr(amount),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15.5,
              fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
              color: isHighlight ? AppColors.burgundy : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
