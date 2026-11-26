// location_model.dart
// Model ini merepresentasikan data lokasi/kota yang didapat
// dari Geocoding API Open-Meteo.
// Digunakan untuk pencarian kota dan penyimpanan favorit/riwayat.

/// Model data lokasi hasil pencarian Geocoding API.
class LocationModel {
  final int id; // ID unik lokasi dari API
  final String name; // Nama kota
  final double latitude; // Koordinat lintang
  final double longitude; // Koordinat bujur
  final String country; // Nama negara
  final String admin1; // Provinsi/daerah admin level 1
  final String timezone; // Zona waktu lokasi

  LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.admin1,
    required this.timezone,
  });

  /// Membuat LocationModel dari JSON response API.
  /// Menggunakan nilai default '' jika field tidak tersedia.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      country: json['country'] ?? '',
      admin1: json['admin1'] ?? '',
      timezone: json['timezone'] ?? 'auto',
    );
  }

  /// Mengubah LocationModel ke Map (untuk disimpan ke SharedPreferences).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  /// Override == agar bisa dibandingkan berdasarkan id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
