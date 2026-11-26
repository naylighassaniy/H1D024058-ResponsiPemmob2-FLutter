// weather_background.dart
// Latar belakang gradien dinamis yang berubah halus sesuai kondisi cuaca
// dan waktu siang/malam, dilengkapi blob gradien lembut di belakang konten
// agar efek kaca (GlassCard) memiliki kedalaman visual.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/weather_code_helper.dart';

/// Latar belakang dinamis berbasis cuaca dan siang/malam.
class WeatherBackground extends StatelessWidget {
  final int? weatherCode;
  final bool isDay;
  final Widget child;

  const WeatherBackground({
    super.key,
    this.weatherCode,
    this.isDay = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mood = weatherCode != null
        ? WeatherCodeHelper.getMood(weatherCode!, isDay: isDay)
        : WeatherMood.clearDay;
    final scheme = WeatherPalette.getScheme(mood);

    return Stack(
      children: [
        // Gradien utama dengan animasi transisi halus 600ms saat ganti kota/cuaca
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: scheme.gradientColors,
            ),
          ),
        ),

        // Blob gradien kanan atas — memberi efek cahaya lembut di balik kaca
        Positioned(
          top: -90,
          right: -70,
          child: _AmbientBlob(
            size: 320,
            color: scheme.primaryBlob.withValues(alpha: 0.34),
          ),
        ),

        // Blob gradien kiri tengah
        Positioned(
          top: 220,
          left: -110,
          child: _AmbientBlob(
            size: 280,
            color: scheme.secondaryBlob.withValues(alpha: 0.25),
          ),
        ),

        // Blob gradien kanan bawah
        Positioned(
          bottom: -100,
          right: -50,
          child: _AmbientBlob(
            size: 300,
            color: scheme.primaryBlob.withValues(alpha: 0.22),
          ),
        ),

        // Lapisan kontras halus agar teks di atas kaca selalu terbaca jelas
        Container(
          color: Colors.black.withValues(alpha: 0.08),
        ),

        // Konten utama layar
        child,
      ],
    );
  }
}

/// Lingkaran gradien radial lembut (tanpa shadow berlebih) untuk kedalaman latar.
class _AmbientBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _AmbientBlob({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}
