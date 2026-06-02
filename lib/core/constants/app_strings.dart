/// アプリ内の日本語文字列定数
class AppStrings {
  AppStrings._();

  // アプリ全般
  static const String appName = 'ベジグロ';
  static const String appTagline = 'Grow fresh. Grow happy.';

  // ナビゲーション
  static const String navHome = 'ホーム';
  static const String navPestChecker = '病害虫';
  static const String navCropEncyclopedia = '作物図鑑';
  static const String navBlog = 'ブログ';
  static const String navSettings = '設定';

  // ホーム画面
  static const String homeWeather = '今日の天気';
  static const String homeTask = 'タスク';
  static const String homeGrowing = '育てているもの';
  static const String homeNoTask = 'タスクはありません';
  static const String homeNoGrowing = '作物を追加してください';

  // 病害虫チェッカー
  static const String pestCheckerTitle = '病害虫チェッカー';
  static const String pestCheckerDescription = '病害虫の説明';
  static const String pestCheckerTreatment = '対処法';
  static const String pestCheckerPrevention = '対策・予防';
  static const String pestCheckerCamera = 'カメラで撮影';
  static const String pestCheckerGallery = 'アルバムから選択';
  static const String pestCheckerAnalyzing = '診断中...';
  static const String pestCheckerResult = '診断結果';
  static const String pestCheckerNoResult = '問題は検出されませんでした';

  // 作物図鑑
  static const String cropEncyclopediaTitle = '作物図鑑';
  static const String cropSearchHint = '作物名で検索...';
  static const String cropVegetableName = '野菜の名前';
  static const String cropGrowingMethod = '栽培方法や栽培期間';
  static const String cropPestDisease = '主な病気や病害虫';

  // ブログ
  static const String blogTitle = 'ブログ';
  static const String blogNewPost = '新しい投稿';
  static const String blogProfile = 'プロフィール';
  static const String blogMyPosts = '自分が出してきたブログ';
  static const String blogProfileName = '名前';

  // タスク
  static const String taskTitle = 'タスク';
  static const String taskWhatToDo = '何をするか';
  static const String taskWhenToDo = 'いつするか';
  static const String taskCategory = 'カテゴリー';
  static const String taskAddButton = '追加';
  static const String taskComplete = '完了';
  static const String taskDelete = '削除';

  // 設定
  static const String settingsTitle = 'アプリ設定';
  static const String settingsNotification = '通知';
  static const String settingsNotificationOn = 'オン';
  static const String settingsNotificationOff = 'オフ';
  static const String settingsPublicSetting = '公開設定';
  static const String settingsPublic = '公開';
  static const String settingsPrivate = '非公開';
  static const String settingsGrowingPlace = '栽培場所';
  static const String settingsBalcony = 'ベランダ';
  static const String settingsField = '畑・庭';
  static const String settingsIndoor = '室内';
  static const String settingsGrowingRegion = '栽培地域';
  static const String settingsEastJapan = '東日本';
  static const String settingsWestJapan = '西日本';
  static const String settingsCentralJapan = '中部';
  static const String settingsKyushu = '九州';

  // エラーメッセージ
  static const String errorGeneral = 'エラーが発生しました';
  static const String errorNetwork = 'ネットワークエラーが発生しました';
  static const String errorPermissionCamera = 'カメラへのアクセス許可が必要です';
  static const String errorPermissionGallery = 'フォトライブラリへのアクセス許可が必要です';

  // 共通ボタン
  static const String buttonSave = '保存';
  static const String buttonCancel = 'キャンセル';
  static const String buttonDelete = '削除';
  static const String buttonEdit = '編集';
  static const String buttonRetry = '再試行';
  static const String buttonClose = '閉じる';
}
