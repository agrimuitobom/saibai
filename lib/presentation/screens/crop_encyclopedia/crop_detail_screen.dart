import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/crop_provider.dart';
import '../../widgets/common/app_card.dart';

class CropDetailScreen extends ConsumerWidget {
  final String cropId;

  const CropDetailScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crop = ref.watch(cropDetailProvider(cropId));

    if (crop == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('作物詳細'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(child: Text('作物が見つかりませんでした')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(
                        crop.imagePath,
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(
                crop.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Name + difficulty badge
                Row(
                  children: [
                    Text(
                      AppStrings.cropName,
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(crop.name, style: AppTextStyles.headlineMedium),
                    const Spacer(),
                    _DifficultyBadge(difficulty: crop.difficulty),
                  ],
                ),
                const SizedBox(height: 16),

                // Season chip
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_outlined,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 6),
                    Text('栽培シーズン',
                        style: AppTextStyles.titleSmall),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        crop.season,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Cultivation method card
                _DetailSection(
                  icon: Icons.spa_outlined,
                  iconColor: AppColors.primary,
                  title: AppStrings.cultivationMethod,
                  content: '${crop.cultivationMethod}\n\n${crop.cultivationPeriod}',
                ),
                const SizedBox(height: 14),

                // Pests card
                _DetailSection(
                  icon: Icons.bug_report_outlined,
                  iconColor: AppColors.error,
                  title: AppStrings.mainPests,
                  content: crop.mainPests,
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _DetailSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  Color get _color {
    switch (difficulty) {
      case '易しい':
        return AppColors.success;
      case '難しい':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        difficulty,
        style: AppTextStyles.labelMedium.copyWith(
          color: _color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
