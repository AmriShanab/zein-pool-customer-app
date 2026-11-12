import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
}

abstract final class AppRadii {
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 18.0;
  static const double xl = 24.0;
  static const double xxl = 30.0;
  static const double pill = 999.0;

  static final BorderRadius roundedXs = BorderRadius.circular(xs);
  static final BorderRadius roundedSm = BorderRadius.circular(sm);
  static final BorderRadius roundedMd = BorderRadius.circular(md);
  static final BorderRadius roundedLg = BorderRadius.circular(lg);
  static final BorderRadius roundedXl = BorderRadius.circular(xl);
  static final BorderRadius roundedXxl = BorderRadius.circular(xxl);
  static final BorderRadius roundedPill = BorderRadius.circular(pill);
}

abstract final class AppGlassBlur {
  static const double subtle = 8.0;
  static const double standard = 16.0;
  static const double heavy = 24.0;
  static const double intense = 36.0;
}

abstract final class AppShadows {
  static const subtle = [
    BoxShadow(color: Color(0x0A3D0816), blurRadius: 10, offset: Offset(0, 3)),
  ];

  static const elevated = [
    BoxShadow(color: Color(0x124A0A1B), blurRadius: 20, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x087B112C), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const card = [
    BoxShadow(color: Color(0x0F4A0A1B), blurRadius: 18, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x082A050F), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const glass = [
    BoxShadow(
      color: Color(0x0D4A0A1B),
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
    BoxShadow(color: Color(0x087B112C), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const glassFloating = [
    BoxShadow(
      color: Color(0x184A0A1B),
      blurRadius: 28,
      offset: Offset(0, 12),
      spreadRadius: 1,
    ),
    BoxShadow(color: Color(0x127B112C), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const luxuryGlow = [
    BoxShadow(color: Color(0x267B112C), blurRadius: 20, offset: Offset(0, 6)),
  ];

  static const darkGlassGlow = [
    BoxShadow(color: Color(0x144A0A1B), blurRadius: 24, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x127B112C), blurRadius: 14, offset: Offset(0, 2)),
  ];
}
