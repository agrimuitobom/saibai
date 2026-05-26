import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/weather_api_service.dart';
import '../../domain/entities/weather.dart';

/// 天気APIサービスのプロバイダー
final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService();
});

/// 天気情報の非同期状態プロバイダー
/// デフォルトは東京の座標
final weatherProvider = FutureProvider.autoDispose
    .family<Weather, ({double lat, double lon})>(
  (ref, location) async {
    final service = ref.watch(weatherApiServiceProvider);
    final model = await service.getCurrentWeather(
      latitude: location.lat,
      longitude: location.lon,
    );
    return model.toEntity();
  },
);

/// 東京の天気プロバイダー（デフォルト表示用）
final tokyoWeatherProvider = FutureProvider.autoDispose<Weather>((ref) async {
  final service = ref.watch(weatherApiServiceProvider);
  // 東京の座標
  final model = await service.getCurrentWeather(
    latitude: 35.6762,
    longitude: 139.6503,
  );
  return model.toEntity();
});

/// ユーザーの栽培地域に基づく天気プロバイダー
final regionalWeatherProvider =
    FutureProvider.autoDispose<Weather>((ref) async {
  final region = ref.watch(selectedRegionProvider);
  final service = ref.watch(weatherApiServiceProvider);

  final cityName = switch (region) {
    '東日本' => 'Tokyo',
    '西日本' => 'Osaka',
    '中部' => 'Nagoya',
    '九州' => 'Fukuoka',
    _ => 'Tokyo',
  };

  final model = await service.getWeatherByCity(cityName);
  return model.toEntity();
});

/// 選択中の地域プロバイダー（設定と共有）
final selectedRegionProvider =
    StateProvider<String>((ref) => '東日本');
