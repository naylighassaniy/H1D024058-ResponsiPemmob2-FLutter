// location_storage_repository.dart
// Repository ini menangani penyimpanan lokal (SharedPreferences)
// untuk lokasi favorit, riwayat pencarian, dan lokasi terakhir.
// Data disimpan sebagai JSON string.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

/// Repository untuk menyimpan dan memuat data lokasi dari local storage.
class LocationStorageRepository {
  // Key untuk SharedPreferences
  static const String _favoritesKey = 'favorite_locations';
  static const String _historyKey = 'search_history';
  static const String _lastLocationKey = 'last_location';

  // === LOKASI FAVORIT ===

  /// Memuat daftar lokasi favorit dari local storage.
  Future<List<LocationModel>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return []; // Belum ada data tersimpan
    }

    // Decode JSON string menjadi list of map, lalu konversi ke model
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => LocationModel.fromJson(item)).toList();
  }

  /// Menyimpan daftar lokasi favorit ke local storage.
  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    // Konversi list model ke list map, lalu encode ke JSON string
    final jsonList = favorites.map((loc) => loc.toJson()).toList();
    await prefs.setString(_favoritesKey, json.encode(jsonList));
  }

  /// Menambah lokasi ke favorit (jika belum ada).
  Future<List<LocationModel>> addFavorite(LocationModel location) async {
    final favorites = await loadFavorites();
    // Cek apakah sudah ada di favorit (berdasarkan id)
    if (!favorites.any((fav) => fav.id == location.id)) {
      favorites.add(location);
      await saveFavorites(favorites);
    }
    return favorites;
  }

  /// Menghapus lokasi dari favorit.
  Future<List<LocationModel>> removeFavorite(LocationModel location) async {
    final favorites = await loadFavorites();
    favorites.removeWhere((fav) => fav.id == location.id);
    await saveFavorites(favorites);
    return favorites;
  }

  /// Mengecek apakah lokasi ada di favorit.
  Future<bool> isFavorite(int locationId) async {
    final favorites = await loadFavorites();
    return favorites.any((fav) => fav.id == locationId);
  }

  // === RIWAYAT PENCARIAN ===

  /// Memuat riwayat pencarian dari local storage.
  Future<List<LocationModel>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => LocationModel.fromJson(item)).toList();
  }

  /// Menyimpan riwayat pencarian ke local storage.
  Future<void> saveHistory(List<LocationModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((loc) => loc.toJson()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }

  /// Menambah lokasi ke riwayat pencarian.
  /// Jika sudah ada, pindahkan ke paling atas (terbaru).
  /// Maksimal 20 riwayat.
  Future<List<LocationModel>> addToHistory(LocationModel location) async {
    final history = await loadHistory();
    // Hapus duplikat jika ada
    history.removeWhere((loc) => loc.id == location.id);
    // Tambahkan di awal (terbaru di atas)
    history.insert(0, location);
    // Batasi maksimal 20 item
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    await saveHistory(history);
    return history;
  }

  /// Menghapus satu item dari riwayat.
  Future<List<LocationModel>> removeFromHistory(LocationModel location) async {
    final history = await loadHistory();
    history.removeWhere((loc) => loc.id == location.id);
    await saveHistory(history);
    return history;
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // === LOKASI TERAKHIR ===

  /// Menyimpan lokasi terakhir yang dipilih.
  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, json.encode(location.toJson()));
  }

  /// Memuat lokasi terakhir yang dipilih.
  /// Mengembalikan null jika belum ada.
  Future<LocationModel?> loadLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_lastLocationKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null; // Belum pernah memilih lokasi
    }

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return LocationModel.fromJson(jsonMap);
  }
}
