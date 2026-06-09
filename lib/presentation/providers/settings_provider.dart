import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool notificationsEnabled;
  final bool isPublic;
  final String cultivationPlace;
  final String cultivationRegion;

  const AppSettings({
    this.notificationsEnabled = true,
    this.isPublic = true,
    this.cultivationPlace = 'ベランダ',
    this.cultivationRegion = '東日本',
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? isPublic,
    String? cultivationPlace,
    String? cultivationRegion,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isPublic: isPublic ?? this.isPublic,
      cultivationPlace: cultivationPlace ?? this.cultivationPlace,
      cultivationRegion: cultivationRegion ?? this.cultivationRegion,
    );
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const String _notifKey = 'notifications_enabled';
  static const String _publicKey = 'is_public';
  static const String _placeKey = 'cultivation_place';
  static const String _regionKey = 'cultivation_region';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      notificationsEnabled: prefs.getBool(_notifKey) ?? true,
      isPublic: prefs.getBool(_publicKey) ?? true,
      cultivationPlace: prefs.getString(_placeKey) ?? 'ベランダ',
      cultivationRegion: prefs.getString(_regionKey) ?? '東日本',
    );
  }

  Future<void> toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(notificationsEnabled: value));
  }

  Future<void> togglePublic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_publicKey, value);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(isPublic: value));
  }

  Future<void> setCultivationPlace(String place) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_placeKey, place);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(cultivationPlace: place));
  }

  Future<void> setCultivationRegion(String region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, region);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(cultivationRegion: region));
  }
}
