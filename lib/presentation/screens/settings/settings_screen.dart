import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/settings_provider.dart';
import '../../providers/weather_provider.dart';

/// アプリ設定画面
/// ワイヤーフレーム：通知・公開設定・栽培場所・栽培地域
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.settingsTitle,
          style: AppTextStyles.headlineSmall,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // 通知設定（ワイヤーフレーム準拠）
            _SettingsCard(
              children: [
                _ToggleSetting(
                  title: AppStrings.settingsNotification,
                  subtitle: '水やりや収穫のタイミングをお知らせします',
                  icon: Icons.notifications,
                  value: settings.notificationsEnabled,
                  onChanged: (_) => notifier.toggleNotifications(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 公開設定（ワイヤーフレーム準拠）
            _SettingsCard(
              children: [
                _ToggleSetting(
                  title: AppStrings.settingsPublicSetting,
                  subtitle: settings.isPublicProfile
                      ? 'プロフィールを公開中'
                      : 'プロフィールを非公開中',
                  icon: Icons.visibility,
                  value: settings.isPublicProfile,
                  onChanged: (_) => notifier.togglePublicProfile(),
                  trueLabel: AppStrings.settingsPublic,
                  falseLabel: AppStrings.settingsPrivate,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 栽培場所（ワイヤーフレーム準拠：ベランダ・畑・庭・室内）
            _SettingsCard(
              title: AppStrings.settingsGrowingPlace,
              children: [
                _MultiSelectSetting(
                  options: const [
                    AppStrings.settingsBalcony,
                    AppStrings.settingsField,
                    AppStrings.settingsIndoor,
                  ],
                  selectedOption: settings.growingLocation,
                  onSelected: notifier.setGrowingLocation,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 栽培地域（ワイヤーフレーム準拠：東日本・その他）
            _SettingsCard(
              title: AppStrings.settingsGrowingRegion,
              children: [
                _MultiSelectSetting(
                  options: const [
                    AppStrings.settingsEastJapan,
                    AppStrings.settingsWestJapan,
                    AppStrings.settingsCentralJapan,
                    AppStrings.settingsKyushu,
                  ],
                  selectedOption: settings.growingRegion,
                  onSelected: (region) async {
                    await notifier.setGrowingRegion(region);
                    // 地域変更時に天気情報を再取得
                    ref.read(selectedRegionProvider.notifier).state = region;
                    ref.invalidate(regionalWeatherProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            // アプリ情報
            _AppInfo(),
          ],
        ),
      ),
    );
  }
}

/// 設定カードコンテナ
class _SettingsCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SettingsCard({
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(title!, style: AppTextStyles.headlineSmall),
            ),
          ...children,
        ],
      ),
    );
  }
}

/// トグル設定アイテム（ワイヤーフレームのオン/オフ）
class _ToggleSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? trueLabel;
  final String? falseLabel;

  const _ToggleSetting({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.trueLabel,
    this.falseLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // アイコン
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          // タイトルとサブタイトル
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          // トグルスイッチ（ワイヤーフレームのオン/オフ）
          if (trueLabel != null && falseLabel != null)
            _ToggleWithLabel(
              value: value,
              trueLabel: trueLabel!,
              falseLabel: falseLabel!,
              onChanged: onChanged,
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
        ],
      ),
    );
  }
}

/// ラベル付きトグル（公開/非公開）
class _ToggleWithLabel extends StatelessWidget {
  final bool value;
  final String trueLabel;
  final String falseLabel;
  final ValueChanged<bool> onChanged;

  const _ToggleWithLabel({
    required this.value,
    required this.trueLabel,
    required this.falseLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value ? trueLabel : falseLabel,
          style: AppTextStyles.labelMedium.copyWith(
            color: value ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

/// 複数選択設定（ワイヤーフレームのタグ選択）
class _MultiSelectSetting extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final void Function(String) onSelected;

  const _MultiSelectSetting({
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.map((option) {
          final isSelected = option == selectedOption;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardBorder,
                ),
              ),
              child: Text(
                option,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.onSurface,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// アプリ情報
class _AppInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.eco, size: 32, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            'GreenThumb',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '家庭菜園をもっと楽しく',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
