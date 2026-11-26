// favorite_section.dart
// Bagian daftar kota favorit pada Search Screen saat kolom pencarian kosong.
// Menampilkan pratinjau suhu & ikon cuaca mini untuk kota favorit jika tersedia.

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/current_weather_model.dart';
import '../../../models/location_model.dart';
import 'location_result_tile.dart';

/// Bagian Favorit pada Search Screen.
class FavoriteSection extends StatelessWidget {
  final List<LocationModel> favorites;
  final CurrentWeatherModel? Function(int locationId) getWeatherPreview;
  final bool Function(int locationId) isLoadingPreview;
  final ValueChanged<LocationModel> onSelect;
  final ValueChanged<LocationModel> onToggleFavorite;

  const FavoriteSection({
    super.key,
    required this.favorites,
    required this.getWeatherPreview,
    required this.isLoadingPreview,
    required this.onSelect,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
          child: Text(
            'FAVORIT',
            style: textTheme.labelSmall?.copyWith(
              color: palette.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...favorites.map(
          (location) => LocationResultTile(
            location: location,
            isFavorite: true,
            weatherPreview: getWeatherPreview(location.id),
            isLoadingPreview: isLoadingPreview(location.id),
            onTap: () => onSelect(location),
            onFavoriteToggle: () => onToggleFavorite(location),
          ),
        ),
      ],
    );
  }
}
