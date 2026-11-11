import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final String condition;
  final int temperature;
  final int humidity;
  final String icon;
  final String location;

  const WeatherData({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.icon,
    required this.location,
  });
}

class _Place {
  final String name;
  final double latitude;
  final double longitude;

  const _Place(this.name, this.latitude, this.longitude);
}

/// Open-Meteo (https://open-meteo.com) から現在の天気を取得する。
/// APIキー不要。端末の現在地を使い、取得できない場合は設定の栽培地域の
/// 代表都市にフォールバックする。
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String currentLocationLabel = '現在地';

  static const Map<String, _Place> _regionPlaces = {
    '東日本': _Place('東京', 35.6895, 139.6917),
    '西日本': _Place('大阪', 34.6937, 135.5023),
    '中部': _Place('名古屋', 35.1815, 136.9066),
    '九州': _Place('福岡', 33.5902, 130.4017),
  };

  /// 天気を順に流す。まず設定の栽培地域の代表都市の天気をすぐに返し、
  /// 端末の現在地が取得できたら、その場所の天気で上書きする。
  /// ブラウザによっては位置情報の問い合わせが応答を返さないことがあるため、
  /// 現在地を待たずに表示できるようにしている。
  Stream<WeatherData> watchWeather({String region = '東日本'}) async* {
    final currentPlace = _currentPlace();
    final fallback = _regionPlaces[region] ?? _regionPlaces['東日本']!;

    Object? fallbackError;
    try {
      yield await _fetch(fallback);
    } catch (e) {
      fallbackError = e;
    }

    final place = await currentPlace;
    if (place != null) {
      try {
        yield await _fetch(place);
        return;
      } catch (_) {
        // 現在地の天気が取れなくても、地域の天気が出ていればそのままにする
      }
    }
    if (fallbackError != null) throw fallbackError;
  }

  Future<WeatherData> _fetch(_Place place) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': place.latitude.toStringAsFixed(4),
      'longitude': place.longitude.toStringAsFixed(4),
      'current': 'temperature_2m,relative_humidity_2m,weather_code,is_day',
      'timezone': 'auto',
    });
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Open-Meteo returned ${response.statusCode}');
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes))
        as Map<String, dynamic>;
    final current = body['current'] as Map<String, dynamic>;
    final code = (current['weather_code'] as num).toInt();
    final isDay = (current['is_day'] as num?)?.toInt() != 0;
    final (condition, icon) = _describe(code, isDay);

    return WeatherData(
      condition: condition,
      temperature: (current['temperature_2m'] as num).round(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      icon: icon,
      location: place.name,
    );
  }

  /// 端末の現在地。権限拒否・非対応・タイムアウト時は null。
  Future<_Place?> _currentPlace() async {
    try {
      // ブラウザ側のタイムアウトが効かず応答が返らないケースがあるので、
      // 許可ダイアログに答える時間も含めて Dart 側でも上限を設ける。
      return await _locate().timeout(_locationTimeout);
    } catch (_) {
      return null;
    }
  }

  static const Duration _locationTimeout = Duration(seconds: 30);

  Future<_Place?> _locate() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return _Place(currentLocationLabel, position.latitude, position.longitude);
  }

  /// WMO weather interpretation code → (日本語の天気, 絵文字)
  static (String, String) _describe(int code, bool isDay) {
    switch (code) {
      case 0:
        return ('快晴', isDay ? '☀️' : '🌙');
      case 1:
        return ('晴れ', isDay ? '🌤️' : '🌙');
      case 2:
        return ('晴れ時々くもり', '⛅');
      case 3:
        return ('くもり', '☁️');
      case 45:
      case 48:
        return ('霧', '🌫️');
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return ('霧雨', '🌦️');
      case 61:
      case 80:
        return ('弱い雨', '🌧️');
      case 63:
      case 66:
      case 81:
        return ('雨', '🌧️');
      case 65:
      case 67:
      case 82:
        return ('強い雨', '🌧️');
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return ('雪', '❄️');
      case 95:
      case 96:
      case 99:
        return ('雷雨', '⛈️');
      default:
        return ('不明', '🌡️');
    }
  }
}
