// home_error_view.dart
// Tampilan error dan kosong bergaya kaca untuk Home Screen.
// Menggunakan ikon SVG dari set Meteocons (tanpa emoji) serta pesan ramah.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/weather_code_helper.dart';
import '../../../core/widgets/glass_card.dart';

/// Kartu kaca untuk menampilkan kondisi error dengan tombol Coba Lagi.
class HomeErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HomeErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          radius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                WeatherCodeHelper.notAvailableIcon,
                width: 84,
                height: 84,
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Cuaca',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  color: palette.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu kaca saat belum ada data cuaca / lokasi kosong.
class HomeEmptyView extends StatelessWidget {
  final VoidCallback onSearchTap;

  const HomeEmptyView({
    super.key,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          radius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                WeatherCodeHelper.getIconPath(2, isDay: true),
                width: 84,
                height: 84,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Lokasi Dipilih',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  color: palette.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Cari nama kota untuk melihat prakiraan cuaca terkini dan 7 hari ke depan.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onSearchTap,
                icon: const Icon(Icons.search_rounded, size: 20),
                label: const Text('Cari Kota'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
