// weather_code_helper.dart
// Memetakan WMO weather code dari API Open-Meteo menjadi:
// 1. Deskripsi cuaca dalam bahasa Indonesia
// 2. Path aset SVG Meteocons (mendukung versi siang dan malam)
// 3. WeatherMood untuk menentukan gradien latar dinamis

import '../theme/app_theme.dart';

/// Kelas helper untuk mapping weather_code ke deskripsi, ikon SVG, dan suasana latar.
class WeatherCodeHelper {
  static const String _basePath = 'assets/icons/weather';

  // Path ikon detail cuaca (dari set Meteocons yang sama)
  static const String humidityIcon = '$_basePath/humidity.svg';
  static const String windIcon = '$_basePath/wind.svg';
  static const String raindropIcon = '$_basePath/raindrop.svg';
  static const String umbrellaIcon = '$_basePath/umbrella.svg';
  static const String thermometerIcon = '$_basePath/thermometer.svg';
  static const String notAvailableIcon = '$_basePath/not-available.svg';

  /// Mendapatkan deskripsi cuaca dalam bahasa Indonesia dari WMO weather code.
  static String getDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah Berawan';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Berawan';
      case 45:
        return 'Berkabut';
      case 48:
        return 'Kabut Tebal';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
        return 'Gerimis Dingin';
      case 57:
        return 'Gerimis Dingin Lebat';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
        return 'Hujan Dingin';
      case 67:
        return 'Hujan Dingin Lebat';
      case 71:
        return 'Salju Ringan';
      case 73:
        return 'Salju Sedang';
      case 75:
        return 'Salju Lebat';
      case 77:
        return 'Butiran Salju';
      case 80:
        return 'Hujan Deras Sesaat';
      case 81:
        return 'Hujan Sangat Lebat';
      case 82:
        return 'Hujan Ekstrem';
      case 85:
        return 'Hujan Salju Ringan';
      case 86:
        return 'Hujan Salju Lebat';
      case 95:
        return 'Badai Petir';
      case 96:
        return 'Badai & Hujan Es';
      case 99:
        return 'Badai Petir Hebat';
      default:
        return 'Tidak Diketahui';
    }
  }

  /// Mendapatkan path aset SVG Meteocons sesuai weather code dan status siang/malam.
  static String getIconPath(int code, {bool isDay = true}) {
    switch (code) {
      case 0:
        return '$_basePath/${isDay ? 'clear-day' : 'clear-night'}.svg';
      case 1:
      case 2:
        return '$_basePath/${isDay ? 'partly-cloudy-day' : 'partly-cloudy-night'}.svg';
      case 3:
        return '$_basePath/${isDay ? 'overcast-day' : 'overcast-night'}.svg';
      case 45:
      case 48:
        return '$_basePath/${isDay ? 'fog-day' : 'fog-night'}.svg';
      case 51:
      case 53:
      case 56:
        return '$_basePath/${isDay ? 'partly-cloudy-day-drizzle' : 'partly-cloudy-night-drizzle'}.svg';
      case 55:
      case 57:
        return '$_basePath/drizzle.svg';
      case 61:
      case 66:
        return '$_basePath/${isDay ? 'partly-cloudy-day-rain' : 'partly-cloudy-night-rain'}.svg';
      case 63:
      case 80:
        return '$_basePath/rain.svg';
      case 65:
      case 67:
      case 81:
      case 82:
        return '$_basePath/extreme-rain.svg';
      case 71:
      case 73:
        return '$_basePath/${isDay ? 'partly-cloudy-day-snow' : 'partly-cloudy-night-snow'}.svg';
      case 75:
      case 77:
        return '$_basePath/snow.svg';
      case 85:
      case 86:
        return '$_basePath/sleet.svg';
      case 95:
        return '$_basePath/${isDay ? 'thunderstorms-day' : 'thunderstorms-night'}.svg';
      case 96:
      case 99:
        return '$_basePath/${isDay ? 'thunderstorms-day-rain' : 'thunderstorms-night-rain'}.svg';
      default:
        return notAvailableIcon;
    }
  }

  /// Menentukan suasana warna latar belakang berdasarkan weather code dan siang/malam.
  static WeatherMood getMood(int code, {bool isDay = true}) {
    // Badai petir tetap menggunakan tema badai baik siang maupun malam
    if (code >= 95) {
      return WeatherMood.storm;
    }
    // Hujan deras/lebat
    if (code == 65 || code == 67 || (code >= 80 && code <= 82)) {
      return WeatherMood.rain;
    }
    // Kabut
    if (code == 45 || code == 48) {
      return isDay ? WeatherMood.fog : WeatherMood.night;
    }
    // Jika malam hari (selain badai/hujan lebat), gunakan palet malam
    if (!isDay) {
      return WeatherMood.night;
    }
    // Siang hari berdasarkan kondisi
    if (code == 0 || code == 1) {
      return WeatherMood.clearDay;
    }
    if (code == 2 || code == 3 || (code >= 71 && code <= 77) || code == 85 || code == 86) {
      return WeatherMood.cloudy;
    }
    if ((code >= 51 && code <= 67)) {
      return WeatherMood.rain;
    }
    return WeatherMood.clearDay;
  }
}
