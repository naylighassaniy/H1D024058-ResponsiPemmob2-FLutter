// api_constants.dart
// File ini berisi semua URL dan parameter API yang digunakan aplikasi.
// Disimpan di satu tempat agar mudah diubah dan konsisten.

/// Kelas berisi konstanta URL dan parameter untuk API Open-Meteo.
class ApiConstants {
  // === BASE URL ===
  /// URL dasar untuk Geocoding API (mencari kota berdasarkan nama)
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  /// URL dasar untuk Weather Forecast API (mengambil data cuaca)
  static const String forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  // === PARAMETER GEOCODING ===
  /// Jumlah maksimal hasil pencarian kota
  static const int geocodingCount = 10;

  /// Bahasa hasil pencarian
  static const String geocodingLanguage = 'id';

  // === PARAMETER FORECAST ===
  /// Data cuaca terkini yang diminta dari API (termasuk is_day untuk tema siang/malam)
  static const String currentParams =
      'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m';

  /// Data perkiraan per jam yang diminta dari API (untuk 24 jam ke depan)
  static const String hourlyParams =
      'temperature_2m,weather_code,precipitation_probability';

  /// Data perkiraan harian yang diminta dari API
  static const String dailyParams =
      'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max';

  /// Zona waktu otomatis
  static const String timezone = 'auto';

  /// Jumlah hari perkiraan cuaca
  static const int forecastDays = 7;

  // === TIMEOUT ===
  /// Batas waktu request HTTP dalam detik
  static const int timeoutSeconds = 10;

  // === LOKASI DEFAULT ===
  /// Lokasi default saat pertama kali buka aplikasi (Purwokerto)
  static const String defaultCityName = 'Purwokerto';
  static const double defaultLatitude = -7.4314;
  static const double defaultLongitude = 109.2471;
  static const String defaultCountry = 'Indonesia';
  static const String defaultAdmin1 = 'Central Java';
  static const String defaultTimezone = 'Asia/Jakarta';
}
