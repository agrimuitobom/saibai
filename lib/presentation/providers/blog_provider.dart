import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/blog_post.dart';

const _uuid = Uuid();

/// ブログ投稿の状態管理
class BlogNotifier extends StateNotifier<List<BlogPost>> {
  BlogNotifier() : super(_samplePosts);

  /// 投稿を追加
  void addPost({
    required String title,
    required String content,
    String? imageUrl,
    List<String> tags = const [],
    bool isPublic = true,
  }) {
    final post = BlogPost(
      id: _uuid.v4(),
      title: title,
      content: content,
      imageUrl: imageUrl,
      author: _currentUser,
      publishedAt: DateTime.now(),
      tags: tags,
      isPublic: isPublic,
    );
    state = [post, ...state];
  }

  /// いいねをトグル
  void toggleLike(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
      return post;
    }).toList();
  }

  /// 公開設定をトグル
  void togglePublic(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(isPublic: !post.isPublic);
      }
      return post;
    }).toList();
  }

  /// 投稿を削除
  void deletePost(String postId) {
    state = state.where((p) => p.id != postId).toList();
  }
}

final blogProvider =
    StateNotifierProvider<BlogNotifier, List<BlogPost>>((ref) {
  return BlogNotifier();
});

/// 公開投稿のみ
final publicPostsProvider = Provider<List<BlogPost>>((ref) {
  final posts = ref.watch(blogProvider);
  return posts.where((p) => p.isPublic).toList();
});

/// 自分の投稿のみ
final myPostsProvider = Provider<List<BlogPost>>((ref) {
  final posts = ref.watch(blogProvider);
  return posts.where((p) => p.author.id == _currentUser.id).toList();
});

/// 現在のユーザー（認証実装後は差し替え）
const _currentUser = BlogAuthor(
  id: 'user_001',
  name: '田中 花子',
  bio: '都市農業が趣味のベランダ菜園家です🌱',
);

/// サンプルブログ投稿
final _samplePosts = [
  BlogPost(
    id: 'post_001',
    title: 'トマトが赤くなってきた！',
    content: 'ベランダで育てているトマトがついに赤くなってきました。'
        '毎日水やりをした甲斐がありました。あと3日くらいで収穫できそうです😊',
    imageUrl: null,
    author: _currentUser,
    publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
    tags: ['トマト', '収穫前', 'ベランダ菜園'],
    likeCount: 12,
    commentCount: 3,
  ),
  BlogPost(
    id: 'post_002',
    title: 'アブラムシの対策を試してみた',
    content: '先週からバジルにアブラムシがついてしまい、色々対策を試してみました。'
        '今日はペットボトルスプレーで水洗いする方法を実践。効果があるといいな。',
    imageUrl: null,
    author: const BlogAuthor(
      id: 'user_002',
      name: '鈴木 太郎',
      bio: '菜園歴5年のベテランです',
    ),
    publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    tags: ['病害虫対策', 'バジル', 'アブラムシ'],
    likeCount: 8,
    commentCount: 5,
  ),
  BlogPost(
    id: 'post_003',
    title: 'キュウリが豊作すぎる問題',
    content: 'キュウリが毎日大量に収穫できて嬉しい反面、食べきれない…'
        '近所の方に分けたり、ぬか漬けにしたりして消費中です。',
    imageUrl: null,
    author: _currentUser,
    publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    tags: ['キュウリ', '豊作', '夏野菜'],
    likeCount: 24,
    commentCount: 10,
  ),
];
