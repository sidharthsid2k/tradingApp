import 'package:flutter/material.dart';

/// Centralised colour palette for the light clean trading theme.
class AppColors {
  AppColors._();

  // ─── Background ─────────────────────────────────────────────────────────────
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);
  static const cardBg = Color(0xFFFFFFFF);
  static const bottomNavBg = Color(0xFFFFFFFF);

  // ─── Accent ──────────────────────────────────────────────────────────────────
  static const primary = Color(0xFF0D9488); // Crisp Emerald/Teal
  static const primaryDim = Color(0xFF0F766E);
  static const primaryBg = Color(0xFFCCFBF1);
  static const secondary = Color(0xFF2563EB); // Royal Blue
  static const secondaryBg = Color(0xFFDBEAFE);
  static const gradientStart = Color(0xFF0D9488);
  static const gradientEnd = Color(0xFF2563EB);

  // ─── Market (Gain / Loss) ────────────────────────────────────────────────────
  static const gain = Color(0xFF16A34A);
  static const gainLight = Color(0xFF22C55E);
  static const gainBg = Color(0xFFDCFCE7);
  static const gainFlash = Color(0x3016A34A);
  static const loss = Color(0xFFDC2626);
  static const lossLight = Color(0xFFEF4444);
  static const lossBg = Color(0xFFFEE2E2);
  static const lossFlash = Color(0x30DC2626);
  static const neutral = Color(0xFF64748B);
  static const neutralBg = Color(0xFFF1F5F9);

  // ─── Text ────────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF475569); // Slate 600
  static const textMuted = Color(0xFF64748B); // Slate 500
  static const textDisabled = Color(0xFF94A3B8); // Slate 400

  // ─── Borders ─────────────────────────────────────────────────────────────────
  static const border = Color(0xFFE2E8F0); // Slate 200
  static const borderLight = Color(0xFFF1F5F9); // Slate 100
  static const divider = Color(0xFFE2E8F0);

  // ─── Status ──────────────────────────────────────────────────────────────────
  static const error = Color(0xFFDC2626);
  static const errorBg = Color(0xFFFEE2E2);
  static const warning = Color(0xFFD97706);
  static const success = Color(0xFF16A34A);

  // ─── Overlays ─────────────────────────────────────────────────────────────────
  static const glassWhite = Color(0x80FFFFFF);
  static const glassBorder = Color(0x33000000);
  static const overlay = Color(0x660F172A);
}
