// history_section.dart
// Bagian daftar riwayat pencarian lokasi pada Search Screen.
// Mendukung hapus per item (swipe) dan hapus semua riwayat.

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/location_model.dart';
import 'location_result_tile.dart';

/// Bagian Riwayat Pencarian pada Search Screen.
class HistorySection extends StatelessWidget {
  final List<LocationModel> history;
  final bool Function(int locationId) isFavorite;
  final ValueChanged<LocationModel> onSelect;
  final ValueChanged<LocationModel> onToggleFavorite;
  final ValueChanged<LocationModel> onRemoveItem;
  final VoidCallback onClearAll;

  const HistorySection({
    super.key,
    required this.history,
    required this.isFavorite,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.onRemoveItem,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'RIWAYAT PENCARIAN',
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onClearAll,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: palette.textSecondary,
                ),
                label: Text(
                  'Hapus Semua',
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...history.map(
          (location) => Dismissible(
            key: Key('history_${location.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white),
            ),
            onDismissed: (_) => onRemoveItem(location),
            child: LocationResultTile(
              location: location,
              isFavorite: isFavorite(location.id),
              showHistoryBadge: true,
              onTap: () => onSelect(location),
              onFavoriteToggle: () => onToggleFavorite(location),
            ),
          ),
        ),
      ],
    );
  }
}
