import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/blog_post.dart';
import '../../providers/blog_provider.dart';

/// ブログプロフィール画面
/// ワイヤーフレーム：プロフィール画像・名前・設定ボタン・自分のブログ一覧
class BlogProfileScreen extends ConsumerWidget {
  const BlogProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPosts = ref.watch(myPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // プロフィールヘッダー
          SliverToBoxAdapter(
            child: _ProfileHeader(),
          ),
          // 自分が出してきたブログ（ワイヤーフレーム準拠）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                AppStrings.blogMyPosts,
                style: AppTextStyles.headlineSmall,
              ),
            ),
          ),
          if (myPosts.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('投稿がありません'),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _MyPostItem(post: myPosts[index]),
                childCount: myPosts.length,
              ),
            ),
        ],
      ),
    );
  }
}

/// プロフィールヘッダー（ワイヤーフレーム準拠）
class _ProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.surface,
      child: Stack(
        children: [
          // 背景グラジエント
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryContainer,
                  AppColors.surfaceVariant,
                ],
              ),
            ),
          ),
          // 設定ボタン（ワイヤーフレームの右上の設定）
          Positioned(
            top: 48,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/settings'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // 戻るボタン
          Positioned(
            top: 48,
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            ),
          ),
          // プロフィール情報
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // プロフィール画像（ワイヤーフレームの大きな円形アイコン）
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // 名前と自己紹介
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 44),
                      // 名前（ワイヤーフレームの「名前」）
                      Text(
                        '田中 花子',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '都市農業が趣味のベランダ菜園家です🌱',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 自分の投稿アイテム
class _MyPostItem extends ConsumerWidget {
  final BlogPost post;

  const _MyPostItem({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  post.title,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 公開/非公開バッジ
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: post.isPublic
                      ? AppColors.primaryContainer
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  post.isPublic
                      ? AppStrings.settingsPublic
                      : AppStrings.settingsPrivate,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: post.isPublic
                        ? AppColors.primaryDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            post.content,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                DateFormatter.toJapaneseDate(post.publishedAt),
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              Icon(
                Icons.favorite,
                size: 14,
                color: AppColors.error.withOpacity(0.7),
              ),
              const SizedBox(width: 3),
              Text('${post.likeCount}', style: AppTextStyles.bodySmall),
              const SizedBox(width: 12),
              const Icon(Icons.chat_bubble_outline,
                  size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 3),
              Text('${post.commentCount}', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
