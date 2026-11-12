import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/facility_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.86,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _glowAnimation = Tween<double>(
      begin: 0.12,
      end: 0.28,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Clean Ice White & White Surface Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.meshBackgroundGradient,
            ),
          ),

          // 2. Subtle Warm Burgundy Ambient Spheres
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: size.width * 0.85,
              height: size.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.burgundy.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: size.width * 0.85,
              height: size.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.burgundyLight.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // 3. Central Pure White & Burgundy Luxury Showcase Card
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: 38,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.burgundyDark.withValues(alpha: 0.08),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: AppColors.burgundy.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand Emblem Medallion with Burgundy Ring
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.burgundy.withValues(
                                    alpha: 0.45,
                                  ),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.burgundy.withValues(
                                      alpha: _glowAnimation.value,
                                    ),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: ClipOval(
                                child: Image.asset(
                                  FacilityAssets.logo,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.pool_rounded,
                                        size: 52,
                                        color: AppColors.burgundy,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Brand Title
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(text: "Zein's "),
                              TextSpan(
                                text: 'Pool',
                                style: TextStyle(color: AppColors.burgundy),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle Tagline
                        const Text(
                          'Exclusive Pool & Sports Turf Reservations',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Showcase Highlights Soft Burgundy Pills
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.xs + 2,
                          runSpacing: AppSpacing.xs,
                          children: [
                            _buildShowcasePill(
                              Icons.lock_outline_rounded,
                              '100% Private',
                            ),
                            _buildShowcasePill(
                              Icons.waves_rounded,
                              'Filtered Pool',
                            ),
                            _buildShowcasePill(
                              Icons.sports_soccer_rounded,
                              'Sports Turf',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Sleek Burgundy Loading Spinner
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.burgundy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcasePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.burgundySoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: AppColors.burgundyMuted,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.burgundy),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.burgundyDark,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
