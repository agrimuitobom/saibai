import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/services/weather_service.dart';
import '../../providers/task_provider.dart';
import '../../providers/crop_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/section_header.dart';

final weatherProvider = FutureProvider<WeatherData>((ref) {
  return WeatherService().fetchWeather();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final growingCropsAsync = ref.watch(growingCropsProvider);
    final today = DateTime.now();
    final dateStr = DateFormat('yyyy年M月d日（E）', 'ja').format(today);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.headerGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('🌱', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.appName,
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              dateStr,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 天気 card
                SectionHeader(
                  title: AppStrings.todayWeather,
                  actionLabel: null,
                ),
                const SizedBox(height: 8),
                weatherAsync.when(
                  data: (w) => AppCard(
                    child: Row(
                      children: [
                        Text(w.icon, style: const TextStyle(fontSize: 48)),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${w.temperature}°C  ${w.condition}',
                              style: AppTextStyles.headlineMedium,
                            ),
                            Text(
                              '湿度 ${w.humidity}%  ${w.location}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  loading: () => const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  error: (_, __) => AppCard(
                    child: Text(
                      '天気情報を取得できませんでした',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // タスク card
                SectionHeader(
                  title: AppStrings.todayTasks,
                  actionLabel: AppStrings.viewAll,
                  onAction: () => context.go('/task'),
                ),
                const SizedBox(height: 8),
                tasksAsync.when(
                  data: (tasks) {
                    final todayTasks = tasks
                        .where((t) =>
                            !t.isCompleted &&
                            t.dueDate.year == today.year &&
                            t.dueDate.month == today.month &&
                            t.dueDate.day == today.day)
                        .take(3)
                        .toList();
                    if (todayTasks.isEmpty) {
                      return AppCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              AppStrings.noTasks,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: todayTasks.map((task) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.radio_button_unchecked,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    task.category,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const AppCard(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => AppCard(
                    child: Text(
                      AppStrings.error,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 育てているもの card
                SectionHeader(
                  title: AppStrings.growingCrops,
                  actionLabel: AppStrings.viewAll,
                  onAction: () => context.go('/task/growing'),
                ),
                const SizedBox(height: 8),
                growingCropsAsync.when(
                  data: (crops) {
                    if (crops.isEmpty) {
                      return AppCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              AppStrings.noCrops,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: crops.take(6).map((crop) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              crop.name,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const AppCard(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => AppCard(
                    child: Text(AppStrings.error, style: AppTextStyles.bodyMedium),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick actions
                SectionHeader(title: 'クイックアクション'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        onTap: () => context.go('/task/calendar'),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.calendar,
                              style: AppTextStyles.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        onTap: () => context.go('/pest'),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.bug_report,
                              color: AppColors.accent,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.pestChecker,
                              style: AppTextStyles.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        onTap: () => context.go('/crops'),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.menu_book,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.cropEncyclopedia,
                              style: AppTextStyles.labelMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
