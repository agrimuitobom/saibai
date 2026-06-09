import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/services/pest_checker_service.dart';
import '../../widgets/common/app_card.dart';

final _selectedSymptomProvider = StateProvider<String?>((ref) => null);
final _pestResultProvider =
    StateProvider<AsyncValue<PestResult?>>((ref) => const AsyncData(null));

class PestCheckerScreen extends ConsumerWidget {
  const PestCheckerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedSymptomProvider);
    final resultState = ref.watch(_pestResultProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.pestChecker),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🔍', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(AppStrings.selectSymptom,
                          style: AppTextStyles.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '症状を選んで検索してください',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ...PestCheckerService.symptoms.map((symptom) {
                    final isSelected = symptom == selected;
                    return GestureDetector(
                      onTap: () {
                        ref.read(_selectedSymptomProvider.notifier).state =
                            symptom;
                        ref.read(_pestResultProvider.notifier).state =
                            const AsyncData(null);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.12)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              symptom,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: selected == null
                          ? null
                          : () async {
                              ref
                                  .read(_pestResultProvider.notifier)
                                  .state = const AsyncLoading();
                              try {
                                final result =
                                    await PestCheckerService().checkPest(
                                  selected,
                                );
                                ref
                                    .read(_pestResultProvider.notifier)
                                    .state = AsyncData(result);
                              } catch (e) {
                                ref
                                    .read(_pestResultProvider.notifier)
                                    .state = AsyncError(e, StackTrace.current);
                              }
                            },
                      icon: const Icon(Icons.search),
                      label: const Text(AppStrings.search),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            resultState.when(
              data: (result) {
                if (result == null) return const SizedBox.shrink();
                return _PestResultCard(result: result);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('診断中...'),
                    ],
                  ),
                ),
              ),
              error: (e, _) => AppCard(
                child: Text(
                  AppStrings.error,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PestResultCard extends StatelessWidget {
  final PestResult result;

  const _PestResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('診断結果', style: AppTextStyles.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),

        // Result header
        AppCard(
          color: AppColors.primary.withOpacity(0.08),
          child: Row(
            children: [
              Text(result.emoji,
                  style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '考えられる原因',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    Text(result.name, style: AppTextStyles.headlineSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Description
        _InfoSection(
          icon: Icons.description_outlined,
          title: AppStrings.pestDescription,
          content: result.description,
          iconColor: AppColors.accent,
        ),
        const SizedBox(height: 12),

        // Treatment
        _InfoSection(
          icon: Icons.medical_services_outlined,
          title: AppStrings.treatment,
          content: result.treatment,
          iconColor: AppColors.warning,
        ),
        const SizedBox(height: 12),

        // Prevention
        _InfoSection(
          icon: Icons.shield_outlined,
          title: AppStrings.prevention,
          content: result.prevention,
          iconColor: AppColors.success,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color iconColor;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text(content, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
