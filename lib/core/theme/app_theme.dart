// app_theme.dart
// Konfigurasi tema terpusat (Material 3) dengan font Plus Jakarta Sans,
// ColorScheme custom bernuansa teal/aqua, serta ThemeExtension untuk
// palet latar cuaca dinamis dan parameter glassmorphism.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kategori suasana cuaca untuk menentukan palet warna latar & aksen.
enum WeatherMood {
  clearDay, // Cerah siang: biru langit ke teal terang
  cloudy, // Berawan: abu kebiruan lembut
  rain, // Hujan: teal gelap ke biru laut
  storm, // Badai: biru tua keunguan gelap
  night, // Malam: navy ke indigo
  fog, // Kabut: abu kehijauan pudar
}

/// ThemeExtension yang menyimpan palet warna cuaca dan parameter glassmorphism.
/// Diambil dari `Theme.of(context).extension<WeatherPalette>()` agar konsisten.
class WeatherPalette extends ThemeExtension<WeatherPalette> {
  final Color glassTint;
  final double glassFillOpacity;
  final double glassBlurSigma;
  final double glassRadius;
  final double glassBorderOpacity;
  final Color accentAqua;
  final Color accentWarm;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const WeatherPalette({
    required this.glassTint,
    required this.glassFillOpacity,
    required this.glassBlurSigma,
    required this.glassRadius,
    required this.glassBorderOpacity,
    required this.accentAqua,
    required this.accentWarm,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  /// Palet default untuk mode kaca transparan berwarna.
  static const WeatherPalette standard = WeatherPalette(
    glassTint: Color(0xFF38BDF8),
    glassFillOpacity: 0.14,
    glassBlurSigma: 18.0,
    glassRadius: 24.0,
    glassBorderOpacity: 0.28,
    accentAqua: Color(0xFF5EEAD4),
    accentWarm: Color(0xFFFBBF24),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFDCE7F3),
    textMuted: Color(0xFF9FB4C9),
  );

  /// Mengembalikan daftar warna gradien (atas -> bawah) + warna blob dekoratif
  /// sesuai kondisi cuaca dan siang/malam.
  static WeatherBackgroundScheme getScheme(WeatherMood mood) {
    switch (mood) {
      case WeatherMood.clearDay:
        return const WeatherBackgroundScheme(
          gradientColors: [
            Color(0xFF0B4F8A),
            Color(0xFF157A9E),
            Color(0xFF21A6A8),
          ],
          primaryBlob: Color(0xFF5EEAD4),
          secondaryBlob: Color(0xFF38BDF8),
          glassTint: Color(0xFF7DD3FC),
        );
      case WeatherMood.cloudy:
        return const WeatherBackgroundScheme(
          gradientColors: [
            Color(0xFF2B4157),
            Color(0xFF425B73),
            Color(0xFF5C768D),
          ],
          primaryBlob: Color(0xFF93C5FD),
          secondaryBlob: Color(0xFF7DD3FC),
          glassTint: Color(0xFFBAE6FD),
        );
      case WeatherMood.rain:
        return const WeatherBackgroundScheme(
          gradientColors: [
            Color(0xFF0A2E44),
            Color(0xFF0E4D64),
            Color(0xFF136F7A),
          ],
          primaryBlob: Color(0xFF2DD4BF),
          secondaryBlob: Color(0xFF0284C7),
          glassTint: Color(0xFF5EEAD4),
        );
      case WeatherMood.storm:
        return const WeatherBackgroundScheme(
          gradientColors: [
            Color(0xFF111633),
            Color(0xFF1C234D),
            Color(0xFF282B5E),
          ],
          primaryBlob: Color(0xFF6366F1),
          secondaryBlob: Color(0xFF0EA5E9),
          glassTint: Color(0xFF93C5FD),
        );
      case WeatherMood.night:
        return const WeatherBackgroundScheme(
          gradientColors: [
            Color(0xFF081226),
            Color(0xFF0E1E3E),
            Color(0xFF162B54),
          ],
          primaryBlob: Color(0xFF2563EB),
          secondaryBlob: Color(0xFF14B8A6),
          glassTint: Color(0xFF7DD3FC),
        );
      case WeatherMood.fog:
        return const WeatherBackgroundScheme(
          gradientColors: [
            Color(0xFF2F4544),
            Color(0xFF455E5C),
            Color(0xFF607875),
          ],
          primaryBlob: Color(0xFF99F6E4),
          secondaryBlob: Color(0xFF94A3B8),
          glassTint: Color(0xFFCCFBF1),
        );
    }
  }

  @override
  WeatherPalette copyWith({
    Color? glassTint,
    double? glassFillOpacity,
    double? glassBlurSigma,
    double? glassRadius,
    double? glassBorderOpacity,
    Color? accentAqua,
    Color? accentWarm,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
  }) {
    return WeatherPalette(
      glassTint: glassTint ?? this.glassTint,
      glassFillOpacity: glassFillOpacity ?? this.glassFillOpacity,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      glassRadius: glassRadius ?? this.glassRadius,
      glassBorderOpacity: glassBorderOpacity ?? this.glassBorderOpacity,
      accentAqua: accentAqua ?? this.accentAqua,
      accentWarm: accentWarm ?? this.accentWarm,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  WeatherPalette lerp(ThemeExtension<WeatherPalette>? other, double t) {
    if (other is! WeatherPalette) return this;
    return WeatherPalette(
      glassTint: Color.lerp(glassTint, other.glassTint, t) ?? glassTint,
      glassFillOpacity:
          glassFillOpacity + (other.glassFillOpacity - glassFillOpacity) * t,
      glassBlurSigma:
          glassBlurSigma + (other.glassBlurSigma - glassBlurSigma) * t,
      glassRadius: glassRadius + (other.glassRadius - glassRadius) * t,
      glassBorderOpacity: glassBorderOpacity +
          (other.glassBorderOpacity - glassBorderOpacity) * t,
      accentAqua: Color.lerp(accentAqua, other.accentAqua, t) ?? accentAqua,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t) ?? accentWarm,
      textPrimary:
          Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
    );
  }
}

/// Skema warna latar belakang dinamis untuk tiap suasana cuaca.
class WeatherBackgroundScheme {
  final List<Color> gradientColors;
  final Color primaryBlob;
  final Color secondaryBlob;
  final Color glassTint;

  const WeatherBackgroundScheme({
    required this.gradientColors,
    required this.primaryBlob,
    required this.secondaryBlob,
    required this.glassTint,
  });
}

/// Kelas penyedia ThemeData utama aplikasi cuaca.
class AppTheme {
  static const Color _primaryTeal = Color(0xFF14B8A6);
  static const Color _secondarySky = Color(0xFF38BDF8);
  static const Color _surfaceDark = Color(0xFF0E1E3E);
  static const Color _errorCoral = Color(0xFFFB7185);
  static const Color _textLight = Color(0xFFF8FAFC);

  /// Theme utama aplikasi berbasis Material 3 dengan gaya glassmorphism.
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryTeal,
      onPrimary: Color(0xFF042F2E),
      secondary: _secondarySky,
      onSecondary: Color(0xFF082F49),
      error: _errorCoral,
      onError: Colors.white,
      surface: _surfaceDark,
      onSurface: _textLight,
    );

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 84,
          fontWeight: FontWeight.w200,
          letterSpacing: -3.0,
          height: 1.0,
          color: _textLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: _textLight,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: _textLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _textLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _textLight,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: Color(0xFFDCE7F3),
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Color(0xFF9FB4C9),
        ),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surfaceDark,
      textTheme: baseTextTheme,
      extensions: const <ThemeExtension<dynamic>>[
        WeatherPalette.standard,
      ],

      // AppBar transparan dengan status bar ikon terang
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _textLight,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Input decoration default untuk kolom pencarian kaca
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: _secondarySky.withValues(alpha: 0.65),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9FB4C9),
          fontWeight: FontWeight.w400,
        ),
      ),

      // Transisi halaman halus antar screen
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),

      // Tombol utama berbentuk kapsul
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          foregroundColor: _textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
