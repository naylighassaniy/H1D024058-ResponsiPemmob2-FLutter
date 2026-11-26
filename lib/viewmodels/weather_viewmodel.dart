// weather_viewmodel.dart
// ViewModel ini mengelola state untuk Home/Weather Screen.
// Bertanggung jawab untuk: memuat cuaca, mengelola favorit,
// dan menangani state loading/success/empty/error.
// Menggunakan ChangeNotifier agar View otomatis ter-update.

import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../models/location_model.dart';
import '../models/weather_response_model.dart';
import '../repositories/weather_repository.dart';
import '../repositories/location_storage_repository.dart';

/// Enum untuk status tampilan (memudahkan pengecekan state di View).
enum ViewState { initial, loading, success, empty, error }

/// ViewModel untuk Home Screen — mengelola data cuaca dan lokasi aktif.
class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _weatherRepository;
  final LocationStorageRepository _storageRepository;

  // === STATE ===
  ViewState _state = ViewState.initial; // Status tampilan saat ini
  WeatherResponseModel? _weatherData; // Data cuaca yang ditampilkan
  LocationModel? _currentLocation; // Lokasi yang sedang aktif
  String _errorMessage = ''; // Pesan error jika ada
  bool _isFavorite = false; // Apakah lokasi aktif ada di favorit
  List<LocationModel> _favorites = []; // Daftar lokasi favorit

  // === GETTERS ===
  // Getter agar View bisa membaca state tanpa mengubahnya langsung
  ViewState get state => _state;
  WeatherResponseModel? get weatherData => _weatherData;
  LocationModel? get currentLocation => _currentLocation;
  String get errorMessage => _errorMessage;
  bool get isFavorite => _isFavorite;
  List<LocationModel> get favorites => _favorites;

  WeatherViewModel({
    WeatherRepository? weatherRepository,
    LocationStorageRepository? storageRepository,
  })  : _weatherRepository = weatherRepository ?? WeatherRepository(),
        _storageRepository =
            storageRepository ?? LocationStorageRepository();

  /// Inisialisasi saat aplikasi pertama kali dibuka.
  /// Memuat lokasi terakhir dari storage, lalu ambil cuaca dari API.
  Future<void> initialize() async {
    // Muat daftar favorit dari local storage
    _favorites = await _storageRepository.loadFavorites();

    // Muat lokasi terakhir yang dipilih
    final lastLocation = await _storageRepository.loadLastLocation();

    if (lastLocation != null) {
      // Jika ada lokasi terakhir, gunakan itu
      await fetchWeather(lastLocation);
    } else {
      // Jika belum pernah memilih, gunakan lokasi default (Purwokerto)
      final defaultLocation = LocationModel(
        id: 0,
        name: ApiConstants.defaultCityName,
        latitude: ApiConstants.defaultLatitude,
        longitude: ApiConstants.defaultLongitude,
        country: ApiConstants.defaultCountry,
        admin1: ApiConstants.defaultAdmin1,
        timezone: ApiConstants.defaultTimezone,
      );
      await fetchWeather(defaultLocation);
    }
  }

  /// Mengambil data cuaca untuk lokasi tertentu dari API.
  /// Ini dipanggil saat user memilih kota baru atau refresh.
  Future<void> fetchWeather(LocationModel location) async {
    // Set state loading dan beritahu View
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Request data cuaca ke API melalui repository
      final weather = await _weatherRepository.getWeather(
        location.latitude,
        location.longitude,
      );

      // Simpan data dan update state
      _weatherData = weather;
      _currentLocation = location;
      _state = ViewState.success;

      // Cek apakah lokasi ini ada di favorit
      _isFavorite = _favorites.any((fav) => fav.id == location.id);

      // Simpan sebagai lokasi terakhir di local storage
      await _storageRepository.saveLastLocation(location);
    } catch (e) {
      // Jika gagal, set state error dengan pesan
      _state = ViewState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    // Beritahu View untuk rebuild
    notifyListeners();
  }

  /// Refresh data cuaca (dipanggil oleh pull-to-refresh).
  Future<void> refreshWeather() async {
    if (_currentLocation != null) {
      await fetchWeather(_currentLocation!);
    }
  }

  /// Toggle status favorit untuk lokasi yang sedang aktif.
  Future<void> toggleFavorite() async {
    if (_currentLocation == null) return;

    if (_isFavorite) {
      // Hapus dari favorit
      _favorites =
          await _storageRepository.removeFavorite(_currentLocation!);
      _isFavorite = false;
    } else {
      // Tambah ke favorit
      _favorites = await _storageRepository.addFavorite(_currentLocation!);
      _isFavorite = true;
    }

    notifyListeners();
  }

  /// Sinkronkan ulang daftar favorit dari storage (mis. setelah kembali dari Search).
  Future<void> syncFavorites() async {
    _favorites = await _storageRepository.loadFavorites();
    if (_currentLocation != null) {
      _isFavorite = _favorites.any((fav) => fav.id == _currentLocation!.id);
    }
    notifyListeners();
  }
}
