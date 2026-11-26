// weather_detail_grid.dart
// Grid 2 kolom berisi GlassCard kecil untuk menampilkan metrik detail cuaca:
// Kelembapan, Kecepatan Angin, Kemungkinan Hujan, Curah Hujan, dan Suhu Terasa.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/weather_code_helper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/current_weather_model.dart';

/// Grid detail cuaca 2 kolom bergaya glassmorphism.
class WeatherDetailGrid extends StatelessWidget {
  final CurrentWeatherModel weather;
  final int todayPrecipitationProbability;

  const WeatherDetailGrid({
    super.key,
    required this.weather,
    required this.todayPrecipitationProbability,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Kondisi Detail',
              style: textTheme.titleMedium?.copyWith(
                color: palette.textPrimary,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final halfWidth = (constraints.maxWidth - spacing) / 2;

              return Column(
                children: [
                  Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: halfWidth,
                        child: _DetailMetricCard(
                          iconPath: WeatherCodeHelper.humidityIcon,
                          label: 'KELEMBAPAN',
                          value: '${weather.humidity}${weather.humidityUnit}',
                        ),
                      ),
                      SizedBox(
                        width: halfWidth,
                        child: _DetailMetricCard(
                          iconPath: WeatherCodeHelper.windIcon,
                          label: 'KECEPATAN ANGIN',
                          value:
                              '${weather.windSpeed.toStringAsFixed(1)} ${weather.windSpeedUnit}',
                        ),
                      ),
                      SizedBox(
                        width: halfWidth,
                        child: _DetailMetricCard(
                          iconPath: WeatherCodeHelper.umbrellaIcon,
                          label: 'KEMUNGKINAN HUJAN',
                          value: '$todayPrecipitationProbability%',
                        ),
                      ),
                      SizedBox(
                        width: halfWidth,
                        child: _DetailMetricCard(
                          iconPath: WeatherCodeHelper.raindropIcon,
                          label: 'CURAH HUJAN',
                          value:
                              '${weather.precipitation} ${weather.precipitationUnit}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: spacing),
                  // Kartu lebar penuh untuk Suhu Terasa agar komposisi 5 metrik seimbang
                  _FeelsLikeBannerCard(weather: weather),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Kartu detail metrik individual dengan ikon SVG Meteocons, nilai besar, dan label kecil.
class _DetailMetricCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final String value;

  const _DetailMetricCard({
    required this.iconPath,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    return GlassCard(
      radius: 20,
      blurSigma: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              color: palette.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Kartu kaca untuk Suhu Terasa (apparent_temperature) dengan layout horizontal rapi.
class _FeelsLikeBannerCard extends StatelessWidget {
  final CurrentWeatherModel weather;

  const _FeelsLikeBannerCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    final diff = weather.apparentTemperature - weather.temperature;
    final String note;
    if (diff >= 2) {
      note = 'Terasa lebih hangat karena kelembapan udara';
    } else if (diff <= -2) {
      note = 'Terasa lebih sejuk karena hembusan angin';
    } else {
      note = 'Mendekati suhu udara aktual';
    }

    return GlassCard(
      radius: 20,
      blurSigma: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SvgPicture.asset(
            WeatherCodeHelper.thermometerIcon,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUHU TERASA',
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${weather.apparentTemperature.round()}${weather.apparentTemperatureUnit}',
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
