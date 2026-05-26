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
];
