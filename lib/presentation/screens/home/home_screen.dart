import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/crop_provider.dart';
import '../../widgets/weather_widget.dart';

/// ホーム画面
/// ワイヤーフレーム：アプリ名・アイコン、天気、タスク、育てているものを表示
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          // 天気情報を再取得
          ref.invalidate(regionalWeatherProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // 天気ウィジェット
              const WeatherWidget(),
              const SizedBox(height: 8),
              // タスクセクション
              _TaskSection(),
              const SizedBox(height: 8),
              // 育てているものセクション
              _GrowingCropsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.eco,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            AppStrings.appName,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        // プロフィールアイコン（ワイヤーフレーム：アイコン）
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/blog/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryContainer,
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// タスクセクション
class _TaskSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = ref.watch(todayTasksProvider);
    final pendingTasks = ref.watch(pendingTasksProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.homeTask, style: AppTextStyles.headlineSmall),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/task'),
                child: const Text('すべて見る'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 本日のタスク数バッジ
          if (todayTasks.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '今日のタスク: ${todayTasks.length}件',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // タスクリスト（最大3件表示）
          if (pendingTasks.isEmpty)
            _EmptyStateCard(
              icon: Icons.check_circle_outline,
              message: AppStrings.homeNoTask,
            )
          else
            ...pendingTasks.take(3).map(
                  (task) => _TaskCard(task: task),
                ),
        ],
      ),
    );
  }
}

/// タスクカード
class _TaskCard extends ConsumerWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // カテゴリーアイコン（絵文字）
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                task.category.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // タスク内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.toTaskDeadline(task.dueDate),
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.category.label,
                        style: AppTextStyles.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 完了チェックボックス
          GestureDetector(
            onTap: () =>
                ref.read(taskProvider.notifier).toggleComplete(task.id),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.primary
                      : AppColors.cardBorder,
                  width: 2,
                ),
                color: task.isCompleted
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// 育てている作物セクション
class _GrowingCropsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growingCrops = ref.watch(growingCropDetailsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.homeGrowing,
                style: AppTextStyles.headlineSmall,
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/crop-encyclopedia'),
                child: const Text('図鑑を見る'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (growingCrops.isEmpty)
            _EmptyStateCard(
              icon: Icons.eco_outlined,
              message: AppStrings.homeNoGrowing,
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: growingCrops.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final crop = growingCrops[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/crop-encyclopedia/detail',
                      arguments: crop,
                    ),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 作物アイコン
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            crop.name,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 空状態表示カード
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStateCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
