import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/crop.dart';
import '../../providers/crop_provider.dart';

/// 作物図鑑画面
/// ワイヤーフレーム：検索窓 + グリッド表示（円形アイコン）
class CropEncyclopediaScreen extends ConsumerWidget {
  const CropEncyclopediaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredCrops = ref.watch(filteredCropsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.cropEncyclopediaTitle,
          style: AppTextStyles.headlineSmall,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 検索窓（ワイヤーフレーム準拠）
          _SearchBar(),
          const SizedBox(height: 8),
          // 作物グリッド（ワイヤーフレーム：円形アイコングリッド）
          Expanded(
            child: filteredCrops.isEmpty
                ? _EmptySearchResult()
                : _CropGrid(crops: filteredCrops),
          ),
        ],
      ),
    );
  }
}

/// 検索バー（ワイヤーフレームの「検索窓」）
class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        onChanged: (value) {
          ref.read(cropSearchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: AppStrings.cropSearchHint,
          prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/// 作物グリッド（ワイヤーフレームの円形アイコン3列グリッド）
class _CropGrid extends StatelessWidget {
  final List<Crop> crops;

  const _CropGrid({required this.crops});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,      // ワイヤーフレーム通り3列
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: crops.length,
      itemBuilder: (context, index) {
        return _CropGridItem(crop: crops[index]);
      },
    );
  }
}

/// 作物グリッドアイテム（円形アイコン）
class _CropGridItem extends StatelessWidget {
  final Crop crop;

  const _CropGridItem({required this.crop});

  /// 作物名から絵文字アイコンを取得
  String get _cropEmoji {
    switch (crop.nameEn.toLowerCase()) {
      case 'tomato':
        return '🍅';
      case 'cucumber':
        return '🥒';
      case 'eggplant':
        return '🍆';
      case 'bell pepper':
        return '🫑';
      case 'strawberry':
        return '🍓';
      case 'lettuce':
        return '🥬';
      case 'spinach':
        return '🥦';
      case 'basil':
        return '🌿';
      default:
        return '🌱';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CropDetailScreen(crop: crop),
          ),
        );
      },
      child: Column(
        children: [
          // 円形アイコン（ワイヤーフレーム準拠）
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _cropEmoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // 作物名
          Text(
            crop.name,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 検索結果なし表示
class _EmptySearchResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '該当する作物が見つかりませんでした',
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '別のキーワードで検索してください',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// 作物詳細画面
/// ワイヤーフレーム：野菜の名前・栽培方法や栽培期間・主な病気や病害虫
class CropDetailScreen extends ConsumerWidget {
  final Crop crop;

  const CropDetailScreen({super.key, required this.crop});

  String get _cropEmoji {
    switch (crop.nameEn.toLowerCase()) {
      case 'tomato':
        return '🍅';
      case 'cucumber':
        return '🥒';
      case 'eggplant':
        return '🍆';
      case 'bell pepper':
        return '🫑';
      case 'strawberry':
        return '🍓';
      case 'lettuce':
        return '🥬';
      case 'spinach':
        return '🥦';
      case 'basil':
        return '🌿';
      default:
        return '🌱';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growingIds = ref.watch(growingCropsProvider);
    final isGrowing = growingIds.contains(crop.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ヒーローアプリバー
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryContainer,
                child: Center(
                  child: Text(
                    _cropEmoji,
                    style: const TextStyle(fontSize: 96),
                  ),
                ),
              ),
            ),
            actions: [
              // 育てているリストへの追加・削除ボタン
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    if (isGrowing) {
                      ref
                          .read(growingCropsProvider.notifier)
                          .removeCrop(crop.id);
                    } else {
                      ref
                          .read(growingCropsProvider.notifier)
                          .addCrop(crop.id);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isGrowing
                              ? '${crop.name}を栽培リストから削除しました'
                              : '${crop.name}を栽培リストに追加しました',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(
                    isGrowing ? Icons.favorite : Icons.favorite_border,
                    color: isGrowing ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          // コンテンツ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 野菜の名前セクション（ワイヤーフレーム準拠）
                  _SectionCard(
                    title: AppStrings.cropVegetableName,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              crop.name,
                              style: AppTextStyles.headlineLarge,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              crop.nameEn,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 難易度バッジ
                        _DifficultyBadge(level: crop.difficulty),
                        const SizedBox(height: 8),
                        // 栽培場所
                        Wrap(
                          spacing: 8,
                          children: crop.suitableLocations
                              .map(
                                (loc) => Chip(
                                  label: Text(loc.label),
                                  avatar: const Icon(Icons.place, size: 14),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          crop.description,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 栽培方法や栽培期間セクション（ワイヤーフレーム準拠）
                  _SectionCard(
                    title: AppStrings.cropGrowingMethod,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 栽培期間バッジ
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule,
                                  size: 16,
                                  color: AppColors.secondaryDark),
                              const SizedBox(width: 4),
                              Text(
                                crop.growingPeriod,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.secondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          crop.growingMethod,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        // 適期
                        Text(
                          '栽培適期',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: crop.suitableSeasons
                              .map(
                                (season) => _SeasonChip(season: season),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        // 水やり頻度
                        Row(
                          children: [
                            const Icon(
                              Icons.water_drop,
                              color: AppColors.weatherRainy,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '水やり: ${crop.wateringFrequencyDays == 1 ? "毎日" : "${crop.wateringFrequencyDays}日おき"}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 収穫情報
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text('🌾',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  crop.harvestInfo,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 主な病気や病害虫セクション（ワイヤーフレーム準拠）
                  _SectionCard(
                    title: AppStrings.cropPestDisease,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 病害虫
                        if (crop.commonPests.isNotEmpty) ...[
                          Text('🐛 主な病害虫',
                              style: AppTextStyles.labelLarge),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: crop.commonPests
                                .map(
                                  (pest) => Chip(
                                    label: Text(pest),
                                    backgroundColor:
                                        AppColors.pestDanger.withOpacity(0.1),
                                    side: BorderSide(
                                      color: AppColors.pestDanger
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // 病気
                        if (crop.commonDiseases.isNotEmpty) ...[
                          Text('🍄 主な病気',
                              style: AppTextStyles.labelLarge),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: crop.commonDiseases
                                .map(
                                  (disease) => Chip(
                                    label: Text(disease),
                                    backgroundColor: AppColors.pestWarning
                                        .withOpacity(0.1),
                                    side: BorderSide(
                                      color: AppColors.pestWarning
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // 病害虫チェッカーへのリンク
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/pest-checker'),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('病害虫チェッカーで診断'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// セクションカード
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// 難易度バッジ
class _DifficultyBadge extends StatelessWidget {
  final DifficultyLevel level;

  const _DifficultyBadge({required this.level});

  Color get _color {
    switch (level) {
      case DifficultyLevel.easy:
        return AppColors.pestSafe;
      case DifficultyLevel.medium:
        return AppColors.pestWarning;
      case DifficultyLevel.hard:
        return AppColors.pestDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 季節チップ
class _SeasonChip extends StatelessWidget {
  final String season;

  const _SeasonChip({required this.season});

  String get _emoji {
    switch (season) {
      case '春':
        return '🌸';
      case '夏':
        return '☀️';
      case '秋':
        return '🍂';
      case '冬':
        return '❄️';
      default:
        return '🌿';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$_emoji $season'),
      backgroundColor: AppColors.surfaceVariant,
    );
  }
}
