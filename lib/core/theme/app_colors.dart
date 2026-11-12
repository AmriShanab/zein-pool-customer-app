import 'package:flutter/material.dart';

abstract final class AppColors {
  // 1. Official "ZEIN'S — THE GAME STARTS HERE" Brand Palette
  static const midnightNavy = Color(0xFF06172B);
  static const deepSportsBlue = Color(0xFF073B63);
  static const electricCyan = Color(0xFF22D3EE);
  static const oceanBlue = Color(0xFF087DBA);
  static const iceWhite = Color(0xFFF5F8FC);
  static const whiteSurface = Color(0xFFFFFFFF);
  static const mutedSteel = Color(0xFF8293A7);
  static const borderNeutral = Color(0xFFD8E1EA);

  // Semantic Aliases
  static const deepNavy = midnightNavy;
  static const silverBorder = borderNeutral;

  // Typography
  static const textPrimary = Color(0xFF06172B);
  static const textSecondary = Color(0xFF52657A);
  static const textMuted = mutedSteel;
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Slot & Booking Status Colors
  static const availableSlot = Color(0xFFF0F9FF);
  static const bookedSlot = Color(0xFFE6ECF2);
  static const pastSlot = Color(0xFFEDF1F5);
  static const unavailableSlot = Color(0xFFFCE8E8);
  static const confirmedBooking = Color(0xFFDDF7E8);

  // Primary Action & Brand Semantic Aliases
  static const primary = oceanBlue;
  static const primaryDark = midnightNavy;
  static const primaryLight = electricCyan;
  static const cyanAqua = electricCyan;
  static const brightAqua = electricCyan;
  static const tealGlow = electricCyan;
  static const primarySurface = availableSlot;

  // Legacy aliases mapped cleanly to Midnight Navy / Deep Sports Blue / Cyan
  static const burgundy = oceanBlue;
  static const burgundyDark = midnightNavy;
  static const burgundyLight = electricCyan;
  static const burgundySoft = availableSlot;
  static const burgundyMuted = borderNeutral;

  // Backgrounds & Surfaces
  static const background = iceWhite;
  static const surface = whiteSurface;
  static const surfaceMuted = Color(0xFFEEF3F8);
  static const surfaceElevated = whiteSurface;
  static const border = borderNeutral;
  static const borderSubtle = Color(0xFFE4EBF2);

  // Status & Feedback
  static const success = Color(0xFF16834A);
  static const successSurface = confirmedBooking;
  static const warning = Color(0xFFE9A23B);
  static const warningSurface = Color(0xFFFEF7EC);
  static const error = Color(0xFFD92D35);
  static const errorSurface = unavailableSlot;
  static const info = oceanBlue;
  static const infoSurface = availableSlot;

  // Controlled High-Impact Gradients (Hero overlay, Primary CTA, Selected state)
  static const primaryGradient = LinearGradient(
    colors: [deepSportsBlue, oceanBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroGradient = LinearGradient(
    colors: [midnightNavy, deepSportsBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Clean Surfaces & Borders
  static const glassSurface = whiteSurface;
  static const glassSurfaceSubtle = iceWhite;
  static const glassSurfaceUltra = Color(0xFFFAFCFE);
  static const glassBorder = borderNeutral;
  static const glassBorderSubtle = Color(0xFFE4EBF2);
  static const glassGlow = Color(0x1F073B63);
  static const glassGlowTeal = Color(0x1F22D3EE);

  // Light Gradients
  static const glassGradientLight = LinearGradient(
    colors: [whiteSurface, iceWhite],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glassBorderGradientLight = LinearGradient(
    colors: [borderNeutral, Color(0xFFE4EBF2), borderNeutral],
    stops: [0.0, 0.6, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const meshBackgroundGradient = LinearGradient(
    colors: [whiteSurface, iceWhite, Color(0xFFEEF4FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Unified Fallbacks
  static const darkBackground = iceWhite;
  static const darkCard = whiteSurface;
  static const darkCardElevated = whiteSurface;
  static const darkGlassSurface = whiteSurface;
  static const darkGlassElevated = iceWhite;
  static const darkBorder = borderNeutral;
  static const darkBorderSubtle = Color(0xFFE4EBF2);
  static const darkGlassBorder = borderNeutral;
  static const darkTextPrimary = textPrimary;
  static const darkTextSecondary = textSecondary;
  static const darkTextMuted = textMuted;

  static const darkLuxuryGradient = LinearGradient(
    colors: [midnightNavy, deepSportsBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGlassGradient = LinearGradient(
    colors: [whiteSurface, iceWhite],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGlassBorderGradient = LinearGradient(
    colors: [borderNeutral, Color(0xFFE4EBF2), borderNeutral],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkAccentGradient = LinearGradient(
    colors: [deepSportsBlue, oceanBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
