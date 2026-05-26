import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/pest_diagnosis_model.dart';

/// AI病害虫診断サービス
/// Google Cloud Vision API + カスタムモデルによる画像診断
class PestDetectionService {
  final Dio _dio;

  // Google Cloud Vision API エンドポイント
  static const String _visionApiUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  // APIキーは環境変数から取得
  static const String _apiKey = String.fromEnvironment(
    'GOOGLE_CLOUD_API_KEY',
    defaultValue: 'YOUR_VISION_API_KEY_HERE',
  );

  PestDetectionService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  /// 画像ファイルから病害虫を診断
  ///
  /// [imageFile] 診断する画像ファイル
  /// 戻り値: 診断結果モデルのリスト（信頼度順）
  Future<List<PestDiagnosisModel>> diagnoseFromFile(File imageFile) async {
    try {
      // 画像をBase64エンコード
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Vision API リクエストボディ
      final requestBody = {
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'LABEL_DETECTION', 'maxResults': 20},
              {'type': 'WEB_DETECTION', 'maxResults': 10},
              {'type': 'OBJECT_LOCALIZATION', 'maxResults': 10},
            ],
          }
        ]
      };

      final response = await _dio.post(
        '$_visionApiUrl?key=$_apiKey',
        data: requestBody,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // Vision APIレスポンスを解析して病害虫を特定
      return _parseVisionResponse(
        response.data as Map<String, dynamic>,
        imagePath: imageFile.path,
      );
    } on DioException catch (e) {
      throw PestDetectionException(
        message: '画像診断に失敗しました: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Vision APIのレスポンスを病害虫診断結果に変換
  List<PestDiagnosisModel> _parseVisionResponse(
    Map<String, dynamic> response, {
    required String imagePath,
  }) {
    final responses = response['responses'] as List?;
    if (responses == null || responses.isEmpty) return [];

    final firstResponse = responses.first as Map<String, dynamic>;
    final labels = firstResponse['labelAnnotations'] as List? ?? [];
    final webDetection =
        firstResponse['webDetection'] as Map<String, dynamic>? ?? {};

    // 病害虫関連のキーワードでフィルタリング
    final pestKeywords = [
      'aphid', 'アブラムシ',
      'whitefly', 'コナジラミ',
      'spider mite', 'ハダニ',
      'thrips', 'アザミウマ',
      'caterpillar', 'イモムシ',
      'fungus', 'カビ',
      'blight', '疫病',
      'rust', 'さび病',
      'mildew', 'うどんこ病',
      'leaf spot', '葉斑病',
      'rot', '腐敗',
      'wilt', '萎凋病',
    ];

    final results = <PestDiagnosisModel>[];

    for (final label in labels) {
      final description =
          (label['description'] as String? ?? '').toLowerCase();
      final score = (label['score'] as num?)?.toDouble() ?? 0.0;

      // 病害虫キーワードに一致するかチェック
      for (final keyword in pestKeywords) {
        if (description.contains(keyword.toLowerCase()) && score > 0.5) {
          results.add(_buildDiagnosisModel(
            labelDescription: label['description'] as String,
            confidence: score,
            imagePath: imagePath,
          ));
          break;
        }
      }
    }

    // 病害虫が検出されなかった場合は健康診断を返す
    if (results.isEmpty) {
      results.add(PestDiagnosisModel.healthy(imagePath: imagePath));
    }

    // 信頼度順にソート
    results.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return results;
  }

  /// ラベル情報から診断モデルを構築
  PestDiagnosisModel _buildDiagnosisModel({
    required String labelDescription,
    required double confidence,
    required String imagePath,
  }) {
    // 病害虫データベースからマッチング（実際はローカルDBまたはAPIから取得）
    final pestInfo = _getPestInfo(labelDescription);

    return PestDiagnosisModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pestName: pestInfo['name'] ?? labelDescription,
      description: pestInfo['description'] ?? '',
      confidenceScore: confidence,
      severityLevel: _calculateSeverity(confidence),
      treatmentSteps: pestInfo['treatments'] as List<String>? ?? [],
      preventionTips: pestInfo['prevention'] as List<String>? ?? [],
      imageUrl: imagePath,
      diagnosedAt: DateTime.now(),
    );
  }

  /// 信頼度から重症度を計算
  String _calculateSeverity(double confidence) {
    if (confidence >= 0.85) return 'severe';
    if (confidence >= 0.65) return 'moderate';
    return 'mild';
  }

  /// 病害虫情報データベース（ローカルキャッシュ）
  Map<String, dynamic> _getPestInfo(String labelDescription) {
    final label = labelDescription.toLowerCase();

    if (label.contains('aphid') || label.contains('アブラムシ')) {
      return {
        'name': 'アブラムシ',
        'description': '小さな虫が葉や茎に集団で寄生します。植物の汁を吸い、ウイルス病を媒介します。',
        'treatments': ['殺虫剤（ベニカXファインスプレー）を散布', '水でしっかり洗い流す', '天敵（テントウムシ）を利用する'],
        'prevention': ['植物を健康に保つ', '反射マルチを利用する', '定期的に葉の裏を確認する'],
      };
    }

    if (label.contains('mildew') || label.contains('うどんこ')) {
      return {
        'name': 'うどんこ病',
        'description': '白い粉状のカビが葉や茎を覆います。風通しが悪い環境で発生しやすいです。',
        'treatments': ['発病した葉を除去して処分', '重曹水溶液（1%）を散布', '専用殺菌剤を使用'],
        'prevention': ['適切な株間を確保する', '過湿を避ける', '窒素肥料の過多に注意する'],
      };
    }

    if (label.contains('blight') || label.contains('疫病')) {
      return {
        'name': '疫病',
        'description': '葉や茎に水浸状の斑点が現れ、急速に進展します。梅雨時期に多発します。',
        'treatments': ['発病した部分を速やかに除去', '殺菌剤（ダコニール）を散布', '被害株は根ごと処分'],
        'prevention': ['水はね防止のマルチを使用', '過湿を避ける', '排水の良い場所で育てる'],
      };
    }

    // デフォルトの情報
    return {
      'name': labelDescription,
      'description': '植物に影響を与える可能性のある問題が検出されました。',
      'treatments': ['専門家に相談してください', '被害部位を除去してください'],
      'prevention': ['定期的な観察を心がけてください', '適切な環境管理を行ってください'],
    };
  }
}

/// 病害虫診断専用の例外クラス
class PestDetectionException implements Exception {
  final String message;
  final int? statusCode;

  PestDetectionException({required this.message, this.statusCode});

  @override
  String toString() =>
      'PestDetectionException: $message (status: $statusCode)';
}
