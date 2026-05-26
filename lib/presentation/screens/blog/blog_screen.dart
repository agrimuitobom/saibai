import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/blog_post.dart';
import '../../providers/blog_provider.dart';

/// ブログ画面（Twitter風デザイン）
class BlogScreen extends ConsumerWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(publicPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.eco, color: AppColors.primary, size: 26),
            const SizedBox(width: 8),
            Text('ブログ', style: AppTextStyles.headlineSmall),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/blog/profile'),
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person, color: AppColors.primary, size: 18),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: posts.isEmpty
            ? _EmptyFeedView()
            : ListView.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, thickness: 1),
                itemBuilder: (context, index) =>
                    _TweetCard(post: posts[index]),
              ),
      ),
      // 投稿ボタン（Twitter の tweet ボタン風）
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeSheet(context, ref),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  void _showComposeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComposeSheet(ref: ref),
    );
  }
}

/// Twitter風ツイートカード
class _TweetCard extends ConsumerWidget {
  final BlogPost post;

  const _TweetCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {}, // 詳細画面へ（将来実装）
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アバター（シルエット）
            _SilhouetteAvatar(name: post.author.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダー：名前・ハンドル・時刻
                  Row(
                    children: [
                      Text(
                        post.author.name,
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '·',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormatter.toRelativeTime(post.publishedAt),
                        style: AppTextStyles.bodySmall,
                      ),
                      const Spacer(),
                      // 非公開バッジ
                      if (!post.isPublic)
                        const Icon(Icons.lock,
                            size: 14, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 本文
                  Text(
                    post.content,
                    style: AppTextStyles.bodyMedium,
                  ),
                  // 添付画像（あれば）
                  if (post.imageUrl != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: AppColors.primaryContainer,
                        child: const Icon(
                          Icons.image,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                  // タグ
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: post.tags
                          .map(
                            (tag) => Text(
                              '#$tag',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  // アクションバー（Twitter風）
                  _ActionBar(post: post),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// シルエットアバター
class _SilhouetteAvatar extends StatelessWidget {
  final String name;

  const _SilhouetteAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: _PersonSilhouettePainter(),
        ),
      ),
    );
  }
}

/// 人物シルエットを描画するカスタムペインター
class _PersonSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    // 頭部
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.33),
      size.width * 0.2,
      paint,
    );
    // 胴体（下半分を楕円で表現）
    final bodyRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.78),
      width: size.width * 0.6,
      height: size.height * 0.5,
    );
    canvas.drawOval(bodyRect, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// アクションバー（リプライ・いいね・共有）
class _ActionBar extends ConsumerWidget {
  final BlogPost post;

  const _ActionBar({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // コメント
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          count: post.commentCount,
          onTap: () {},
        ),
        const SizedBox(width: 28),
        // リポスト
        _ActionButton(
          icon: Icons.repeat,
          count: 0,
          onTap: () {},
          activeColor: const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 28),
        // いいね
        _ActionButton(
          icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
          count: post.likeCount,
          onTap: () =>
              ref.read(blogProvider.notifier).toggleLike(post.id),
          isActive: post.isLiked,
          activeColor: AppColors.error,
        ),
        const Spacer(),
        // 共有
        _ActionButton(
          icon: Icons.ios_share_outlined,
          count: null,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final VoidCallback onTap;
  final bool isActive;
  final Color activeColor;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.onTap,
    this.isActive = false,
    this.activeColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? activeColor : AppColors.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: AppTextStyles.bodySmall.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 投稿コンポーザー（Twitter風）
class _ComposeSheet extends StatefulWidget {
  final WidgetRef ref;

  const _ComposeSheet({required this.ref});

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  File? _selectedImage;
  bool _isPublic = true;
  static const int _maxLength = 280;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _remaining => _maxLength - _controller.text.length;
  bool get _canPost =>
      _controller.text.trim().isNotEmpty && _remaining >= 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 200),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドルバー
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // ツールバー
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // キャンセル
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  const Spacer(),
                  // 公開/非公開
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isPublic = !_isPublic),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isPublic
                                ? Icons.public
                                : Icons.lock_outline,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isPublic ? '公開' : '非公開',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 投稿ボタン
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, __, ___) => ElevatedButton(
                      onPressed: _canPost ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('投稿'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // 入力エリア
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 自分のアバター
                      const _SilhouetteAvatar(name: '自分'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              maxLines: null,
                              minLines: 4,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: '今日の菜園はどうでしたか？',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                              style: AppTextStyles.bodyLarge,
                            ),
                            // 選択された画像プレビュー
                            if (_selectedImage != null) ...[
                              const SizedBox(height: 8),
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    child: Image.file(
                                      _selectedImage!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => _selectedImage = null),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            // ボトムツールバー（画像添付など）
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 20),
              child: Row(
                children: [
                  // 画像添付（カメラ）
                  IconButton(
                    onPressed: () =>
                        _pickImage(ImageSource.camera),
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primary,
                    ),
                    tooltip: 'カメラで撮影',
                  ),
                  // 画像添付（アルバム）
                  IconButton(
                    onPressed: () =>
                        _pickImage(ImageSource.gallery),
                    icon: const Icon(
                      Icons.image_outlined,
                      color: AppColors.primary,
                    ),
                    tooltip: 'アルバムから選択',
                  ),
                  // 位置情報（将来実装）
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    tooltip: '位置情報',
                  ),
                  const Spacer(),
                  // 文字数カウンター
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, __, ___) {
                      final color = _remaining < 0
                          ? AppColors.error
                          : _remaining < 20
                              ? AppColors.warning
                              : AppColors.onSurfaceVariant;
                      return Text(
                        '$_remaining',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: color),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _submit() {
    widget.ref.read(blogProvider.notifier).addPost(
          title: _controller.text.trim().split('\n').first,
          content: _controller.text.trim(),
          isPublic: _isPublic,
        );
    Navigator.pop(context);
  }
}

/// 空のフィード表示
class _EmptyFeedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.dynamic_feed_outlined,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('まだ投稿がありません', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          Text(
            'ペンアイコンから最初の投稿をしましょう',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
