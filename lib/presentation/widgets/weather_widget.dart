import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/weather.dart';
import '../providers/weather_provider.dart';

/// ホーム画面の天気ウィジェット
class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(regionalWeatherProvider);

    return weatherAsync.when(
      loading: () => const _WeatherLoadingCard(),
      error: (err, _) => const _WeatherErrorCard(),
      data: (weather) => _WeatherDataCard(weather: weather),
    );
  }
}

/// 天気データ表示カード
class _WeatherDataCard extends StatelessWidget {
  final Weather weather;

  const _WeatherDataCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getWeatherGradient(weather.condition),
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 地域名と天気アイコン
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        weather.location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.conditionJa,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // 天気絵文字（大きく）
              Text(
                _getWeatherEmoji(weather.condition),
                style: const TextStyle(fontSize: 56),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 温度表示
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '体感 ${weather.feelsLike.toStringAsFixed(0)}°',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '湿度 ${weather.humidity}%',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '風速 ${weather.windSpeed.toStringAsFixed(1)}m/s',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 栽培アドバイス
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_florist,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weather.gardeningAdvice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getWeatherGradient(String condition) {
    switch (condition) {
      case 'Clear':
        return [const Color(0xFFFFB300), const Color(0xFFFF8F00)];
      case 'Rain':
      case 'Drizzle':
        return [const Color(0xFF42A5F5), const Color(0xFF1976D2)];
      case 'Thunderstorm':
        return [const Color(0xFF546E7A), const Color(0xFF37474F)];
      case 'Snow':
        return [const Color(0xFF90CAF9), const Color(0xFF64B5F6)];
      case 'Clouds':
        return [const Color(0xFF78909C), const Color(0xFF546E7A)];
      default:
        return [AppColors.primary, AppColors.primaryDark];
    }
  }

  String _getWeatherEmoji(String condition) {
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

/// ローディング表示
class _WeatherLoadingCard extends StatelessWidget {
  const _WeatherLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// エラー表示
class _WeatherErrorCard extends StatelessWidget {
  const _WeatherErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.grey[600]),
          const SizedBox(width: 12),
          const Text('天気情報を取得できませんでした'),
        ],
      ),
    );
  }
}
