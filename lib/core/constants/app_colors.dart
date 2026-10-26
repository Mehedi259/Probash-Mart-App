import 'package:flutter/material.dart';

/// Probash Mart Brand Color System
/// Exact match with Probash Mart website and official brand guidelines.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFFFE6202); // Warm Orange
  static const Color primaryDark = Color(0xFFD64F00);
  static const Color primaryLight = Color(0xFFFF8C04);
  static const Color primaryContainer = Color(0xFFFFEEDF);
  static const Color onPrimaryContainer = Color(0xFF832E00);

  // Secondary Brand Colors
  static const Color secondary = Color(0xFF281508); // Deep Espresso
  static const Color secondaryLight = Color(0xFF42220D);
  static const Color onSecondary = Colors.white;

  // Accent / Highlights
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color gold = Color(0xFFF59E0B);

  // Background & Surfaces
  static const Color background = Color(0xFFFBFBFA);
  static const Color surface = Colors.white;
  static const Color surfaceDim = Color(0xFFF0F0ED);
  static const Color surfaceContainer = Color(0xFFF2F3F5);
  static const Color surfaceContainerHigh = Color(0xFFE9EAED);
  static const Color cardColor = Colors.white;

  // Text & Typography
  static const Color textPrimary = Color(0xFF191C1F);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // WhatsApp Brand Color
  static const Color whatsapp = Color(0xFF25D366);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
