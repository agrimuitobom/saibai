import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/blog_post_model.dart';
import '../../providers/blog_provider.dart';
import '../../widgets/common/app_card.dart';

class BlogProfileScreen extends ConsumerWidget {
  const BlogProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(blogProfileProvider);
    final myPosts = ref.watch(myPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.blogProfile),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
            tooltip: AppStrings.settings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0] : 'G',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: Colors.white),
                  ),
                  if (profile.bio != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      profile.bio!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(
                          label: '投稿',
                          value: '${profile.postCount}'),
                      const SizedBox(width: 32),
                      _StatItem(
                          label: 'フォロワー',
                          value: '${profile.followerCount}'),
                    ],
                  ),
                ],
              ),
            ),

            // My posts
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.myPosts,
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 12),
                  if (myPosts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            const Icon(Icons.article_outlined,
                                size: 48,
                                color: AppColors.textSecondary),
                            const SizedBox(height: 8),
                            Text(
                              'まだ投稿がありません',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...myPosts
                        .map((post) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MyPostTile(post: post),
                            ))
                        .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MyPostTile extends ConsumerWidget {
  final BlogPostModel post;

  const _MyPostTile({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(post.title, style: AppTextStyles.titleLarge),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('投稿を削除'),
                      content: const Text('この投稿を削除しますか？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(AppStrings.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(blogPostsProvider.notifier)
                                .deletePost(post.id);
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            AppStrings.delete,
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
              const Icon(Icons.favorite_border,
                  color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              Text('${post.likeCount}', style: AppTextStyles.labelSmall),
              const Spacer(),
              Text(
                DateFormat('yyyy年M月d日', 'ja').format(post.createdAt),
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
