import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ設定の状態
class AppSettings {
  final bool notificationsEnabled;
  final bool isPublicProfile;
  final String growingLocation;
  final String growingRegion;

  const AppSettings({
    this.notificationsEnabled = true,
    this.isPublicProfile = true,
    this.growingLocation = 'ベランダ',
    this.growingRegion = '東日本',
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? isPublicProfile,
    String? growingLocation,
    String? growingRegion,
  }) {
    return AppSettings(
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      isPublicProfile: isPublicProfile ?? this.isPublicProfile,
      growingLocation: growingLocation ?? this.growingLocation,
      growingRegion: growingRegion ?? this.growingRegion,
    );
  }
}

/// 設定の状態管理
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  Future<void> toggleNotifications() async {
    state = state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
    );
    await _save();
  }

  Future<void> togglePublicProfile() async {
    state = state.copyWith(
      isPublicProfile: !state.isPublicProfile,
    );
    await _save();
  }

  Future<void> setGrowingLocation(String location) async {
    state = state.copyWith(growingLocation: location);
    await _save();
  }

  Future<void> setGrowingRegion(String region) async {
    state = state.copyWith(growingRegion: region);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', state.notificationsEnabled);
    await prefs.setBool('public_profile', state.isPublicProfile);
    await prefs.setString('growing_location', state.growingLocation);
    await prefs.setString('growing_region', state.growingRegion);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      notificationsEnabled: prefs.getBool('notifications') ?? true,
      isPublicProfile: prefs.getBool('public_profile') ?? true,
      growingLocation: prefs.getString('growing_location') ?? 'ベランダ',
      growingRegion: prefs.getString('growing_region') ?? '東日本',
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final notifier = SettingsNotifier();
  notifier.load();
  return notifier;
});
