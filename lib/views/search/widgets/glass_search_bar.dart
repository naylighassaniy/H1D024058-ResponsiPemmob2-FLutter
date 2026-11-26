// glass_search_bar.dart
// Kolom pencarian berbentuk kapsul kaca transparan dengan ikon cari
// dan tombol hapus teks di sisi kanan.

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';

/// Kolom pencarian kaca berbentuk kapsul untuk Search Screen.
class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const GlassSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette =
        Theme.of(context).extension<WeatherPalette>() ?? WeatherPalette.standard;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassCard(
        radius: 28,
        blurSigma: 14,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          style: textTheme.bodyLarge?.copyWith(
            color: palette.textPrimary,
          ),
          cursorColor: palette.accentAqua,
          decoration: InputDecoration(
            hintText: 'Cari kota...',
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: palette.textMuted,
            ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: palette.textSecondary,
              size: 22,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: palette.textSecondary,
                      size: 20,
                    ),
                    tooltip: 'Hapus teks',
                    onPressed: onClear,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
