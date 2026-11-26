// current_weather_model.dart
// Model ini merepresentasikan data cuaca terkini (current weather)
// yang didapat dari Weather Forecast API Open-Meteo.

/// Model data cuaca saat ini dari API.
class CurrentWeatherModel {
  final double temperature; // Suhu saat ini (°C)
  final int humidity; // Kelembapan udara (%)
  final double apparentTemperature; // Suhu yang dirasakan (°C)
  final bool isDay; // Status siang (true) atau malam (false)
  final double precipitation; // Curah hujan (mm)
  final int weatherCode; // Kode kondisi cuaca (WMO)
  final double windSpeed; // Kecepatan angin (km/h)

  // Satuan dari API
  final String temperatureUnit;
  final String humidityUnit;
  final String apparentTemperatureUnit;
  final String precipitationUnit;
  final String windSpeedUnit;

  CurrentWeatherModel({
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.isDay,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    this.temperatureUnit = '°C',
    this.humidityUnit = '%',
    this.apparentTemperatureUnit = '°C',
    this.precipitationUnit = 'mm',
    this.windSpeedUnit = 'km/h',
  });

  /// Membuat model dari JSON response API.
  /// [currentJson] = bagian "current" dari response.
  /// [unitsJson] = bagian "current_units" dari response (untuk satuan).
  factory CurrentWeatherModel.fromJson(
    Map<String, dynamic> currentJson,
    Map<String, dynamic>? unitsJson,
  ) {
    // Open-Meteo mengembalikan is_day berupa integer 1 (siang) atau 0 (malam)
    final isDayValue = currentJson['is_day'];
    final bool isDay = isDayValue == null ? true : (isDayValue == 1 || isDayValue == true);

    return CurrentWeatherModel(
      temperature: (currentJson['temperature_2m'] ?? 0).toDouble(),
      humidity: (currentJson['relative_humidity_2m'] ?? 0).toInt(),
      apparentTemperature:
          (currentJson['apparent_temperature'] ?? 0).toDouble(),
      isDay: isDay,
      precipitation: (currentJson['precipitation'] ?? 0).toDouble(),
      weatherCode: (currentJson['weather_code'] ?? 0).toInt(),
      windSpeed: (currentJson['wind_speed_10m'] ?? 0).toDouble(),
      // Ambil satuan dari response jika tersedia
      temperatureUnit: unitsJson?['temperature_2m'] ?? '°C',
      humidityUnit: unitsJson?['relative_humidity_2m'] ?? '%',
      apparentTemperatureUnit: unitsJson?['apparent_temperature'] ?? '°C',
      precipitationUnit: unitsJson?['precipitation'] ?? 'mm',
      windSpeedUnit: unitsJson?['wind_speed_10m'] ?? 'km/h',
    );
  }
}
