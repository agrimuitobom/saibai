class BlogPostModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final String? imageUrl;
  final int likeCount;
  final List<String> tags;

  const BlogPostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.imageUrl,
    this.likeCount = 0,
    this.tags = const [],
  });

  BlogPostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    String? imageUrl,
    int? likeCount,
    List<String>? tags,
  }) {
    return BlogPostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'likeCount': likeCount,
      'tags': tags,
    };
  }

  factory BlogPostModel.fromJson(Map<String, dynamic> json) {
    return BlogPostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlogPostModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class BlogProfileModel {
  final String id;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final int postCount;
  final int followerCount;

  const BlogProfileModel({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
    this.postCount = 0,
    this.followerCount = 0,
  });

  BlogProfileModel copyWith({
    String? id,
    String? name,
    String? bio,
    String? avatarUrl,
    int? postCount,
    int? followerCount,
  }) {
    return BlogProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
    );
  }
}
