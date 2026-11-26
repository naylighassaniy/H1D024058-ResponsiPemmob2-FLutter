// home_screen.dart
// Halaman utama (Home/Weather Screen) dengan gaya glassmorphism:
// - AppBar transparan (extendBodyBehindAppBar) + tombol kaca Cari & Favorit
// - Latar dinamis WeatherBackground mengikuti kondisi cuaca & siang/malam
// - Hero cuaca, perkiraan per jam, grid detail 2 kolom, perkiraan 7 hari
// - Mendukung pull-to-refresh serta tampilan loading skeleton, empty, & error

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/weather_background.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../search/search_screen.dart';
import 'widgets/current_weather_hero.dart';
import 'widgets/hourly_forecast_list.dart';
import 'widgets/weather_detail_grid.dart';
import 'widgets/daily_forecast_card.dart';
import 'widgets/home_loading_skeleton.dart';
import 'widgets/home_error_view.dart';

/// Home Screen — menampilkan informasi cuaca lengkap lokasi yang dipilih.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, viewModel, _) {
        final currentWeather = viewModel.weatherData?.current;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildTransparentAppBar(context, viewModel),
          body: WeatherBackground(
            weatherCode: currentWeather?.weatherCode,
            isDay: currentWeather?.isDay ?? true,
            child: SafeArea(
              child: RefreshIndicator(
                color: Colors.white,
                backgroundColor:
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                onRefresh: () => viewModel.refreshWeather(),
                child: _buildBody(context, viewModel),
              ),
            ),
          ),
        );
      },
    );
  }

  /// AppBar transparan ringan: nama kota, provinsi/negara, tombol Favorit & Cari.
  PreferredSizeWidget _buildTransparentAppBar(
    BuildContext context,
    WeatherViewModel viewModel,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;
    final location = viewModel.currentLocation;

    final subtitle = location != null
        ? [location.admin1, location.country]
            .where((s) => s.isNotEmpty)
            .join(', ')
        : '';

    return AppBar(
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            location?.name ?? 'Cuaca',
            style: textTheme.headlineMedium?.copyWith(
              color: palette.textPrimary,
              fontSize: 22,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        // Tombol Favorit berbentuk kaca bulat
        if (viewModel.state == ViewState.success)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _GlassIconButton(
              icon: viewModel.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: viewModel.isFavorite
                  ? Theme.of(context).colorScheme.error
                  : palette.textPrimary,
              tooltip: viewModel.isFavorite
                  ? 'Hapus dari favorit'
                  : 'Tambah ke favorit',
              onTap: () => viewModel.toggleFavorite(),
            ),
          ),
        // Tombol Cari berbentuk kaca bulat
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _GlassIconButton(
            icon: Icons.search_rounded,
            iconColor: palette.textPrimary,
            tooltip: 'Cari kota',
            onTap: () => _navigateToSearch(context),
          ),
        ),
      ],
    );
  }

  /// Menentukan konten utama sesuai state ViewModel.
  Widget _buildBody(BuildContext context, WeatherViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.initial:
      case ViewState.loading:
        return const HomeLoadingSkeleton();

      case ViewState.success:
        return _buildWeatherContent(context, viewModel);

      case ViewState.error:
        return HomeErrorView(
          message: viewModel.errorMessage,
          onRetry: () => viewModel.refreshWeather(),
        );

      case ViewState.empty:
        return HomeEmptyView(
          onSearchTap: () => _navigateToSearch(context),
        );
    }
  }

  /// Konten cuaca utama yang responsif untuk layar kecil hingga tablet/landscape.
  Widget _buildWeatherContent(
    BuildContext context,
    WeatherViewModel viewModel,
  ) {
    final weather = viewModel.weatherData!;
    final todayForecast = weather.dailyForecasts.isNotEmpty
        ? weather.dailyForecasts.first
        : null;
    final todayPrecipProb = todayForecast?.precipitationProbability ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          child: Center(
            child: ConstrainedBox(
              // Batasi lebar maksimum pada layar lebar/tablet agar proporsional
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero cuaca utama
                  CurrentWeatherHero(
                    weather: weather.current,
                    todayForecast: todayForecast,
                  ),

                  const SizedBox(height: 16),

                  // 2. Perkiraan per jam (24 jam ke depan)
                  HourlyForecastList(forecasts: weather.hourlyForecasts),

                  const SizedBox(height: 20),

                  // 3. Detail cuaca dalam grid 2 kolom
                  WeatherDetailGrid(
                    weather: weather.current,
                    todayPrecipitationProbability: todayPrecipProb,
                  ),

                  const SizedBox(height: 20),

                  // 4. Perkiraan 7 hari ke depan
                  DailyForecastCard(forecasts: weather.dailyForecasts),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Navigasi ke Search Screen dan muat cuaca kota yang dipilih.
  Future<void> _navigateToSearch(BuildContext context) async {
    final weatherVM = context.read<WeatherViewModel>();

    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );

    if (!mounted) return;
    await weatherVM.syncFavorites();

    if (selectedLocation != null && mounted) {
      weatherVM.fetchWeather(selectedLocation);
    }
  }
}

/// Tombol aksi bulat bergaya kaca untuk header.
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String tooltip;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.iconColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 40,
        height: 40,
        child: GlassCard(
          radius: 20,
          blurSigma: 12,
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}
