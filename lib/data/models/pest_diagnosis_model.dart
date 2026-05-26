import '../../domain/entities/pest_diagnosis.dart';

/// 病害虫診断結果のデータモデル
class PestDiagnosisModel {
  final String id;
  final String pestName;
  final String description;
  final double confidenceScore;
  final String severityLevel;
  final List<String> treatmentSteps;
  final List<String> preventionTips;
  final String imageUrl;
  final DateTime diagnosedAt;

  const PestDiagnosisModel({
    required this.id,
    required this.pestName,
    required this.description,
    required this.confidenceScore,
    required this.severityLevel,
    required this.treatmentSteps,
    required this.preventionTips,
    required this.imageUrl,
    required this.diagnosedAt,
  });

  /// 健康状態（問題なし）の結果を生成
  factory PestDiagnosisModel.healthy({required String imagePath}) {
    return PestDiagnosisModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pestName: '異常なし',
      description: '植物は健康な状態です。引き続き適切な管理を続けてください。',
      confidenceScore: 0.95,
      severityLevel: 'none',
      treatmentSteps: [],
      preventionTips: [
        '定期的な水やりを続ける',
        '適切な日光を確保する',
        '週に1回は葉の裏を確認する',
      ],
      imageUrl: imagePath,
      diagnosedAt: DateTime.now(),
    );
  }

  /// ドメインエンティティへの変換
  PestDiagnosis toEntity() {
    final severity = _parseSeverity(severityLevel);

    return PestDiagnosis(
      id: id,
      pestName: pestName,
      description: description,
      confidenceScore: confidenceScore,
      severity: severity,
      treatments: _buildTreatments(),
      preventionTips: preventionTips,
      imageUrl: imageUrl,
      diagnosedAt: diagnosedAt,
    );
  }

  SeverityLevel _parseSeverity(String level) {
    switch (level) {
      case 'mild':
        return SeverityLevel.mild;
      case 'moderate':
        return SeverityLevel.moderate;
      case 'severe':
        return SeverityLevel.severe;
      default:
        return SeverityLevel.none;
    }
  }

  List<PestTreatment> _buildTreatments() {
    if (treatmentSteps.isEmpty) return [];

    return [
      PestTreatment(
        title: '推奨される対処法',
        description: '$pestNameへの対処方法です。',
        steps: treatmentSteps,
      ),
    ];
  }
}
