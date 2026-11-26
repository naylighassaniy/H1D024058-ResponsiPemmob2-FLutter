// search_state_views.dart
// Tampilan state untuk Search Screen: skeleton loading kartu kaca,
// hasil kosong ("Kota tidak ditemukan"), error, dan prompt awal saat belum ada data.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/weather_code_helper.dart';
import '../../../core/widgets/glass_card.dart';

/// Skeleton loading untuk daftar hasil pencarian kota.
class SearchLoadingSkeleton extends StatefulWidget {
  const SearchLoadingSkeleton({super.key});

  @override
  State<SearchLoadingSkeleton> createState() => _SearchLoadingSkeletonState();
}

class _SearchLoadingSkeletonState extends State<SearchLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slide = (_controller.value * 2) - 1;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: 5,
          itemBuilder: (context, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: GlassCard(
                radius: 20,
                blurSigma: 10,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    _shimmerRect(38, 38, 12, slide),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerRect(130, 14, 7, slide),
                          const SizedBox(height: 8),
                          _shimmerRect(180, 10, 5, slide),
                        ],
                      ),
                    ),
                    _shimmerRect(26, 26, 13, slide),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _shimmerRect(double w, double h, double r, double slide) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          begin: Alignment(slide - 0.8, 0),
          end: Alignment(slide + 0.8, 0),
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
      ),
    );
  }
}

/// Tampilan saat hasil pencarian kota kosong / belum ada data tersimpan.
class SearchEmptyView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? iconAssetPath;

  const SearchEmptyView({
    super.key,
    required this.title,
    required this.subtitle,
    this.iconAssetPath,
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
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconAssetPath ?? WeatherCodeHelper.getIconPath(2, isDay: true),
                width: 68,
                height: 68,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: palette.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tampilan error pada Search Screen dengan tombol Coba Lagi.
class SearchErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const SearchErrorView({
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
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                WeatherCodeHelper.notAvailableIcon,
                width: 68,
                height: 68,
              ),
              const SizedBox(height: 16),
              Text(
                'Pencarian Gagal',
                style: textTheme.titleMedium?.copyWith(
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
