// weather_repository.dart
// Repository ini menjadi penghubung antara WeatherApiService dan ViewModel.
// ViewModel tidak langsung memanggil service, tapi melalui repository.
// Ini sesuai pola MVVM agar kode lebih terstruktur.

import '../models/location_model.dart';
import '../models/weather_response_model.dart';
import '../services/weather_api_service.dart';

/// Repository untuk mengakses data cuaca dan pencarian lokasi.
class WeatherRepository {
  final WeatherApiService _apiService;

  WeatherRepository({WeatherApiService? apiService})
      : _apiService = apiService ?? WeatherApiService();

  /// Mencari lokasi berdasarkan nama kota.
  /// Mengembalikan list lokasi yang ditemukan.
  Future<List<LocationModel>> searchLocation(String query) {
    return _apiService.searchLocation(query);
  }

  /// Mengambil data cuaca berdasarkan koordinat latitude & longitude.
  Future<WeatherResponseModel> getWeather(
      double latitude, double longitude) {
    return _apiService.getWeather(latitude, longitude);
  }
}
