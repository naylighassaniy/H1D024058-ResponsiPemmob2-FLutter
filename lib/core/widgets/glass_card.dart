// glass_card.dart
// Widget reusable bergaya kaca buram transparan (glassmorphism).
// Menggunakan ClipRRect + BackdropFilter dengan isi gradien bertint warna,
// border tipis 1px semi-transparan, dan bayangan lembut.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kartu kaca buram berwarna yang mengambil gaya dasar dari [WeatherPalette].
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? tint;
  final double? blurSigma;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.tint,
    this.blurSigma,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    final effectiveRadius = radius ?? palette.glassRadius;
    final effectiveSigma = blurSigma ?? palette.glassBlurSigma;
    final effectiveTint = tint ?? palette.glassTint;
    final borderRadius = BorderRadius.circular(effectiveRadius);

    // Lapisan kaca: blur latar belakang + gradien warna bertint + border tipis 1px
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        // Gradien transparan bertint warna (bukan putih polos)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(
              Colors.white.withValues(alpha: palette.glassFillOpacity + 0.06),
              effectiveTint.withValues(alpha: palette.glassFillOpacity + 0.08),
              0.4,
            )!,
            Color.lerp(
              Colors.white.withValues(alpha: palette.glassFillOpacity - 0.04),
              effectiveTint.withValues(alpha: palette.glassFillOpacity),
              0.55,
            )!,
          ],
        ),
        // Border tipis 1 px semi-transparan untuk efek tepi kaca
        border: Border.all(
          color: Colors.white.withValues(alpha: palette.glassBorderOpacity),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: content,
        ),
      );
    }

    // Container luar memberi bayangan lembut tanpa merusak ClipRRect blur
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveSigma,
            sigmaY: effectiveSigma,
          ),
          child: content,
        ),
      ),
    );
  }
}
