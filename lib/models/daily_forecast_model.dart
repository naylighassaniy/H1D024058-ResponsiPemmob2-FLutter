// daily_forecast_model.dart
// Model ini merepresentasikan data perkiraan cuaca SATU hari.
// API mengembalikan array paralel, jadi kita gabungkan per indeks
// menjadi list DailyForecastModel.

/// Model data perkiraan cuaca harian.
class DailyForecastModel {
  final String date; // Tanggal (format: "2024-01-01")
  final int weatherCode; // Kode kondisi cuaca (WMO)
  final double tempMax; // Suhu maksimum hari itu (°C)
  final double tempMin; // Suhu minimum hari itu (°C)
  final int precipitationProbability; // Peluang hujan maksimum (%)

  // Satuan
  final String tempUnit;
  final String precipUnit;

  DailyForecastModel({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbability,
    this.tempUnit = '°C',
    this.precipUnit = '%',
  });

  /// Membuat LIST dari JSON response API.
  /// Karena API mengembalikan array paralel (time[], temp_max[], dst),
  /// kita iterasi per indeks dan buat objek per hari.
  static List<DailyForecastModel> fromJsonList(
    Map<String, dynamic> dailyJson,
    Map<String, dynamic>? unitsJson,
  ) {
    final List<dynamic> times = dailyJson['time'] ?? [];
    final List<dynamic> weatherCodes = dailyJson['weather_code'] ?? [];
    final List<dynamic> tempMaxList = dailyJson['temperature_2m_max'] ?? [];
    final List<dynamic> tempMinList = dailyJson['temperature_2m_min'] ?? [];
    final List<dynamic> precipProbList =
        dailyJson['precipitation_probability_max'] ?? [];

    final String tempUnit = unitsJson?['temperature_2m_max'] ?? '°C';
    final String precipUnit =
        unitsJson?['precipitation_probability_max'] ?? '%';

    List<DailyForecastModel> forecasts = [];

    for (int i = 0; i < times.length; i++) {
      forecasts.add(DailyForecastModel(
        date: times[i].toString(),
        weatherCode: (weatherCodes.length > i ? weatherCodes[i] : 0).toInt(),
        tempMax: (tempMaxList.length > i ? tempMaxList[i] : 0).toDouble(),
        tempMin: (tempMinList.length > i ? tempMinList[i] : 0).toDouble(),
        precipitationProbability:
            (precipProbList.length > i ? precipProbList[i] : 0).toInt(),
        tempUnit: tempUnit,
        precipUnit: precipUnit,
      ));
    }

    return forecasts;
  }
}
