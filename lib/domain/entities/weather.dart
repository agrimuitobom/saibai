import 'package:equatable/equatable.dart';

/// 天気情報エンティティ
class Weather extends Equatable {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String conditionJa;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final DateTime fetchedAt;

  const Weather({
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

  /// 天気アドバイス（栽培向け）
  String get gardeningAdvice {
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return '雨の日は水やり不要です。病害虫に注意しましょう。';
    }
    if (temperature > 35) {
      return '猛暑日です。日よけと水やりをこまめに行いましょう。';
    }
    if (temperature < 5) {
      return '寒波に注意。防寒対策をしましょう。';
    }
    if (condition.contains('clear') && temperature > 20) {
      return '菜園日和です！定植や収穫に最適です。';
    }
    return '適度な水やりを忘れずに。';
  }

  @override
  List<Object?> get props => [
        location,
        temperature,
        condition,
        humidity,
        fetchedAt,
      ];
}
