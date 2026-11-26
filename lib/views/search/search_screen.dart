// search_screen.dart
// Halaman pencarian lokasi dengan gaya glassmorphism serasi dengan Home Screen:
// - Latar belakang dinamis WeatherBackground mengikuti cuaca aktif
// - Kolom pencarian kapsul kaca dengan debounce 500ms ke Geocoding API
// - Daftar hasil pencarian, bagian Favorit (dengan pratinjau cuaca mini), & Riwayat
// - Loading skeleton, empty state, dan error state bergaya kaca

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/weather_background.dart';
import '../../models/location_model.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import 'widgets/favorite_section.dart';
import 'widgets/glass_search_bar.dart';
import 'widgets/history_section.dart';
import 'widgets/location_result_tile.dart';
import 'widgets/search_state_views.dart';

/// Search Screen — pencarian kota, lokasi favorit, dan riwayat pencarian.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().loadSavedData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Menangani perubahan teks pencarian dengan debounce 500ms.
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      context.read<SearchViewModel>().resetSearch();
      setState(() {});
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchViewModel>().searchLocation(query);
    });
    setState(() {});
  }

  /// Menangani pemilihan lokasi: simpan ke riwayat lalu kembali ke Home.
  void _onLocationSelected(LocationModel location) {
    context.read<SearchViewModel>().addToHistory(location);
    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    // Ikuti latar cuaca aktif dari WeatherViewModel agar serasi dengan Home
    final activeWeather = context.select<WeatherViewModel, ({int? code, bool isDay})>(
      (vm) => (
        code: vm.weatherData?.current.weatherCode,
        isDay: vm.weatherData?.current.isDay ?? true,
      ),
    );

    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: GlassCard(
                radius: 20,
                blurSigma: 12,
                padding: EdgeInsets.zero,
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: palette.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Pilih Lokasi',
          style: textTheme.titleMedium?.copyWith(
            color: palette.textPrimary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: WeatherBackground(
        weatherCode: activeWeather.code,
        isDay: activeWeather.isDay,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                children: [
                  // Kolom pencarian kapsul kaca
                  GlassSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: (query) {
                      _debounceTimer?.cancel();
                      if (query.trim().length >= 2) {
                        context.read<SearchViewModel>().searchLocation(query);
                      }
                    },
                    onClear: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),

                  // Daftar hasil atau daftar tersimpan (Favorit & Riwayat)
                  Expanded(
                    child: Consumer<SearchViewModel>(
                      builder: (context, viewModel, _) {
                        if (viewModel.currentQuery.isNotEmpty ||
                            viewModel.state == SearchState.loading) {
                          return _buildSearchResults(context, viewModel);
                        }
                        return _buildSavedSections(context, viewModel);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Menampilkan hasil pencarian API sesuai state (loading, success, empty, error).
  Widget _buildSearchResults(BuildContext context, SearchViewModel viewModel) {
    switch (viewModel.state) {
      case SearchState.loading:
        return const SearchLoadingSkeleton();

      case SearchState.success:
        return ListView.builder(
          padding: const EdgeInsets.only(top: 6, bottom: 24),
          itemCount: viewModel.searchResults.length,
          itemBuilder: (context, index) {
            final location = viewModel.searchResults[index];
            return LocationResultTile(
              location: location,
              isFavorite: viewModel.isFavorite(location.id),
              onTap: () => _onLocationSelected(location),
              onFavoriteToggle: () => viewModel.toggleFavorite(location),
            );
          },
        );

      case SearchState.empty:
        return SearchEmptyView(
          title: 'Kota tidak ditemukan',
          subtitle:
              'Periksa kembali ejaan nama kota atau coba nama daerah yang lebih umum.',
          iconAssetPath: WeatherCodeHelper.notAvailableIcon,
        );

      case SearchState.error:
        return SearchErrorView(
          message: viewModel.errorMessage,
          onRetry: () => viewModel.searchLocation(viewModel.currentQuery),
        );

      case SearchState.initial:
        return const SizedBox.shrink();
    }
  }

  /// Menampilkan Favorit dan Riwayat saat kolom pencarian kosong.
  Widget _buildSavedSections(BuildContext context, SearchViewModel viewModel) {
    final hasFavorites = viewModel.favorites.isNotEmpty;
    final hasHistory = viewModel.history.isNotEmpty;

    if (!hasFavorites && !hasHistory) {
      return SearchEmptyView(
        title: 'Mulai Mencari Kota',
        subtitle:
            'Ketik minimal 2 huruf nama kota. Lokasi favorit dan riwayat akan tersimpan di sini.',
        iconAssetPath: WeatherCodeHelper.getIconPath(1, isDay: true),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FavoriteSection(
            favorites: viewModel.favorites,
            getWeatherPreview: viewModel.getFavoriteWeather,
            isLoadingPreview: viewModel.isFavoriteWeatherLoading,
            onSelect: _onLocationSelected,
            onToggleFavorite: viewModel.toggleFavorite,
          ),
          HistorySection(
            history: viewModel.history,
            isFavorite: viewModel.isFavorite,
            onSelect: _onLocationSelected,
            onToggleFavorite: viewModel.toggleFavorite,
            onRemoveItem: viewModel.removeFromHistory,
            onClearAll: () => _confirmClearHistory(context, viewModel),
          ),
        ],
      ),
    );
  }

  /// Dialog konfirmasi penghapusan seluruh riwayat pencarian.
  void _confirmClearHistory(BuildContext context, SearchViewModel viewModel) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF142749),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        title: Text(
          'Hapus Riwayat',
          style: textTheme.titleMedium?.copyWith(color: palette.textPrimary),
        ),
        content: Text(
          'Semua riwayat pencarian kota akan dihapus dari perangkat ini.',
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(color: palette.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              viewModel.clearHistory();
              Navigator.pop(ctx);
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
