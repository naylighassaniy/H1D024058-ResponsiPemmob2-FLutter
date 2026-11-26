// search_viewmodel.dart
// ViewModel ini mengelola state untuk Search/Location Screen.
// Bertanggung jawab untuk: pencarian kota, mengelola favorit & riwayat,
// serta memuat pratinjau cuaca mini untuk daftar kota favorit (maks. 5 paralel).

import 'package:flutter/foundation.dart';
import '../models/current_weather_model.dart';
import '../models/location_model.dart';
import '../repositories/weather_repository.dart';
import '../repositories/location_storage_repository.dart';

/// Enum untuk status pencarian.
enum SearchState { initial, loading, success, empty, error }

/// ViewModel untuk Search Screen — mengelola pencarian dan data tersimpan.
class SearchViewModel extends ChangeNotifier {
  final WeatherRepository _weatherRepository;
  final LocationStorageRepository _storageRepository;

  // === STATE ===
  SearchState _state = SearchState.initial; // Status pencarian
  List<LocationModel> _searchResults = []; // Hasil pencarian dari API
  List<LocationModel> _favorites = []; // Daftar favorit dari storage
  List<LocationModel> _history = []; // Riwayat pencarian dari storage
  final Map<int, CurrentWeatherModel> _favoriteWeathers = {}; // Cache mini cuaca favorit
  final Set<int> _loadingFavoriteIds = {}; // ID favorit yang sedang dimuat cuacanya
  String _errorMessage = ''; // Pesan error
  String _currentQuery = ''; // Query pencarian saat ini

  // === GETTERS ===
  SearchState get state => _state;
  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get favorites => _favorites;
  List<LocationModel> get history => _history;
  String get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  /// Mengambil data cuaca terkini untuk kota favorit tertentu (jika sudah dimuat).
  CurrentWeatherModel? getFavoriteWeather(int locationId) =>
      _favoriteWeathers[locationId];

  /// Mengecek apakah cuaca mini kota favorit sedang dimuat.
  bool isFavoriteWeatherLoading(int locationId) =>
      _loadingFavoriteIds.contains(locationId);

  SearchViewModel({
    WeatherRepository? weatherRepository,
    LocationStorageRepository? storageRepository,
  })  : _weatherRepository = weatherRepository ?? WeatherRepository(),
        _storageRepository =
            storageRepository ?? LocationStorageRepository();

  /// Memuat data favorit dan riwayat dari local storage.
  /// Dipanggil saat screen pertama kali dibuka.
  Future<void> loadSavedData() async {
    _favorites = await _storageRepository.loadFavorites();
    _history = await _storageRepository.loadHistory();
    notifyListeners();

    // Muat pratinjau cuaca mini untuk maksimal 5 kota favorit secara paralel
    await _loadFavoriteWeatherPreviews();
  }

  /// Mengambil suhu & ikon cuaca terkini untuk maksimal 5 lokasi favorit secara paralel.
  Future<void> _loadFavoriteWeatherPreviews() async {
    final targets = _favorites
        .take(5)
        .where((loc) => !_favoriteWeathers.containsKey(loc.id))
        .toList();

    if (targets.isEmpty) return;

    for (final loc in targets) {
      _loadingFavoriteIds.add(loc.id);
    }
    notifyListeners();

    await Future.wait(
      targets.map((loc) async {
        try {
          final response = await _weatherRepository.getWeather(
            loc.latitude,
            loc.longitude,
          );
          _favoriteWeathers[loc.id] = response.current;
        } catch (_) {
          // Abaikan jika gagal memuat pratinjau satu kota agar UI tetap berjalan
        } finally {
          _loadingFavoriteIds.remove(loc.id);
        }
      }),
    );

    notifyListeners();
  }

  /// Mencari lokasi berdasarkan nama kota.
  /// Memanggil Geocoding API melalui repository.
  Future<void> searchLocation(String query) async {
    // Minimal 2 karakter untuk mencari
    if (query.trim().length < 2) {
      _state = SearchState.initial;
      _searchResults = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _currentQuery = query;
    _state = SearchState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Request ke Geocoding API
      final results = await _weatherRepository.searchLocation(query);

      if (results.isEmpty) {
        // Tidak ada hasil ditemukan
        _state = SearchState.empty;
        _searchResults = [];
      } else {
        // Ada hasil
        _state = SearchState.success;
        _searchResults = results;
      }
    } catch (e) {
      // Error saat request
      _state = SearchState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _searchResults = [];
    }

    notifyListeners();
  }

  /// Menambah lokasi yang dipilih ke riwayat pencarian.
  Future<void> addToHistory(LocationModel location) async {
    _history = await _storageRepository.addToHistory(location);
    notifyListeners();
  }

  /// Menghapus satu item dari riwayat.
  Future<void> removeFromHistory(LocationModel location) async {
    _history = await _storageRepository.removeFromHistory(location);
    notifyListeners();
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clearHistory() async {
    await _storageRepository.clearHistory();
    _history = [];
    notifyListeners();
  }

  /// Toggle favorit untuk lokasi tertentu.
  Future<void> toggleFavorite(LocationModel location) async {
    final isFav = _favorites.any((fav) => fav.id == location.id);

    if (isFav) {
      _favorites = await _storageRepository.removeFavorite(location);
      _favoriteWeathers.remove(location.id);
    } else {
      _favorites = await _storageRepository.addFavorite(location);
      notifyListeners();
      await _loadFavoriteWeatherPreviews();
      return;
    }

    notifyListeners();
  }

  /// Cek apakah lokasi ada di favorit.
  bool isFavorite(int locationId) {
    return _favorites.any((fav) => fav.id == locationId);
  }

  /// Reset state pencarian (saat user mengosongkan kolom pencarian).
  void resetSearch() {
    _state = SearchState.initial;
    _searchResults = [];
    _currentQuery = '';
    notifyListeners();
  }
}
