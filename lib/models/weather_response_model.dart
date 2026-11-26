// weather_response_model.dart
// Model gabungan yang merangkum seluruh response dari Weather Forecast API.
// Berisi data cuaca terkini (current), per jam (hourly), dan harian (daily).

import 'current_weather_model.dart';
import 'daily_forecast_model.dart';
import 'hourly_forecast_model.dart';

/// Model gabungan response cuaca dari API.
class WeatherResponseModel {
  final CurrentWeatherModel current; // Data cuaca saat ini
  final List<HourlyForecastModel> hourlyForecasts; // Perkiraan 24 jam ke depan
  final List<DailyForecastModel> dailyForecasts; // Perkiraan 7 hari

  WeatherResponseModel({
    required this.current,
    required this.hourlyForecasts,
    required this.dailyForecasts,
  });

  /// Membuat WeatherResponseModel dari seluruh JSON response API.
  factory WeatherResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> currentJson = json['current'] ?? {};

    return WeatherResponseModel(
      // Parse bagian "current" dengan satuan dari "current_units"
      current: CurrentWeatherModel.fromJson(
        currentJson,
        json['current_units'],
      ),
      // Parse bagian "hourly" untuk 24 jam ke depan
      hourlyForecasts: HourlyForecastModel.fromJsonList(
        json['hourly'] ?? {},
        json['hourly_units'],
        currentTimeStr: currentJson['time']?.toString(),
      ),
      // Parse bagian "daily" (array paralel) dengan satuan dari "daily_units"
      dailyForecasts: DailyForecastModel.fromJsonList(
        json['daily'] ?? {},
        json['daily_units'],
      ),
    );
  }
}
