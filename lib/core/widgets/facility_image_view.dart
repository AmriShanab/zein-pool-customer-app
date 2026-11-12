import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A modern, reusable image component for Zein's facilities.
///
/// Loads the configured asset path and provides an attractive,
/// premium branded visual placeholder if the image has not yet been placed on disk.
class FacilityImageView extends StatelessWidget {
  const FacilityImageView({
    super.key,
    required this.assetPath,
    required this.isTurf,
    this.height,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.heroTag,
  });

  /// The asset path to load (e.g. `FacilityAssets.swimmingPool` or `FacilityAssets.turfGround`).
  final String assetPath;

  /// Whether this facility is the sports turf ground (true) or swimming pool (false).
  final bool isTurf;

  /// Optional fixed height.
  final double? height;

  /// Optional fixed width.
  final double? width;

  /// Corner radius for the image container.
  final BorderRadius? borderRadius;

  /// BoxFit algorithm.
  final BoxFit fit;

  /// Optional hero animation tag.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadii.lg);

    Widget imageContent = ClipRRect(
      borderRadius: effectiveRadius,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // Attractive branded placeholder displayed before user adds their real image
          return _buildAttractivePlaceholder();
        },
      ),
    );

    if (heroTag != null && heroTag!.isNotEmpty) {
      imageContent = Hero(tag: heroTag!, child: imageContent);
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: AppShadows.subtle,
      ),
      child: imageContent,
    );
  }

  Widget _buildAttractivePlaceholder() {
    const gradient = LinearGradient(
      colors: [
        AppColors.burgundyDark,
        AppColors.burgundy,
        AppColors.burgundyLight,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const accentColor = AppColors.burgundySoft;
    final iconData = isTurf ? Icons.sports_soccer_rounded : Icons.pool_rounded;
    final title = isTurf ? "Zein's Turf Ground" : "Zein's Swimming Pool";
    final categoryText = isTurf ? 'PREMIER SPORTS TURF' : 'PRIVATE LUXURY POOL';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background decorative ambient circles
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            left: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Centered branding & icon
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(iconData, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  categoryText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
