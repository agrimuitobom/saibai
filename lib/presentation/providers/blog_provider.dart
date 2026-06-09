import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/blog_post_model.dart';

final blogPostsProvider =
    NotifierProvider<BlogPostsNotifier, List<BlogPostModel>>(
  BlogPostsNotifier.new,
);

class BlogPostsNotifier extends Notifier<List<BlogPostModel>> {
  @override
  List<BlogPostModel> build() {
    return _mockPosts;
  }

  void addPost(String title, String content) {
    final newPost = BlogPostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      authorId: 'user_1',
      authorName: 'ガーデナー',
      createdAt: DateTime.now(),
      likeCount: 0,
      tags: [],
    );
    state = [newPost, ...state];
  }

  void deletePost(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

final _mockPosts = [
  BlogPostModel(
    id: '1',
    title: 'トマトの育て方〜初心者でも簡単！',
    content: '今年初めてトマトを育てています。毎日水やりをして、わき芽かきも頑張っています。まだ花が咲いたばかりですが、早く実がなるのが楽しみです！苗を植えてから約2ヶ月、ようやく黄色い花が咲き始めました。毎朝確認するのが日課になっています。',
    authorId: 'user_2',
    authorName: '田中みどり',
    createdAt: DateTime(2026, 6, 1),
    likeCount: 12,
    tags: ['トマト', '初心者', '夏野菜'],
  ),
  BlogPostModel(
    id: '2',
    title: 'ベランダ菜園で夏野菜5種類に挑戦中',
    content: 'マンションのベランダで野菜を育てています。今年はトマト、きゅうり、ナス、ピーマン、バジルを育てています。スペースが限られているので、縦に伸ばす工夫をしています。プランターの配置を工夫することで、日当たりを均等にできるようにしました。',
    authorId: 'user_3',
    authorName: '鈴木はなこ',
    createdAt: DateTime(2026, 5, 28),
    likeCount: 8,
    tags: ['ベランダ菜園', '夏野菜', 'マンション'],
  ),
  BlogPostModel(
    id: '3',
    title: '秋の収穫祭！大根とキャベツが大豊作でした',
    content: '秋に植えた大根とキャベツがついに収穫できました！大根は30cmを超えるものも！キャベツも丸々と育って大満足です。来年は品種を変えてまた挑戦したいと思います。家族みんなで収穫したことが良い思い出になりました。',
    authorId: 'user_4',
    authorName: '山田たろう',
    createdAt: DateTime(2026, 5, 20),
    likeCount: 24,
    tags: ['大根', 'キャベツ', '収穫', '秋野菜'],
  ),
  BlogPostModel(
    id: '4',
    title: '病気に負けないトマト栽培のコツ',
    content: '去年はうどんこ病でトマトを全滅させてしまいました。今年はその反省を活かし、株間を広げて通気性を確保し、雨よけのビニール屋根を設置しました。今のところ順調です！早期発見・早期対処が大切だとわかりました。',
    authorId: 'user_1',
    authorName: 'ガーデナー',
    createdAt: DateTime(2026, 5, 15),
    likeCount: 31,
    tags: ['トマト', '病気対策', 'うどんこ病'],
  ),
];

final blogProfileProvider = Provider<BlogProfileModel>((ref) {
  return BlogProfileModel(
    id: 'user_1',
    name: 'ガーデナー',
    bio: '家庭菜園歴3年。ベランダと小さな庭で野菜を育てています。',
    postCount: 4,
    followerCount: 28,
  );
});

final myPostsProvider = Provider<List<BlogPostModel>>((ref) {
  final posts = ref.watch(blogPostsProvider);
  return posts.where((p) => p.authorId == 'user_1').toList();
});
