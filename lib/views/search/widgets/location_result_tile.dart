// location_result_tile.dart
// Kartu lokasi bergaya kaca untuk menampilkan item hasil pencarian,
// daftar kota favorit (beserta pratinjau suhu & ikon cuaca mini), dan riwayat.

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../models/current_weather_model.dart';
import '../../../models/location_model.dart';

/// Tile lokasi kaca reusable untuk hasil pencarian, favorit, dan riwayat.
class LocationResultTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final CurrentWeatherModel? weatherPreview;
  final bool isLoadingPreview;
  final bool showHistoryBadge;

  const LocationResultTile({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    this.weatherPreview,
    this.isLoadingPreview = false,
    this.showHistoryBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    final subtitle = [location.admin1, location.country]
        .where((s) => s.isNotEmpty)
        .join(', ');

    // RepaintBoundary + blur ringan menjaga performa scroll list tetap mulus
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: GlassCard(
          radius: 20,
          blurSigma: 10,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: onTap,
          child: Row(
            children: [
              // Ikon lokasi atau ikon riwayat di sisi kiri
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  showHistoryBadge
                      ? Icons.history_rounded
                      : Icons.location_on_outlined,
                  color: palette.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Nama kota + provinsi, negara
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: textTheme.bodyLarge?.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Pratinjau suhu & ikon cuaca mini (opsional untuk kartu favorit)
              if (weatherPreview != null) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WeatherIcon(
                      weatherCode: weatherPreview!.weatherCode,
                      isDay: weatherPreview!.isDay,
                      size: 30,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${weatherPreview!.temperature.round()}°',
                      style: textTheme.titleMedium?.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ] else if (isLoadingPreview) ...[
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],

              const SizedBox(width: 8),

              // Tombol toggle favorit di sisi kanan
              IconButton(
                onPressed: onFavoriteToggle,
                tooltip:
                    isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? Theme.of(context).colorScheme.error
                      : palette.textMuted,
                  size: 22,
                ),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
