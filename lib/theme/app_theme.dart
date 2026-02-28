import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color card = Color(0xFF1A2235);
  static const Color cardBorder = Color(0xFF2A3550);
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentGlow = Color(0x336C63FF);
  static const Color green = Color(0xFF00D4AA);
  static const Color yellow = Color(0xFFFFB800);
  static const Color red = Color(0xFFFF4757);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color textMuted = Color(0xFF4A5568);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: green,
          surface: surface,
          error: red,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        cardColor: card,
        dividerColor: cardBorder,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
      );
}

// Risk level helpers
enum RiskLevel { safe, caution, high }

extension RiskLevelExtension on RiskLevel {
  Color get color {
    switch (this) {
      case RiskLevel.safe:
        return AppTheme.green;
      case RiskLevel.caution:
        return AppTheme.yellow;
      case RiskLevel.high:
        return AppTheme.red;
    }
  }

  String get label {
    switch (this) {
      case RiskLevel.safe:
        return 'SAFE';
      case RiskLevel.caution:
        return 'CAUTION';
      case RiskLevel.high:
        return 'HIGH RISK';
    }
  }

  String get emoji {
    switch (this) {
      case RiskLevel.safe:
        return '🟢';
      case RiskLevel.caution:
        return '🟡';
      case RiskLevel.high:
        return '🔴';
    }
  }
}

RiskLevel getRiskLevel(double score) {
  if (score < 0.4) return RiskLevel.safe;
  if (score < 0.7) return RiskLevel.caution;
  return RiskLevel.high;
}
