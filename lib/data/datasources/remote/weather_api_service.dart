import 'package:dio/dio.dart';
import '../../models/weather_model.dart';

/// OpenWeatherMap API を利用した天気情報取得サービス
/// （ウェザーニュースAPI等に差し替え可能な設計）
class WeatherApiService {
  final Dio _dio;

  // OpenWeatherMap APIのベースURL
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // APIキーは環境変数から取得（本番環境では.envファイルで管理）
  static const String _apiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );

  WeatherApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            ));

  /// 現在地の天気情報を取得
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',  // 摂氏
          'lang': 'ja',       // 日本語レスポンス
        },
      );
      return WeatherModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw WeatherApiException(
        message: '天気情報の取得に失敗しました: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// 都市名で天気情報を取得
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': '$cityName,JP',
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'ja',
        },
      );
      return WeatherModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw WeatherApiException(
        message: '天気情報の取得に失敗しました: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// 5日間の天気予報を取得
  Future<List<WeatherModel>> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'ja',
          'cnt': 40, // 3時間ごと×40件（5日分）
        },
      );
      final list = (response.data['list'] as List)
          .map((item) => WeatherModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      throw WeatherApiException(
        message: '予報の取得に失敗しました: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

/// 天気API専用の例外クラス
class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  WeatherApiException({required this.message, this.statusCode});

  @override
  String toString() => 'WeatherApiException: $message (status: $statusCode)';
}
