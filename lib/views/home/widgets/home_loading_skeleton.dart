// home_loading_skeleton.dart
// Skeleton loading bergaya kaca dengan efek shimmer buatan sendiri
// menggunakan AnimationController + gradien bergerak (tanpa package tambahan).

import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';

/// Tampilan loading skeleton untuk Home Screen agar serasi dengan tema kaca.
class HomeLoadingSkeleton extends StatefulWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  State<HomeLoadingSkeleton> createState() => _HomeLoadingSkeletonState();
}

class _HomeLoadingSkeletonState extends State<HomeLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
        final shimmerValue = _controller.value;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            children: [
              // Skeleton hero (ikon + suhu + deskripsi)
              _ShimmerBox(
                width: 110,
                height: 110,
                radius: 55,
                progress: shimmerValue,
              ),
              const SizedBox(height: 16),
              _ShimmerBox(
                width: 130,
                height: 68,
                radius: 20,
                progress: shimmerValue,
              ),
              const SizedBox(height: 12),
              _ShimmerBox(
                width: 160,
                height: 20,
                radius: 10,
                progress: shimmerValue,
              ),
              const SizedBox(height: 28),

              // Skeleton kapsul per jam
              SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, _) => GlassCard(
                    radius: 22,
                    blurSigma: 10,
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ShimmerBox(
                            width: 38,
                            height: 10,
                            radius: 5,
                            progress: shimmerValue,
                          ),
                          _ShimmerBox(
                            width: 32,
                            height: 32,
                            radius: 16,
                            progress: shimmerValue,
                          ),
                          _ShimmerBox(
                            width: 28,
                            height: 14,
                            radius: 6,
                            progress: shimmerValue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Skeleton grid detail 2 kolom
              LayoutBuilder(
                builder: (context, constraints) {
                  final halfWidth = (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      4,
                      (_) => SizedBox(
                        width: halfWidth,
                        child: GlassCard(
                          radius: 20,
                          blurSigma: 10,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ShimmerBox(
                                width: 80,
                                height: 12,
                                radius: 6,
                                progress: shimmerValue,
                              ),
                              const SizedBox(height: 14),
                              _ShimmerBox(
                                width: 64,
                                height: 24,
                                radius: 8,
                                progress: shimmerValue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Skeleton daftar 7 hari
              GlassCard(
                radius: 24,
                blurSigma: 10,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: List.generate(
                    5,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: i < 4 ? 16 : 0),
                      child: Row(
                        children: [
                          _ShimmerBox(
                            width: 60,
                            height: 14,
                            radius: 6,
                            progress: shimmerValue,
                          ),
                          const Spacer(),
                          _ShimmerBox(
                            width: 28,
                            height: 28,
                            radius: 14,
                            progress: shimmerValue,
                          ),
                          const Spacer(),
                          _ShimmerBox(
                            width: 110,
                            height: 12,
                            radius: 6,
                            progress: shimmerValue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Kotak placeholder dengan efek kilau gradien bergerak.
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final double progress;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final slide = (progress * 2) - 1; // Bergerak dari -1.0 ke +1.0

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(slide - 0.8, -0.2),
          end: Alignment(slide + 0.8, 0.2),
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
