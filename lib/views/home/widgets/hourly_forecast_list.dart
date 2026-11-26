// hourly_forecast_list.dart
// Widget daftar perkiraan cuaca per jam (24 jam ke depan) dalam bentuk
// kapsul kaca horizontal yang ringan dan halus saat di-scroll.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../models/hourly_forecast_model.dart';

/// List horizontal perkiraan cuaca per jam untuk 24 jam ke depan.
class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecastModel> forecasts;

  const HourlyForecastList({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Text(
            'Perkiraan Per Jam',
            style: textTheme.titleMedium?.copyWith(
              color: palette.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: forecasts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = forecasts[index];
              final isFirst = index == 0;

              // RepaintBoundary menjaga performa scroll saat ada BackdropFilter ringan
              return RepaintBoundary(
                child: _HourlyCapsule(
                  item: item,
                  isNow: isFirst,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Satu kapsul kaca vertikal berisi jam, ikon cuaca, dan suhu.
class _HourlyCapsule extends StatelessWidget {
  final HourlyForecastModel item;
  final bool isNow;

  const _HourlyCapsule({
    required this.item,
    required this.isNow,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    String timeLabel;
    if (isNow) {
      timeLabel = 'Sekarang';
    } else {
      try {
        final dt = DateTime.parse(item.time);
        timeLabel = DateFormat('HH:mm').format(dt);
      } catch (_) {
        timeLabel = item.time;
      }
    }

    return SizedBox(
      width: 74,
      child: GlassCard(
        radius: 22,
        blurSigma: 10,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        tint: isNow ? palette.accentAqua : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeLabel,
              style: textTheme.labelSmall?.copyWith(
                color: isNow ? palette.textPrimary : palette.textSecondary,
                fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            WeatherIcon(
              weatherCode: item.weatherCode,
              isDay: item.isDay,
              size: 36,
            ),
            Column(
              children: [
                Text(
                  '${item.temperature.round()}°',
                  style: textTheme.bodyLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.precipitationProbability >= 15)
                  Text(
                    '${item.precipitationProbability}%',
                    style: textTheme.labelSmall?.copyWith(
                      color: palette.accentAqua,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
