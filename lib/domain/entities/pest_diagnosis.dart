import 'package:equatable/equatable.dart';

/// 診断結果の重症度
enum SeverityLevel { none, mild, moderate, severe }

extension SeverityLevelExtension on SeverityLevel {
  String get label {
    switch (this) {
      case SeverityLevel.none:
        return '異常なし';
      case SeverityLevel.mild:
        return '軽度';
      case SeverityLevel.moderate:
        return '中程度';
      case SeverityLevel.severe:
        return '重度';
    }
  }
}

/// 病害虫の対処法
class PestTreatment extends Equatable {
  final String title;
  final String description;
  final List<String> steps;
  final String? productName;

  const PestTreatment({
    required this.title,
    required this.description,
    required this.steps,
    this.productName,
  });

  @override
  List<Object?> get props => [title];
}

/// 病害虫診断結果エンティティ
class PestDiagnosis extends Equatable {
  final String id;
  final String pestName;
  final String description;
  final double confidenceScore;
  final SeverityLevel severity;
  final List<PestTreatment> treatments;
  final List<String> preventionTips;
  final String imageUrl;
  final DateTime diagnosedAt;

  const PestDiagnosis({
    required this.id,
    required this.pestName,
    required this.description,
    required this.confidenceScore,
    required this.severity,
    required this.treatments,
    required this.preventionTips,
    required this.imageUrl,
    required this.diagnosedAt,
  });

  /// 信頼度のパーセント表示
  String get confidencePercent =>
      '${(confidenceScore * 100).toStringAsFixed(0)}%';

  @override
  List<Object?> get props => [id, pestName, diagnosedAt];
}
