// current_weather_hero.dart
// Widget bagian atas (hero) Home Screen yang menampilkan ikon cuaca SVG besar,
// suhu utama ber-font tipis, deskripsi kondisi, rentang suhu hari ini,
// serta suhu yang dirasakan (apparent temperature).

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/weather_code_helper.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../models/current_weather_model.dart';
import '../../../models/daily_forecast_model.dart';

/// Hero cuaca utama pada Home Screen.
class CurrentWeatherHero extends StatelessWidget {
  final CurrentWeatherModel weather;
  final DailyForecastModel? todayForecast;

  const CurrentWeatherHero({
    super.key,
    required this.weather,
    this.todayForecast,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;
    final description = WeatherCodeHelper.getDescription(weather.weatherCode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // Ikon cuaca Meteocons dengan transisi halus saat ganti kota
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: WeatherIcon(
              key: ValueKey('${weather.weatherCode}_${weather.isDay}'),
              weatherCode: weather.weatherCode,
              isDay: weather.isDay,
              size: 132,
            ),
          ),

          const SizedBox(height: 4),

          // Suhu saat ini berukuran besar dan tipis
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature.round()}',
                style: textTheme.displayLarge?.copyWith(
                  color: palette.textPrimary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  weather.temperatureUnit,
                  style: textTheme.headlineMedium?.copyWith(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Kondisi cuaca terkini
          Text(
            description,
            style: textTheme.titleMedium?.copyWith(
              color: palette.textPrimary,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 8),

          // Baris ringkas: Maks / Min hari ini + Terasa seperti
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              if (todayForecast != null)
                Text(
                  'Maks ${todayForecast!.tempMax.round()}°  ·  Min ${todayForecast!.tempMin.round()}°',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              Text(
                'Terasa seperti ${weather.apparentTemperature.round()}${weather.apparentTemperatureUnit}',
                style: textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
