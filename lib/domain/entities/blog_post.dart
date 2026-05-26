import 'package:equatable/equatable.dart';

/// ブログ投稿者プロフィール
class BlogAuthor extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? bio;

  const BlogAuthor({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bio,
  });

  @override
  List<Object?> get props => [id, name];
}

/// ブログ投稿エンティティ
class BlogPost extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final BlogAuthor author;
  final DateTime publishedAt;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final bool isPublic;
  final bool isLiked;

  const BlogPost({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.author,
    required this.publishedAt,
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isPublic = true,
    this.isLiked = false,
  });

  BlogPost copyWith({
    bool? isLiked,
    int? likeCount,
    bool? isPublic,
  }) {
    return BlogPost(
      id: id,
      title: title,
      content: content,
      imageUrl: imageUrl,
      author: author,
      publishedAt: publishedAt,
      tags: tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount,
      isPublic: isPublic ?? this.isPublic,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [id, title, publishedAt];
}
