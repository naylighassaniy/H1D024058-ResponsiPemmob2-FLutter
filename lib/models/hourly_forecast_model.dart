// hourly_forecast_model.dart
// Model ini merepresentasikan data perkiraan cuaca PER JAM.
// API mengembalikan array paralel (time[], temperature_2m[], dll),
// yang digabungkan per indeks untuk 24 jam ke depan.

/// Model data perkiraan cuaca per jam.
class HourlyForecastModel {
  final String time; // Waktu ISO (mis. "2026-11-26T07:00")
  final double temperature; // Suhu pada jam tersebut (°C)
  final int weatherCode; // Kode kondisi cuaca (WMO)
  final int precipitationProbability; // Peluang hujan (%)
  final String tempUnit; // Satuan suhu

  HourlyForecastModel({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    this.tempUnit = '°C',
  });

  /// Mengestimasi apakah jam ini termasuk siang (06:00 - 17:59) atau malam.
  bool get isDay {
    try {
      final dt = DateTime.parse(time);
      return dt.hour >= 6 && dt.hour < 18;
    } catch (_) {
      return true;
    }
  }

  /// Mengambil daftar perkiraan untuk 24 jam ke depan dari JSON response API.
  static List<HourlyForecastModel> fromJsonList(
    Map<String, dynamic> hourlyJson,
    Map<String, dynamic>? unitsJson, {
    String? currentTimeStr,
  }) {
    final List<dynamic> times = hourlyJson['time'] ?? [];
    final List<dynamic> temps = hourlyJson['temperature_2m'] ?? [];
    final List<dynamic> weatherCodes = hourlyJson['weather_code'] ?? [];
    final List<dynamic> precipProbs =
        hourlyJson['precipitation_probability'] ?? [];

    final String tempUnit = unitsJson?['temperature_2m'] ?? '°C';

    // Cari indeks awal berdasarkan jam saat ini dari API (format "YYYY-MM-DDTHH:MM")
    int startIndex = 0;
    if (currentTimeStr != null && currentTimeStr.length >= 13) {
      final currentHourPrefix = currentTimeStr.substring(0, 13); // "YYYY-MM-DDTHH"
      final foundIndex = times.indexWhere(
        (t) => t.toString().startsWith(currentHourPrefix),
      );
      if (foundIndex != -1) {
        startIndex = foundIndex;
      }
    }

    final List<HourlyForecastModel> forecasts = [];
    final int endIndex = (startIndex + 24) < times.length
        ? (startIndex + 24)
        : times.length;

    for (int i = startIndex; i < endIndex; i++) {
      forecasts.add(
        HourlyForecastModel(
          time: times[i].toString(),
          temperature: (temps.length > i && temps[i] != null ? temps[i] : 0)
              .toDouble(),
          weatherCode:
              (weatherCodes.length > i && weatherCodes[i] != null
                      ? weatherCodes[i]
                      : 0)
                  .toInt(),
          precipitationProbability:
              (precipProbs.length > i && precipProbs[i] != null
                      ? precipProbs[i]
                      : 0)
                  .toInt(),
          tempUnit: tempUnit,
        ),
      );
    }

    return forecasts;
  }
}
