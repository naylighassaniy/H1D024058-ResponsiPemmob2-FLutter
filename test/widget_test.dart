// widget_test.dart
// Pengujian dasar untuk memastikan model response API ter-parse dengan benar
// dan aplikasi dapat diinisialisasi tanpa error.

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/utils/weather_code_helper.dart';
import 'package:weather_app/core/theme/app_theme.dart';
import 'package:weather_app/models/weather_response_model.dart';

void main() {
  group('WeatherResponseModel parsing', () {
    test('berhasil mem-parse current, hourly, dan daily beserta is_day', () {
      final sampleJson = {
        'current_units': {
          'temperature_2m': '°C',
          'relative_humidity_2m': '%',
          'apparent_temperature': '°C',
          'precipitation': 'mm',
          'wind_speed_10m': 'km/h',
        },
        'current': {
          'time': '2026-11-26T06:00',
          'temperature_2m': 27.5,
          'relative_humidity_2m': 78,
          'apparent_temperature': 30.1,
          'is_day': 1,
          'precipitation': 0.2,
          'weather_code': 2,
          'wind_speed_10m': 11.4,
        },
        'hourly_units': {
          'temperature_2m': '°C',
        },
        'hourly': {
          'time': ['2026-11-26T06:00', '2026-11-26T07:00'],
          'temperature_2m': [27.5, 28.4],
          'weather_code': [2, 1],
          'precipitation_probability': [15, 10],
        },
        'daily_units': {
          'temperature_2m_max': '°C',
          'precipitation_probability_max': '%',
        },
        'daily': {
          'time': ['2026-11-26', '2026-11-27'],
          'weather_code': [2, 61],
          'temperature_2m_max': [31.0, 29.5],
          'temperature_2m_min': [23.0, 22.8],
          'precipitation_probability_max': [30, 80],
        },
      };

      final parsed = WeatherResponseModel.fromJson(sampleJson);

      expect(parsed.current.temperature, 27.5);
      expect(parsed.current.isDay, true);
      expect(parsed.current.weatherCode, 2);
      expect(parsed.hourlyForecasts.length, 2);
      expect(parsed.hourlyForecasts.first.temperature, 27.5);
      expect(parsed.dailyForecasts.length, 2);
      expect(parsed.dailyForecasts.last.precipitationProbability, 80);
    });
  });

  group('WeatherCodeHelper', () {
    test('membedakan ikon dan mood siang vs malam', () {
      expect(
        WeatherCodeHelper.getIconPath(0, isDay: true),
        'assets/icons/weather/clear-day.svg',
      );
      expect(
        WeatherCodeHelper.getIconPath(0, isDay: false),
        'assets/icons/weather/clear-night.svg',
      );
      expect(
        WeatherCodeHelper.getMood(0, isDay: false),
        WeatherMood.night,
      );
    });
  });
}
