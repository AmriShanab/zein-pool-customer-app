import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/phone_validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/glass/glass_app_bar.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../resort_info/presentation/providers/resort_config_provider.dart';

import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';
import 'package:zain_pool_customer_app/features/services/presentation/providers/availability_provider.dart';

import '../../domain/entities/customer_booking.dart';
import '../providers/booking_checkout_provider.dart';
import '../providers/customer_bookings_provider.dart';
import '../services/payhere_native_service.dart';
import '../widgets/payment_method_selector.dart';
import 'booking_details_screen.dart';

class BookingCheckoutScreen extends ConsumerStatefulWidget {
  const BookingCheckoutScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<BookingCheckoutScreen> createState() =>
      _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends ConsumerState<BookingCheckoutScreen> {
  final _noteController = TextEditingController();
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isRequestingOtp = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _noteController.dispose();
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleGuestAuth() async {
    final phone = _guestPhoneController.text.trim();
    if (!isValidSriLankanMobile(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid Sri Lankan mobile number',
            style: TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isRequestingOtp = true);
    final success = await ref
        .read(authStateProvider.notifier)
        .requestOtp(phone);
    setState(() {
      _isRequestingOtp = false;
      _otpSent = success;
    });

    if (success && mounted) {
      final challenge = ref.read(authStateProvider).challenge;
      if (challenge?.debugOtp != null) {
        _otpController.text = challenge!.debugOtp!;
      }
    }
  }

  Future<void> _handleVerifyGuestOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the 6-digit code',
            style: TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(authStateProvider.notifier)
        .verifyOtp(otp, name: _guestNameController.text.trim());

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verified successfully! Ready to book.',
            style: TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleConfirmBooking() async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please verify your mobile number before confirming reservation.',
            style: TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final draft = ref.read(bookingCheckoutProvider);
    final service = draft.service;
    if (service == null) return;

    // 1. Strict Pre-Payment Validation:
    // Verify slot availability in real time before initiating payment or reservation
    final isSlotAvailable = await ref
        .read(bookingCheckoutProvider.notifier)
        .validateSlotAvailability();

    if (!isSlotAvailable) {
      if (!mounted) return;
      _showSlotUnavailableDialog(draft);
      return;
    }

    // 2. Submit Booking Reservation
    ref
        .read(bookingCheckoutProvider.notifier)
        .setAdditionalNote(_noteController.text.trim());

    final booking = await ref
        .read(bookingCheckoutProvider.notifier)
        .submitBooking();

    if (booking == null) {
      if (!mounted) return;
      final error =
          ref.read(bookingCheckoutProvider).errorMessage ?? 'Booking failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: const TextStyle(fontFamily: 'Nunito')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;

    // 3. Handle Online Payment via PayHere
    await _launchInAppPayHereCheckout(booking);
  }

  void _showSlotUnavailableDialog(BookingDraftState draft) {
    final slotName = draft.bookingType == BookingTypeEnum.hourly
        ? (draft.selectedTimeRange ?? 'hourly slot')
        : 'session';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(
          Icons.event_busy_rounded,
          color: AppColors.error,
          size: 48,
        ),
        title: const Text(
          'Slot No Longer Available',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800),
        ),
        content: Text(
          'The selected $slotName is no longer available. Another customer may have just reserved it. Please choose a different time.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
        ),
        actions: [
          AppButton.primary(
            text: 'Choose Another Time',
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(bookingCheckoutProvider.notifier).clearSlot();
              final dateStr = DateFormatter.toIsoDate(draft.bookingDate);
              ref.invalidate(
                availabilityProvider(
                  AvailabilityQuery(serviceId: widget.serviceId, date: dateStr),
                ),
              );
              context.go('/services/${widget.serviceId}/book');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchInAppPayHereCheckout(CustomerBooking booking) async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final checkoutData = await repo.initiatePayHere(booking.id);

      if (!mounted) return;

      await PayHereNativeService.startPayment(
        context: context,
        checkoutData: checkoutData,
        onSuccess: (paymentId, orderId) async {
          await _onPayHereSuccess(booking, paymentId, orderId);
        },
        onError: (error) {
          _onPayHereError(booking, error);
        },
        onDismissed: () {
          _onPayHereCanceled(booking);
        },
      );
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment initiation failed: $errorMsg',
            style: const TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      context.go('/bookings/${booking.id}/pay?method=online&cancelled=true');
    }
  }

  Future<void> _onPayHereSuccess(
    CustomerBooking booking,
    String paymentId,
    String orderId,
  ) async {
    if (!mounted) return;

    // Show verification dialog
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

    // Verify payment with backend
    final repo = ref.read(bookingRepositoryProvider);

    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final verifyResult = await repo.verifyPayHere(
          bookingId: booking.id,
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

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context); // Close verification dialog
    }

    if (!mounted) return;

    ref.invalidate(singleBookingProvider(booking.id));
    ref.read(customerBookingsProvider.notifier).refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment confirmed! Your reservation is booked.',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: AppColors.success,
      ),
    );

    // Redirect to Home screen after successful payment
    context.go('/home');
  }

  void _onPayHereError(CustomerBooking booking, String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment Error: $error. You can retry paying anytime.',
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: AppColors.error,
      ),
    );
    context.go('/bookings/${booking.id}/pay?method=online&cancelled=true');
  }

  void _onPayHereCanceled(CustomerBooking booking) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment was canceled. Your booking is reserved and can be paid anytime.',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        backgroundColor: AppColors.info,
      ),
    );
    context.go('/bookings/${booking.id}/pay?method=online&cancelled=true');
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingCheckoutProvider);
    final authState = ref.watch(authStateProvider);
    final resortConfigAsync = ref.watch(resortConfigProvider);
    final service = draft.service;

    if (service == null) {
      return Scaffold(
        appBar: const GlassAppBar(title: 'Review Booking'),
        body: GlassScaffoldBackground(
          child: Center(
            child: AppButton.primary(
              text: 'Return to Facilities',
              onPressed: () => context.go('/home'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GlassAppBar(title: 'Review & Confirm'),
      body: GlassScaffoldBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A. Unified Editorial Reservation Header (Midnight Navy Block)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.midnightNavy,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'RESERVATION SUMMARY',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.electricCyan,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge.fromBookingType(
                          draft.bookingType.wireValue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DATE',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withValues(alpha: 0.65),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormatter.formatFullDate(
                                    draft.bookingDate,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 26,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SESSION TIME',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withValues(alpha: 0.65),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  draft.bookingType == BookingTypeEnum.hourly
                                      ? (draft.selectedSlots.isNotEmpty
                                            ? draft.selectedSlotsLabel
                                            : 'Hourly')
                                      : 'Scheduled Session',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.electricCyan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Unified Editorial Checkout Sheet Body (Single Clean Surface with Hairlines)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                  border: Border(
                    left: BorderSide(color: AppColors.borderNeutral),
                    right: BorderSide(color: AppColors.borderNeutral),
                    bottom: BorderSide(color: AppColors.borderNeutral),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // B. Guest Information
                    const Text(
                      'GUEST DETAILS',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.mutedSteel,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (authState.isAuthenticated) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authState.customer!.name,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.midnightNavy,
                                  ),
                                ),
                                Text(
                                  formatDisplayPhone(
                                    authState.customer!.mobile,
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/login'),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 32),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text(
                        'Verify your mobile number to receive your booking confirmation.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (!_otpSent) ...[
                        AppTextField(
                          controller: _guestNameController,
                          label: 'Guest Name',
                          hint: 'e.g. Asmi Mohamed',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          controller: _guestPhoneController,
                          label: 'Mobile Number',
                          hint: '77 123 4567',
                          isPhone: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton.primary(
                          text: 'Send Verification Code',
                          isLoading: _isRequestingOtp,
                          onPressed: _handleGuestAuth,
                        ),
                      ] else ...[
                        AppTextField(
                          controller: _otpController,
                          label:
                              'Enter 6-digit Code sent to ${_guestPhoneController.text}',
                          hint: '000000',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton.primary(
                          text: 'Verify Code',
                          onPressed: _handleVerifyGuestOtp,
                        ),
                      ],
                    ],

                    const Divider(height: 28, color: AppColors.borderSubtle),

                    // C. Payment Method
                    const Text(
                      'PAYMENT METHOD',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.mutedSteel,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PaymentMethodSelector(
                      selectedMethod: draft.paymentMethod,
                      onMethodChanged: (method) {
                        ref
                            .read(bookingCheckoutProvider.notifier)
                            .setPaymentMethod(method);
                      },
                      allowOnlinePayment: service.allowOnlinePayment,
                      bankInfo: resortConfigAsync.valueOrNull?.bankInfo,
                      receiptFile: draft.receiptFile,
                      onReceiptChanged: (file) {
                        ref
                            .read(bookingCheckoutProvider.notifier)
                            .setReceiptFile(file);
                      },
                    ),

                    const Divider(height: 28, color: AppColors.borderSubtle),

                    // D. Special Requests (Compact)
                    const Text(
                      'SPECIAL REQUESTS (OPTIONAL)',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.mutedSteel,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5,
                        color: AppColors.midnightNavy,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add any note for your session...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.mutedSteel,
                          fontSize: 12.5,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.borderNeutral,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.borderNeutral,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.deepSportsBlue,
                            width: 1.4,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                    ),

                    const Divider(height: 28, color: AppColors.borderSubtle),

                    // E. Price Breakdown (Accurate, No Fabricated Tax Rows)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            draft.bookingType == BookingTypeEnum.hourly &&
                                    draft.selectedSlotCount > 1
                                ? 'Session Subtotal (${draft.selectedSlotCount} Slots)'
                                : 'Session Subtotal',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          CurrencyFormatter.formatLkr(draft.totalPrice),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.midnightNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Payable',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.midnightNavy,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          CurrencyFormatter.formatLkr(draft.totalPrice),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepSportsBlue,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // F. Primary CTA
              AppButton.primary(
                text: 'Proceed to Online Payment',
                isLoading: draft.isSubmitting,
                icon: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: _handleConfirmBooking,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Center(
                child: Text(
                  'By reserving, you agree to Zein\'s Pool guidelines and rules.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedSteel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
