import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/pest_diagnosis_model.dart';

/// AI病害虫診断サービス
/// Google Gemini API（gemini-1.5-flash）によるマルチモーダル画像診断
class PestDetectionService {
  // 使用するGeminiモデル名
  static const String _modelName = 'gemini-1.5-flash';

  // APIキーは環境変数から取得（dart-define で GEMINI_API_KEY を渡すこと）
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY',
  );

  // Gemini に送る診断プロンプト（日本語）
  static const String _diagnosisPrompt = '''
この植物の画像を詳しく診断してください。
病害虫や病気が見られる場合は以下のJSON形式で返してください：
{
  "detected": true,
  "pest_name": "病害虫・病気の名前",
  "description": "詳細な説明",
  "severity": "mild/moderate/severe",
  "treatments": ["対処法1", "対処法2"],
  "prevention": ["予防法1", "予防法2"]
}
問題がない場合は {"detected": false} を返してください。
JSONのみを返し、前後に余分なテキストや```マークダウンは含めないでください。
''';

  /// 画像ファイルから病害虫を診断する
  ///
  /// [imageFile] 診断する画像ファイル
  /// 戻り値: 診断結果モデルのリスト
  Future<List<PestDiagnosisModel>> diagnoseFromFile(File imageFile) async {
    try {
      // 画像バイトを読み込み、MIMEタイプを判定する
      final imageBytes = await imageFile.readAsBytes();
      final mimeType = _detectMimeType(imageFile.path);

      // Gemini クライアントを初期化する
      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
      );

      // マルチモーダルコンテンツを構築する（テキストプロンプト + 画像）
      final content = [
        Content.multi([
          TextPart(_diagnosisPrompt),
          DataPart(mimeType, imageBytes),
        ]),
      ];

      // Gemini API にリクエストを送信する
      final response = await model.generateContent(content);

      // レスポンステキストを取得する
      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        // レスポンスが空の場合は健康状態として扱う
        return [PestDiagnosisModel.healthy(imagePath: imageFile.path)];
      }

      // JSONレスポンスをパースして診断結果に変換する
      return _parseGeminiResponse(
        responseText,
        imagePath: imageFile.path,
      );
    } on GenerativeAIException catch (e) {
      // Gemini API 固有のエラー
      throw PestDetectionException(
        message: 'Gemini API エラー: ${e.message}',
      );
    } catch (e) {
      // その他の予期しないエラー
      throw PestDetectionException(
        message: '画像診断中に予期しないエラーが発生しました: $e',
      );
    }
  }

  /// Gemini のレスポンステキストを病害虫診断結果モデルのリストに変換する
  List<PestDiagnosisModel> _parseGeminiResponse(
    String responseText, {
    required String imagePath,
  }) {
    try {
      // レスポンスからJSONを抽出する（マークダウンコードブロックが含まれる場合に対応）
      final jsonString = _extractJson(responseText);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // "detected" フラグが false、または存在しない場合は健康状態とみなす
      final detected = jsonData['detected'] as bool? ?? false;
      if (!detected) {
        return [PestDiagnosisModel.healthy(imagePath: imagePath)];
      }

      // 重症度文字列を検証・正規化する（Gemini が想定外の値を返す場合に備える）
      final rawSeverity = jsonData['severity'] as String? ?? 'mild';
      final severity = _normalizeSeverity(rawSeverity);

      // treatmentsリストを安全にキャストする
      final treatmentsList = jsonData['treatments'];
      final treatments = treatmentsList is List
          ? treatmentsList.map((e) => e.toString()).toList()
          : <String>[];

      // preventionリストを安全にキャストする
      final preventionList = jsonData['prevention'];
      final prevention = preventionList is List
          ? preventionList.map((e) => e.toString()).toList()
          : <String>[];

      // 診断結果モデルを生成する
      final diagnosis = PestDiagnosisModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pestName: jsonData['pest_name'] as String? ?? '不明な病害虫',
        description: jsonData['description'] as String? ?? '',
        // Gemini はseverityを返すため、confidenceScoreはseverityから推定する
        confidenceScore: _severityToConfidence(severity),
        severityLevel: severity,
        treatmentSteps: treatments,
        preventionTips: prevention,
        imageUrl: imagePath,
        diagnosedAt: DateTime.now(),
      );

      return [diagnosis];
    } on FormatException catch (e) {
      // JSONパースに失敗した場合は診断エラーとして例外を投げる
      throw PestDetectionException(
        message: 'Gemini のレスポンスをJSONとして解析できませんでした: $e\nレスポンス: $responseText',
      );
    }
  }

  /// レスポンステキストからJSONブロックを抽出する
  ///
  /// Gemini がマークダウンのコードブロック（```json ... ```）で
  /// 囲んで返した場合でも正しく取り出せるようにする
  String _extractJson(String text) {
    // ```json ... ``` または ``` ... ``` ブロックを検索する
    final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = codeBlockRegex.firstMatch(text);
    if (match != null) {
      return match.group(1)!.trim();
    }

    // コードブロックがない場合はテキストをそのまま返す
    return text.trim();
  }

  /// 重症度文字列を正規化する（想定外の値は "mild" にフォールバック）
  String _normalizeSeverity(String severity) {
    const validLevels = {'mild', 'moderate', 'severe'};
    final normalized = severity.toLowerCase().trim();
    return validLevels.contains(normalized) ? normalized : 'mild';
  }

  /// 重症度スコアから信頼度スコアを推定する
  ///
  /// Gemini は確率値を返さないため、severity に基づいて代替値を割り当てる
  double _severityToConfidence(String severity) {
    switch (severity) {
      case 'severe':
        return 0.90;
      case 'moderate':
        return 0.75;
      case 'mild':
      default:
        return 0.60;
    }
  }

  /// ファイルパスの拡張子から画像の MIMEタイプを判定する
  String _detectMimeType(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    // デフォルトはJPEGとみなす
    return 'image/jpeg';
  }
}

/// 病害虫診断専用の例外クラス
class PestDetectionException implements Exception {
  final String message;

  /// statusCode は Vision API 時代の互換性のために残しているが、
  /// Gemini API ではHTTPステータスコードを直接取得しないため省略可能
  final int? statusCode;

  PestDetectionException({required this.message, this.statusCode});

  @override
  String toString() =>
      'PestDetectionException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}
