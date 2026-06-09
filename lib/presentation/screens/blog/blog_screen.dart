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

class BlogScreen extends ConsumerWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(blogPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.blog),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/blog/profile'),
            tooltip: 'プロフィール',
          ),
        ],
      ),
      body: posts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📝', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    '投稿がありません\n+ ボタンで最初の投稿を作成しましょう',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                return _BlogPostCard(post: posts[i]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPostDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('新しい投稿', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.postTitle,
                    hintText: 'タイトルを入力してください',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'タイトルを入力してください' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: AppStrings.postContent,
                    hintText: '投稿内容を入力してください',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '内容を入力してください' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            ref.read(blogPostsProvider.notifier).addPost(
                                  titleController.text.trim(),
                                  contentController.text.trim(),
                                );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('投稿する'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BlogPostCard extends StatelessWidget {
  final BlogPostModel post;

  const _BlogPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  post.authorName.isNotEmpty
                      ? post.authorName[0]
                      : '?',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName,
                      style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text(
                    DateFormat('yyyy年M月d日', 'ja').format(post.createdAt),
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.favorite_border,
                      color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likeCount}',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 6),
          Text(
            post.content,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#$tag',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
