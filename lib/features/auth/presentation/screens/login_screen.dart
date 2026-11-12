import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/facility_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/glass/glass_app_bar.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();

  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = seconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleRequestOtp() async {
    final phone = _phoneController.text.trim();
    if (!isValidSriLankanMobile(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid Sri Lankan mobile number (e.g. 077 123 4567)',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(authStateProvider.notifier)
        .requestOtp(phone);
    if (success && mounted) {
      final challenge = ref.read(authStateProvider).challenge;
      _startTimer(challenge?.resendAfterSeconds ?? 60);
      if (challenge?.debugOtp != null) {
        _otpController.text = challenge!.debugOtp!;
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit verification code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final success = await ref
        .read(authStateProvider.notifier)
        .verifyOtp(otp, name: name.isNotEmpty ? name : null);

    if (success && mounted) {
      if (widget.redirectTo != null && widget.redirectTo!.isNotEmpty) {
        context.go(widget.redirectTo!);
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final hasCodeSent = authState.hasCodeSent;

    return GlassScaffoldBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar(
          title: 'Sign In / Register',
          onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Brand Header with Burgundy Ringed Medallion
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.burgundySoft,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.burgundyMuted,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.burgundy.withValues(alpha: 0.14),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.burgundy.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Image.asset(
                            FacilityAssets.logo,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.pool_rounded,
                                  size: 46,
                                  color: AppColors.burgundy,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                      children: [
                        TextSpan(
                          text: "Zein's ",
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        TextSpan(
                          text: 'Pool',
                          style: TextStyle(color: AppColors.burgundy),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Exclusive Resort & Pool Experiences',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Error display if any
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.35),
                      ),
                    ),
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
                            authState.errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Pure White & Burgundy Authentication Form Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.burgundyDark.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!hasCodeSent) ...[
                        const Text(
                          "Welcome to Zein's Pool",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enter your mobile number to sign in or create your verified guest profile.',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          controller: _nameController,
                          label: 'Full Name (Optional for first-time guests)',
                          hint: 'e.g. Asmi Mohamed',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.burgundy,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Mobile Number',
                          hint: '77 123 4567',
                          isPhone: true,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppButton.primary(
                          text: 'Send Verification Code',
                          isLoading: authState.isLoading,
                          isFullWidth: true,
                          onPressed: _handleRequestOtp,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: AppColors.burgundySoft,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.burgundy,
                                ),
                                onPressed: () {
                                  ref.read(authStateProvider.notifier).reset();
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Code sent to:',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    formatDisplayPhone(authState.mobile ?? ''),
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: Color(0xFFF1E8EB)),
                        if (authState.challenge?.debugOtp != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm + 2),
                            decoration: BoxDecoration(
                              color: AppColors.burgundySoft,
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                              border: Border.all(
                                color: AppColors.burgundyMuted,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.vpn_key_rounded,
                                  size: 18,
                                  color: AppColors.burgundy,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Test OTP: ${authState.challenge!.debugOtp}',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.burgundy,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    _otpController.text =
                                        authState.challenge!.debugOtp!;
                                  },
                                  child: const Text(
                                    'Autofill',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.burgundy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        AppTextField(
                          controller: _otpController,
                          label: '6-Digit Verification Code',
                          hint: '000000',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(
                            Icons.lock_clock_outlined,
                            color: AppColors.burgundy,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppButton.primary(
                          text: 'Verify & Continue',
                          isLoading: authState.isLoading,
                          isFullWidth: true,
                          onPressed: _handleVerifyOtp,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Center(
                          child: _secondsRemaining > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.burgundySoft,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.pill,
                                    ),
                                  ),
                                  child: Text(
                                    'Resend code in ${_secondsRemaining}s',
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.burgundy,
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed: _handleRequestOtp,
                                  child: const Text(
                                    'Resend Code',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.burgundy,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(
                      Icons.explore_outlined,
                      size: 18,
                      color: AppColors.burgundy,
                    ),
                    label: const Text(
                      'Continue as Guest',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.burgundy,
                      ),
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
