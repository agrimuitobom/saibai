import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/crop_provider.dart';
import '../../widgets/common/app_card.dart';

class CropListScreen extends ConsumerWidget {
  const CropListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(cropSearchQueryProvider);
    final crops = ref.watch(filteredCropsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.cropEncyclopedia),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              onChanged: (v) =>
                  ref.read(cropSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: AppStrings.searchCrops,
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(cropSearchQueryProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            if (crops.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 8),
                      Text(
                        '「$query」は見つかりませんでした',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: crops.length,
                  itemBuilder: (context, i) {
                    final crop = crops[i];
                    return GestureDetector(
                      onTap: () => context.go('/crops/${crop.id}'),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              crop.imagePath,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              crop.name,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              crop.season,
                              style: AppTextStyles.labelSmall,
                              textAlign: TextAlign.center,
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
      ),
    );
  }
}
