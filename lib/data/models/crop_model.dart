class CropModel {
  final String id;
  final String name;
  final String emoji;
  final String cultivationMethod;
  final String cultivationPeriod;
  final String mainPests;
  final String difficulty;
  final String season;

  const CropModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cultivationMethod,
    required this.cultivationPeriod,
    required this.mainPests,
    required this.difficulty,
    required this.season,
  });

  CropModel copyWith({
    String? id,
    String? name,
    String? emoji,
    String? cultivationMethod,
    String? cultivationPeriod,
    String? mainPests,
    String? difficulty,
    String? season,
  }) {
    return CropModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      cultivationMethod: cultivationMethod ?? this.cultivationMethod,
      cultivationPeriod: cultivationPeriod ?? this.cultivationPeriod,
      mainPests: mainPests ?? this.mainPests,
      difficulty: difficulty ?? this.difficulty,
      season: season ?? this.season,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'cultivationMethod': cultivationMethod,
      'cultivationPeriod': cultivationPeriod,
      'mainPests': mainPests,
      'difficulty': difficulty,
      'season': season,
    };
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      cultivationMethod: json['cultivationMethod'] as String,
      cultivationPeriod: json['cultivationPeriod'] as String,
      mainPests: json['mainPests'] as String,
      difficulty: json['difficulty'] as String,
      season: json['season'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class GrowingCropModel {
  final String id;
  final String name;
  final DateTime plantingDate;
  final String? notes;

  const GrowingCropModel({
    required this.id,
    required this.name,
    required this.plantingDate,
    this.notes,
  });

  GrowingCropModel copyWith({
    String? id,
    String? name,
    DateTime? plantingDate,
    String? notes,
  }) {
    return GrowingCropModel(
      id: id ?? this.id,
      name: name ?? this.name,
      plantingDate: plantingDate ?? this.plantingDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plantingDate': plantingDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory GrowingCropModel.fromJson(Map<String, dynamic> json) {
    return GrowingCropModel(
      id: json['id'] as String,
      name: json['name'] as String,
      plantingDate: DateTime.parse(json['plantingDate'] as String),
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowingCropModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
