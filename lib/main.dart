// main.dart
// File utama aplikasi — titik masuk (entry point).
// Di sini kita mendaftarkan semua Provider (ChangeNotifierProvider)
// dan mengatur theme serta halaman awal.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'views/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Widget root aplikasi.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider mendaftarkan semua ViewModel agar bisa diakses
    // oleh seluruh widget di bawahnya (dependency injection).
    return MultiProvider(
      providers: [
        // ViewModel untuk Home/Weather Screen
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
        // ViewModel untuk Search Screen
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        // Gunakan theme terpusat dari AppTheme
        theme: AppTheme.lightTheme,
        // Halaman awal: Home Screen
        home: const HomeScreen(),
      ),
    );
  }
}
