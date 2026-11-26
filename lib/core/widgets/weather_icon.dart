// weather_icon.dart
// Widget reusable untuk merender ikon cuaca SVG dari set Meteocons.
// Memilih aset sesuai WMO weather_code dan kondisi siang/malam.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/weather_code_helper.dart';

/// Menampilkan ikon cuaca SVG sesuai [weatherCode] dan [isDay].
class WeatherIcon extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final double size;

  const WeatherIcon({
    super.key,
    required this.weatherCode,
    this.isDay = true,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = WeatherCodeHelper.getIconPath(
      weatherCode,
      isDay: isDay,
    );

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
