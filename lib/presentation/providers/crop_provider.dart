import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/crop.dart';

/// 作物図鑑の検索クエリプロバイダー
final cropSearchQueryProvider = StateProvider<String>((ref) => '');

/// 作物図鑑データプロバイダー（ローカルデータ）
final cropDatabaseProvider = Provider<List<Crop>>((ref) {
  return _cropDatabase;
});

/// 検索結果プロバイダー
final filteredCropsProvider = Provider<List<Crop>>((ref) {
  final query = ref.watch(cropSearchQueryProvider).toLowerCase();
  final crops = ref.watch(cropDatabaseProvider);

  if (query.isEmpty) return crops;

  return crops.where((crop) {
    return crop.name.contains(query) ||
        crop.nameEn.toLowerCase().contains(query) ||
        crop.description.contains(query);
  }).toList();
});

/// 育てている作物の管理
class GrowingCropsNotifier extends StateNotifier<List<String>> {
  GrowingCropsNotifier() : super(['tomato_001', 'basil_001', 'cucumber_001']);

  void addCrop(String cropId) {
    if (!state.contains(cropId)) {
      state = [...state, cropId];
    }
  }

  void removeCrop(String cropId) {
    state = state.where((id) => id != cropId).toList();
  }
}

final growingCropsProvider =
    StateNotifierProvider<GrowingCropsNotifier, List<String>>((ref) {
  return GrowingCropsNotifier();
});

/// 育てている作物の詳細情報
final growingCropDetailsProvider = Provider<List<Crop>>((ref) {
  final growingIds = ref.watch(growingCropsProvider);
  final allCrops = ref.watch(cropDatabaseProvider);
  return allCrops.where((c) => growingIds.contains(c.id)).toList();
});

/// 作物データベース（サンプルデータ）
final _cropDatabase = [
  const Crop(
    id: 'tomato_001',
    name: 'トマト',
    nameEn: 'Tomato',
    description: '家庭菜園で最も人気のある野菜の一つ。'
        '日当たりと水はけの良い場所で育てましょう。',
    imageUrl: '',
    growingMethod: '支柱を立てて誘引しながら育てます。'
        '1本仕立てにすることで実が大きく育ちます。'
        '摘心・摘葉を定期的に行いましょう。',
    growingPeriod: '種まきから収穫まで約100〜120日。'
        '苗植えからは約60〜80日で収穫できます。',
    suitableSeasons: ['春', '夏'],
    commonPests: ['アブラムシ', 'ハダニ', 'コナジラミ'],
    commonDiseases: ['疫病', '青枯れ病', 'モザイク病'],
    difficulty: DifficultyLevel.medium,
    suitableLocations: [GrowingLocationType.field, GrowingLocationType.balcony],
    wateringFrequencyDays: 1,
    harvestInfo: '実が赤く熟したら収穫時期です。ヘタの付け根で摘み取ります。',
  ),
  const Crop(
    id: 'basil_001',
    name: 'バジル',
    nameEn: 'Basil',
    description: 'イタリア料理に欠かせないハーブ。'
        '窓辺でも気軽に育てられる初心者向けの植物です。',
    imageUrl: '',
    growingMethod: '花が咲いたら摘み取ることで長く収穫できます。'
        '摘心することで脇芽が増え、葉の収穫量が増えます。',
    growingPeriod: '種まきから収穫まで約1〜2ヶ月。',
    suitableSeasons: ['春', '夏', '秋'],
    commonPests: ['アブラムシ', 'ヨトウムシ'],
    commonDiseases: ['立枯れ病', '灰色かび病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [
      GrowingLocationType.indoor,
      GrowingLocationType.balcony,
    ],
    wateringFrequencyDays: 1,
    harvestInfo: '葉が10枚以上になったら随時収穫できます。',
  ),
  const Crop(
    id: 'cucumber_001',
    name: 'キュウリ',
    nameEn: 'Cucumber',
    description: '夏野菜の定番。育てやすく収穫量も多い人気の野菜です。',
    imageUrl: '',
    growingMethod: '網やネットに誘引しながら育てます。'
        '親づる・子づるを適切に整理することが重要です。',
    growingPeriod: '苗植えから約60〜70日で収穫開始。その後は毎日〜2日おきに収穫できます。',
    suitableSeasons: ['春', '夏'],
    commonPests: ['アブラムシ', 'ウリハムシ', 'ハダニ'],
    commonDiseases: ['うどんこ病', 'べと病', '炭疽病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [
      GrowingLocationType.field,
      GrowingLocationType.balcony,
    ],
    wateringFrequencyDays: 1,
    harvestInfo: '20〜22cmになったら収穫時期。放置すると大きくなりすぎるので早めに収穫を。',
  ),
  const Crop(
    id: 'strawberry_001',
    name: 'イチゴ',
    nameEn: 'Strawberry',
    description: 'ベランダのプランターでも育てられる人気のフルーツ。'
        'ランナーで増やすことができます。',
    imageUrl: '',
    growingMethod: '秋に苗を植え付け、春に収穫します。'
        'ランナー（茎）が出たら切り取りましょう。',
    growingPeriod: '苗植えから収穫まで約5〜6ヶ月。',
    suitableSeasons: ['秋', '春'],
    commonPests: ['アブラムシ', 'ハダニ', 'ナメクジ'],
    commonDiseases: ['灰色かび病', 'うどんこ病', '炭疽病'],
    difficulty: DifficultyLevel.medium,
    suitableLocations: [
      GrowingLocationType.balcony,
      GrowingLocationType.field,
    ],
    wateringFrequencyDays: 2,
    harvestInfo: '実が完全に赤くなってから収穫します。ヘタの付け根からハサミで切ります。',
  ),
  const Crop(
    id: 'lettuce_001',
    name: 'レタス',
    nameEn: 'Lettuce',
    description: '室内でも育てられる葉野菜。'
        '春と秋が育てやすい季節です。',
    imageUrl: '',
    growingMethod: '間引きをしながら育てます。'
        '外葉から順に収穫する「かき取り収穫」が可能です。',
    growingPeriod: '種まきから収穫まで約60〜90日。',
    suitableSeasons: ['春', '秋'],
    commonPests: ['アブラムシ', 'ヨトウムシ', 'ナメクジ'],
    commonDiseases: ['腐敗病', '灰色かび病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [
      GrowingLocationType.indoor,
      GrowingLocationType.balcony,
      GrowingLocationType.field,
    ],
    wateringFrequencyDays: 2,
    harvestInfo: '結球したら収穫時期。外葉から順にかき取り収穫もできます。',
  ),
  const Crop(
    id: 'spinach_001',
    name: 'ほうれん草',
    nameEn: 'Spinach',
    description: '栄養価が高く、秋冬に育てやすい葉野菜。'
        '霜にあたると甘みが増します。',
    imageUrl: '',
    growingMethod: '直まきで育てます。間引きをしながら育てましょう。',
    growingPeriod: '種まきから収穫まで約40〜60日。',
    suitableSeasons: ['秋', '冬', '春'],
    commonPests: ['アブラムシ', 'ハモグリバエ'],
    commonDiseases: ['べと病', '立枯れ病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [
      GrowingLocationType.field,
      GrowingLocationType.balcony,
    ],
    wateringFrequencyDays: 2,
    harvestInfo: '草丈20〜25cmになったら根元から切り取って収穫します。',
  ),
  const Crop(
    id: 'pepper_001',
    name: 'ピーマン',
    nameEn: 'Bell Pepper',
    description: 'トマトと同じ育て方ができる夏野菜。'
        '緑のうちから収穫できます。',
    imageUrl: '',
    growingMethod: '支柱を立てて2〜3本仕立てで育てます。'
        'わき芽を整理しながら管理します。',
    growingPeriod: '苗植えから収穫開始まで約60〜70日。',
    suitableSeasons: ['春', '夏'],
    commonPests: ['アブラムシ', 'カメムシ', 'タバコガ'],
    commonDiseases: ['疫病', '炭疽病', 'モザイク病'],
    difficulty: DifficultyLevel.medium,
    suitableLocations: [
      GrowingLocationType.field,
      GrowingLocationType.balcony,
    ],
    wateringFrequencyDays: 1,
    harvestInfo: '緑のうちは5〜7cm、赤いピーマンは完熟してから収穫。',
  ),
  const Crop(
    id: 'eggplant_001',
    name: 'ナス',
    nameEn: 'Eggplant',
    description: '夏の定番野菜。水を好むので水やりが重要です。',
    imageUrl: '',
    growingMethod: '3本仕立てで育てます。更新剪定で秋まで収穫できます。',
    growingPeriod: '苗植えから収穫まで約60〜70日。',
    suitableSeasons: ['春', '夏'],
    commonPests: ['アブラムシ', 'ハダニ', 'テントウムシダマシ'],
    commonDiseases: ['半身萎凋病', '青枯れ病', 'うどんこ病'],
    difficulty: DifficultyLevel.medium,
    suitableLocations: [GrowingLocationType.field, GrowingLocationType.balcony],
    wateringFrequencyDays: 1,
    harvestInfo: '15〜20cmになったら収穫時期。皮につやがある状態が食べごろです。',
  ),
  const Crop(
    id: 'broccoli_001',
    name: 'ブロッコリー',
    nameEn: 'Broccoli',
    description: '緑黄色野菜の代表格。ビタミンCが豊富で栄養価が高い人気野菜です。',
    imageUrl: '',
    growingMethod: '苗を深めに植え、支柱で支えます。頂花蕾を収穫後も側枝が育ちます。',
    growingPeriod: '苗植えから収穫まで約60〜80日。',
    suitableSeasons: ['秋', '冬'],
    commonPests: ['アオムシ', 'コナガ', 'アブラムシ'],
    commonDiseases: ['べと病', '黒腐病'],
    difficulty: DifficultyLevel.medium,
    suitableLocations: [GrowingLocationType.field, GrowingLocationType.balcony],
    wateringFrequencyDays: 2,
    harvestInfo: '頂花蕾が直径15〜20cmになり、つぼみが固いうちに収穫します。',
  ),
  const Crop(
    id: 'carrot_001',
    name: 'ニンジン',
    nameEn: 'Carrot',
    description: 'β-カロテンが豊富な根菜。深めのプランターでも育てられます。',
    imageUrl: '',
    growingMethod: '種を直播きします。発芽後は間引きを行い、最終的に10cm間隔にします。',
    growingPeriod: '種まきから収穫まで約100〜120日。',
    suitableSeasons: ['春', '秋'],
    commonPests: ['キアゲハ', 'ネキリムシ'],
    commonDiseases: ['黒葉枯病', '軟腐病'],
    difficulty: DifficultyLevel.medium,
    suitableLocations: [GrowingLocationType.field, GrowingLocationType.balcony],
    wateringFrequencyDays: 2,
    harvestInfo: '根の直径が3〜4cmになったら収穫。肩の部分が地面から出てきたら収穫サインです。',
  ),
  const Crop(
    id: 'pumpkin_001',
    name: 'カボチャ',
    nameEn: 'Pumpkin',
    description: 'つるが広がるが、栄養価が高く保存性も抜群の秋の定番野菜です。',
    imageUrl: '',
    growingMethod: 'つるを誘引し、人工授粉で確実に実を付けます。着果後は果実の下に敷き藁をします。',
    growingPeriod: '種まきから収穫まで約100〜120日。',
    suitableSeasons: ['春', '夏'],
    commonPests: ['アブラムシ', 'ウリハムシ'],
    commonDiseases: ['うどんこ病', 'べと病'],
    difficulty: DifficultyLevel.medium,
    suitableLocations: [GrowingLocationType.field],
    wateringFrequencyDays: 2,
    harvestInfo: 'ヘタがコルク状になり、果皮が固くなったら収穫時期です。',
  ),
  const Crop(
    id: 'onion_001',
    name: 'タマネギ',
    nameEn: 'Onion',
    description: '料理の基本野菜。秋に苗を植えて翌春に収穫する越冬野菜です。',
    imageUrl: '',
    growingMethod: '秋に苗を植え付け、冬を越して春に肥大します。倒伏したら収穫のサインです。',
    growingPeriod: '苗植えから収穫まで約5〜6ヶ月。',
    suitableSeasons: ['秋', '春'],
    commonPests: ['ネギアザミウマ', 'ネギコガ'],
    commonDiseases: ['べと病', '軟腐病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [GrowingLocationType.field, GrowingLocationType.balcony],
    wateringFrequencyDays: 3,
    harvestInfo: '葉が倒れて黄色くなったら収穫時期。晴れた日に引き抜き、風通しの良い場所で乾燥させます。',
  ),
  const Crop(
    id: 'corn_001',
    name: 'トウモロコシ',
    nameEn: 'Corn',
    description: '夏の風物詩。甘みが強く、採れたてのフレッシュな味は格別です。',
    imageUrl: '',
    growingMethod: '花粉を確実に受粉させるため、複数株をまとめて植えます。人工授粉も有効です。',
    growingPeriod: '種まきから収穫まで約80〜100日。',
    suitableSeasons: ['春', '夏'],
    commonPests: ['アワノメイガ', 'アブラムシ'],
    commonDiseases: ['すす病', '黒穂病'],
    difficulty: DifficultyLevel.medium,
    suitableLocations: [GrowingLocationType.field],
    wateringFrequencyDays: 1,
    harvestInfo: 'ひげが茶色くなってから20〜25日後が収穫時期。朝収穫して早めに食べましょう。',
  ),
  const Crop(
    id: 'daikon_001',
    name: 'ダイコン',
    nameEn: 'Daikon Radish',
    description: '日本の食卓に欠かせない根菜。生でも煮ても美味しい万能野菜です。',
    imageUrl: '',
    growingMethod: '種を直播きし、間引きを繰り返します。深く耕して石や根がない土壌を作ることが大切です。',
    growingPeriod: '種まきから収穫まで約60〜70日。',
    suitableSeasons: ['秋', '冬'],
    commonPests: ['アオムシ', 'コナガ', 'アブラムシ'],
    commonDiseases: ['べと病', '軟腐病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [GrowingLocationType.field],
    wateringFrequencyDays: 2,
    harvestInfo: '根の直径が7〜8cmになり、葉が外側から黄色くなってきたら収穫時期です。',
  ),
  const Crop(
    id: 'potato_001',
    name: 'ジャガイモ',
    nameEn: 'Potato',
    description: '種芋から育てる根菜。収穫の達成感が大きく、ファミリー菜園でも人気です。',
    imageUrl: '',
    growingMethod: '種芋を植え付け、芽が出たら芽かきをして2〜3本に絞ります。土寄せを2〜3回行います。',
    growingPeriod: '種芋植え付けから収穫まで約90〜100日。',
    suitableSeasons: ['春'],
    commonPests: ['アブラムシ', 'テントウムシダマシ'],
    commonDiseases: ['疫病', '軟腐病', 'モザイク病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [GrowingLocationType.field],
    wateringFrequencyDays: 3,
    harvestInfo: '茎や葉が黄色くなって枯れてきたら収穫時期。晴れた日に掘り出し、表面を乾かします。',
  ),
  const Crop(
    id: 'shiso_001',
    name: 'シソ',
    nameEn: 'Perilla',
    description: '和食に欠かせないハーブ。育てやすく、次々と葉を収穫できます。',
    imageUrl: '',
    growingMethod: '日当たりか半日陰で育てます。花穂が出てきたら摘み取ると長く収穫できます。',
    growingPeriod: '種まきから収穫まで約40〜60日。',
    suitableSeasons: ['春', '夏', '秋'],
    commonPests: ['アブラムシ', 'ハスモンヨトウ'],
    commonDiseases: ['さび病', 'モザイク病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [GrowingLocationType.indoor, GrowingLocationType.balcony, GrowingLocationType.field],
    wateringFrequencyDays: 1,
    harvestInfo: '葉が十分大きくなったら随時収穫できます。葉が10枚以上になったら収穫開始のめやす。',
  ),
  const Crop(
    id: 'negi_001',
    name: 'ネギ',
    nameEn: 'Green Onion',
    description: '薬味や鍋に欠かせない定番野菜。プランターでも手軽に育てられます。',
    imageUrl: '',
    growingMethod: '種まきか苗植えで育てます。土寄せをしながら白い部分を長くします。',
    growingPeriod: '種まきから収穫まで約120〜150日。苗からは約60〜90日。',
    suitableSeasons: ['春', '秋'],
    commonPests: ['ネギアザミウマ', 'ネギコガ'],
    commonDiseases: ['さび病', 'べと病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [GrowingLocationType.field, GrowingLocationType.balcony],
    wateringFrequencyDays: 2,
    harvestInfo: '長さ50〜60cmになったら収穫できます。根元から切り取るか、引き抜きます。',
  ),
  const Crop(
    id: 'cabbage_001',
    name: 'キャベツ',
    nameEn: 'Cabbage',
    description: 'ビタミンCが豊富な葉野菜。サラダや炒め物に大活躍する定番野菜です。',
    imageUrl: '',
    growingMethod: '苗を植え付け、外葉が結球を包み込むように育ちます。防虫ネットが効果的です。',
    growingPeriod: '苗植えから収穫まで約60〜80日。',
    suitableSeasons: ['秋', '冬', '春'],
    commonPests: ['アオムシ', 'コナガ', 'アブラムシ'],
    commonDiseases: ['べと病', '黒腐病', '軟腐病'],
    difficulty: DifficultyLevel.medium,
    suitableLocations: [GrowingLocationType.field, GrowingLocationType.balcony],
    wateringFrequencyDays: 2,
    harvestInfo: '球が十分締まって硬くなったら収穫時期。結球部分を手で押して硬ければOKです。',
  ),
  const Crop(
    id: 'okra_001',
    name: 'オクラ',
    nameEn: 'Okra',
    description: 'ネバネバ成分が栄養豊富。暑さに強く夏の家庭菜園で人気の野菜です。',
    imageUrl: '',
    growingMethod: '暖かくなってから種まきします。草丈が高くなるので支柱が必要です。',
    growingPeriod: '種まきから収穫まで約60〜70日。',
    suitableSeasons: ['夏'],
    commonPests: ['アブラムシ', 'ハダニ'],
    commonDiseases: ['輪紋病', '立枯れ病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [GrowingLocationType.field, GrowingLocationType.balcony],
    wateringFrequencyDays: 1,
    harvestInfo: '開花後4〜5日、長さ7〜8cmのうちに収穫します。大きくなると固くなります。',
  ),
  const Crop(
    id: 'edamame_001',
    name: 'エダマメ',
    nameEn: 'Edamame',
    description: '枝豆はビールのお供に最適。採れたての甘みは格別です。',
    imageUrl: '',
    growingMethod: '直播きまたは育苗して植え付けます。開花期前後の水やりが重要です。',
    growingPeriod: '種まきから収穫まで約70〜90日。',
    suitableSeasons: ['春', '夏'],
    commonPests: ['カメムシ', 'ダイズアブラムシ'],
    commonDiseases: ['べと病', 'モザイク病'],
    difficulty: DifficultyLevel.easy,
    suitableLocations: [GrowingLocationType.field, GrowingLocationType.balcony],
    wateringFrequencyDays: 2,
    harvestInfo: '莢が膨らんで豆が莢にしっかり詰まったら収穫時期。株ごと引き抜いて収穫します。',
  ),
];
