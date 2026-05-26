import '../../domain/entities/weather.dart';

/// OpenWeatherMap APIレスポンスのデータモデル
class WeatherModel {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String conditionJa;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final DateTime fetchedAt;

  const WeatherModel({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.conditionJa,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.fetchedAt,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;

    return WeatherModel(
      location: json['name'] as String? ?? '',
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      condition: weather['main'] as String? ?? '',
      conditionJa: weather['description'] as String? ?? '',
      humidity: (main['humidity'] as num).toInt(),
      windSpeed: (wind['speed'] as num).toDouble(),
      iconCode: weather['icon'] as String? ?? '',
      fetchedAt: DateTime.now(),
    );
  }

  /// ドメインエンティティへの変換
  Weather toEntity() {
    return Weather(
      location: location,
      temperature: temperature,
      feelsLike: feelsLike,
      condition: condition,
      conditionJa: conditionJa,
      humidity: humidity,
      windSpeed: windSpeed,
      iconCode: iconCode,
      fetchedAt: fetchedAt,
    );
  }

  /// 天気アイコンURL（OpenWeatherMap）
  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  /// 天気コードからフラッターアイコン名へのマッピング
  String get weatherEmoji {
    switch (condition) {
      case 'Clear':
        return '☀️';
      case 'Clouds':
        return '☁️';
      case 'Rain':
      case 'Drizzle':
        return '🌧️';
      case 'Thunderstorm':
        return '⛈️';
      case 'Snow':
        return '❄️';
      default:
        return '🌤️';
    }
  }
}
