import 'package:equatable/equatable.dart';

/// 難易度レベル
enum DifficultyLevel { easy, medium, hard }

extension DifficultyLevelExtension on DifficultyLevel {
  String get label {
    switch (this) {
      case DifficultyLevel.easy:
        return '初心者向け';
      case DifficultyLevel.medium:
        return '中級者向け';
      case DifficultyLevel.hard:
        return '上級者向け';
    }
  }
}

/// 栽培場所タイプ
enum GrowingLocationType { balcony, field, indoor, all }

extension GrowingLocationTypeExtension on GrowingLocationType {
  String get label {
    switch (this) {
      case GrowingLocationType.balcony:
        return 'ベランダ';
      case GrowingLocationType.field:
        return '畑・庭';
      case GrowingLocationType.indoor:
        return '室内';
      case GrowingLocationType.all:
        return 'すべて';
    }
  }
}

/// 作物エンティティ（図鑑データ）
class Crop extends Equatable {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String imageUrl;
  final String growingMethod;
  final String growingPeriod;
  final List<String> suitableSeasons;
  final List<String> commonPests;
  final List<String> commonDiseases;
  final DifficultyLevel difficulty;
  final List<GrowingLocationType> suitableLocations;
  final int wateringFrequencyDays;
  final String harvestInfo;

  const Crop({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.imageUrl,
    required this.growingMethod,
    required this.growingPeriod,
    required this.suitableSeasons,
    required this.commonPests,
    required this.commonDiseases,
    required this.difficulty,
    required this.suitableLocations,
    required this.wateringFrequencyDays,
    required this.harvestInfo,
  });

  @override
  List<Object?> get props => [id, name];
}
