// weather_api_service.dart
// File ini menangani semua HTTP request ke API Open-Meteo.
// Ada 2 fungsi utama: mencari kota (geocoding) dan mengambil cuaca (forecast).
// Semua request menggunakan metode GET dengan timeout 10 detik.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/location_model.dart';
import '../models/weather_response_model.dart';

/// Service untuk mengakses API Open-Meteo (Geocoding & Forecast).
class WeatherApiService {
  /// Mencari lokasi/kota berdasarkan nama menggunakan Geocoding API.
  /// Mengembalikan list LocationModel dari hasil pencarian.
  /// Melempar exception jika request gagal.
  Future<List<LocationModel>> searchLocation(String query) async {
    try {
      // Buat URL dengan parameter pencarian
      final uri = Uri.parse(ApiConstants.geocodingBaseUrl).replace(
        queryParameters: {
          'name': query,
          'count': ApiConstants.geocodingCount.toString(),
          'language': ApiConstants.geocodingLanguage,
          'format': 'json',
        },
      );

      // Kirim HTTP GET request dengan timeout
      final response = await http
          .get(uri)
          .timeout(Duration(seconds: ApiConstants.timeoutSeconds));

      // Cek status code
      if (response.statusCode != 200) {
        throw Exception(
            'Gagal mencari lokasi. Kode status: ${response.statusCode}');
      }

      // Parse JSON response
      final data = json.decode(response.body);

      // Jika key 'results' tidak ada, berarti hasil kosong
      if (data['results'] == null) {
        return []; // Kembalikan list kosong
      }

      // Konversi setiap item JSON menjadi LocationModel
      final List<dynamic> results = data['results'];
      return results.map((item) => LocationModel.fromJson(item)).toList();
    } catch (e) {
      // Tangkap error dan lempar kembali dengan pesan yang ramah
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('timeout')) {
        throw Exception(
            'Koneksi timeout. Periksa koneksi internet Anda dan coba lagi.');
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }
      // Jika exception sudah berisi pesan kita, teruskan saja
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan saat mencari lokasi: $e');
    }
  }

  /// Mengambil data cuaca (current + daily forecast) berdasarkan koordinat.
  /// Mengembalikan WeatherResponseModel.
  /// Melempar exception jika request gagal.
  Future<WeatherResponseModel> getWeather(
      double latitude, double longitude) async {
    try {
      // Buat URL dengan parameter cuaca sesuai ketentuan
      final uri = Uri.parse(ApiConstants.forecastBaseUrl).replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current': ApiConstants.currentParams,
          'hourly': ApiConstants.hourlyParams,
          'daily': ApiConstants.dailyParams,
          'timezone': ApiConstants.timezone,
          'forecast_days': ApiConstants.forecastDays.toString(),
        },
      );

      // Kirim HTTP GET request dengan timeout
      final response = await http
          .get(uri)
          .timeout(Duration(seconds: ApiConstants.timeoutSeconds));

      // Cek status code
      if (response.statusCode != 200) {
        throw Exception(
            'Gagal mengambil data cuaca. Kode status: ${response.statusCode}');
      }

      // Parse JSON dan konversi ke model
      final data = json.decode(response.body);
      return WeatherResponseModel.fromJson(data);
    } catch (e) {
      // Tangkap error dan lempar pesan yang ramah
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('timeout')) {
        throw Exception(
            'Koneksi timeout. Periksa koneksi internet Anda dan coba lagi.');
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan saat mengambil data cuaca: $e');
    }
  }
}
