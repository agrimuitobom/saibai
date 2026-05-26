import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/blog_post.dart';
import '../../providers/blog_provider.dart';

/// ブログ画面
/// ワイヤーフレーム：ブログタイトル・投稿リスト・＋ボタン
class BlogScreen extends ConsumerWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(publicPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.blogTitle,
          style: AppTextStyles.headlineSmall,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // プロフィールボタン
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/blog/profile'),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryContainer,
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: posts.isEmpty
          ? _EmptyBlogView()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _BlogPostCard(post: posts[index]);
              },
            ),
      // ＋ボタン（ワイヤーフレーム準拠）
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPostDialog(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showNewPostDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewPostSheet(ref: ref),
    );
  }
}

/// ブログ投稿カード（ワイヤーフレームのアイコン+コンテンツ）
class _BlogPostCard extends ConsumerWidget {
  final BlogPost post;

  const _BlogPostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー（アイコン + 著者名 + 日時）
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // アバター（ワイヤーフレームの「アイコン」）
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    post.author.name.isNotEmpty
                        ? post.author.name[0]
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.name,
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(
                        DateFormatter.toRelativeTime(post.publishedAt),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                // 非公開バッジ
                if (!post.isPublic)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppStrings.settingsPrivate,
                      style: AppTextStyles.labelSmall,
                    ),
                  ),
              ],
            ),
          ),
          // サムネイル画像（あれば）
          if (post.imageUrl != null)
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 48, color: AppColors.primary),
              ),
            ),
          // タイトルと本文
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: post.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$tag',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          // フッター（いいね・コメント）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                // いいねボタン
                GestureDetector(
                  onTap: () =>
                      ref.read(blogProvider.notifier).toggleLike(post.id),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: post.isLiked
                            ? AppColors.error
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // コメント数
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: AppTextStyles.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 新規投稿ボトムシート
class _NewPostSheet extends StatefulWidget {
  final WidgetRef ref;

  const _NewPostSheet({required this.ref});

  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPublic = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ハンドルバー
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // ヘッダー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.blogNewPost,
                  style: AppTextStyles.headlineSmall,
                ),
                Row(
                  children: [
                    // 公開設定トグル
                    Text(
                      _isPublic
                          ? AppStrings.settingsPublic
                          : AppStrings.settingsPrivate,
                      style: AppTextStyles.labelMedium,
                    ),
                    Switch(
                      value: _isPublic,
                      onChanged: (v) => setState(() => _isPublic = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // 入力フォーム
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'タイトルを入力...',
                      labelText: 'タイトル',
                    ),
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: '今日の菜園について書いてみましょう...',
                      labelText: '本文',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 8,
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  // 投稿ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('投稿する'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      return;
    }
    widget.ref.read(blogProvider.notifier).addPost(
          title: _titleController.text,
          content: _contentController.text,
          isPublic: _isPublic,
        );
    Navigator.pop(context);
  }
}

/// ブログ空状態
class _EmptyBlogView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined,
              size: 64, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('まだ投稿がありません', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          Text('＋ボタンから最初の投稿をしましょう',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
