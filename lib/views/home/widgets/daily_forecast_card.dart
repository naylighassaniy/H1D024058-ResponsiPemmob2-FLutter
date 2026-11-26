// daily_forecast_card.dart
// Kartu besar berisi perkiraan cuaca 7 hari ke depan.
// Menampilkan nama hari, ikon cuaca SVG, peluang hujan, suhu min/max,
// dan bar rentang suhu yang proporsional terhadap rentang suhu mingguan.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../models/daily_forecast_model.dart';

/// Kartu besar daftar perkiraan cuaca harian (7 hari).
class DailyForecastCard extends StatelessWidget {
  final List<DailyForecastModel> forecasts;

  const DailyForecastCard({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    // Hitung suhu terendah dan tertinggi dalam satu minggu untuk skala bar rentang suhu
    double weekMin = forecasts.first.tempMin;
    double weekMax = forecasts.first.tempMax;
    for (final item in forecasts) {
      weekMin = math.min(weekMin, item.tempMin);
      weekMax = math.max(weekMax, item.tempMax);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Perkiraan 7 Hari',
              style: textTheme.titleMedium?.copyWith(
                color: palette.textPrimary,
              ),
            ),
          ),
          GlassCard(
            radius: 24,
            blurSigma: 14,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: List.generate(forecasts.length, (index) {
                final item = forecasts[index];
                return Column(
                  children: [
                    _DailyForecastRow(
                      forecast: item,
                      isToday: index == 0,
                      weekMin: weekMin,
                      weekMax: weekMax,
                    ),
                    if (index < forecasts.length - 1)
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris tunggal perkiraan cuaca harian dengan bar rentang suhu proporsional.
class _DailyForecastRow extends StatelessWidget {
  final DailyForecastModel forecast;
  final bool isToday;
  final double weekMin;
  final double weekMax;

  const _DailyForecastRow({
    required this.forecast,
    required this.isToday,
    required this.weekMin,
    required this.weekMax,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    String dayLabel;
    String dateLabel = '';
    try {
      final date = DateTime.parse(forecast.date);
      dayLabel = isToday ? 'Hari Ini' : _shortIndonesianDay(date);
      dateLabel = DateFormat('d MMM').format(date);
    } catch (_) {
      dayLabel = forecast.date;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Nama hari & tanggal
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (dateLabel.isNotEmpty)
                  Text(
                    dateLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: palette.textMuted,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),

          // Ikon kondisi cuaca (siang)
          WeatherIcon(
            weatherCode: forecast.weatherCode,
            isDay: true,
            size: 32,
          ),

          const SizedBox(width: 8),

          // Peluang hujan dengan warna aksen
          SizedBox(
            width: 38,
            child: Text(
              '${forecast.precipitationProbability}%',
              style: textTheme.labelSmall?.copyWith(
                color: forecast.precipitationProbability >= 30
                    ? palette.accentAqua
                    : palette.textMuted,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 8),

          // Suhu minimum
          SizedBox(
            width: 30,
            child: Text(
              '${forecast.tempMin.round()}°',
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          const SizedBox(width: 8),

          // Bar rentang suhu relatif terhadap min/max mingguan
          Expanded(
            child: _TemperatureRangeBar(
              min: forecast.tempMin,
              max: forecast.tempMax,
              weekMin: weekMin,
              weekMax: weekMax,
            ),
          ),

          const SizedBox(width: 8),

          // Suhu maksimum
          SizedBox(
            width: 30,
            child: Text(
              '${forecast.tempMax.round()}°',
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Mengubah weekday menjadi singkatan hari bahasa Indonesia.
  String _shortIndonesianDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }
}

/// Garis kapsul tipis yang menunjukkan posisi min-max hari ini relatif terhadap minggu ini.
class _TemperatureRangeBar extends StatelessWidget {
  final double min;
  final double max;
  final double weekMin;
  final double weekMax;

  const _TemperatureRangeBar({
    required this.min,
    required this.max,
    required this.weekMin,
    required this.weekMax,
  });

  @override
  Widget build(BuildContext context) {
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    final totalSpan = (weekMax - weekMin).abs();
    final startFraction = totalSpan > 0.1
        ? ((min - weekMin) / totalSpan).clamp(0.0, 0.85)
        : 0.0;
    final lengthFraction = totalSpan > 0.1
        ? ((max - min) / totalSpan).clamp(0.15, 1.0 - startFraction)
        : 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        final leftOffset = fullWidth * startFraction;
        final barWidth = math.max(8.0, fullWidth * lengthFraction);

        return Container(
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              Positioned(
                left: leftOffset,
                width: barWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        palette.accentAqua,
                        palette.accentWarm,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
