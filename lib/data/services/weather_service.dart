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

class WeatherService {
  Future<WeatherData> fetchWeather() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const WeatherData(
      condition: '晴れ',
      temperature: 24,
      humidity: 55,
      icon: '☀️',
      location: '東京',
    );
  }
}
