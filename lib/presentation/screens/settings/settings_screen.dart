import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appSettings),
        backgroundColor: AppColors.primary,
      ),
      body: settingsAsync.when(
        data: (settings) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification & Public settings
                SectionHeader(title: '基本設定'),
                const SizedBox(height: 10),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ToggleTile(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.primary,
                        title: AppStrings.notifications,
                        subtitle: '水やりや収穫のお知らせを受け取る',
                        value: settings.notificationsEnabled,
                        onChanged: (v) => ref
                            .read(settingsProvider.notifier)
                            .toggleNotifications(v),
                      ),
                      const Divider(height: 1, indent: 56),
                      _ToggleTile(
                        icon: Icons.public_outlined,
                        iconColor: AppColors.accent,
                        title: AppStrings.publicSettings,
                        subtitle: 'ブログを一般公開する',
                        value: settings.isPublic,
                        onChanged: (v) => ref
                            .read(settingsProvider.notifier)
                            .togglePublic(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cultivation place
                SectionHeader(title: AppStrings.cultivationPlace),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '栽培している場所を選択してください',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          AppStrings.balcony,
                          AppStrings.fieldGarden,
                          AppStrings.indoor,
                        ].map((place) {
                          final isSelected =
                              settings.cultivationPlace == place;
                          return GestureDetector(
                            onTap: () => ref
                                .read(settingsProvider.notifier)
                                .setCultivationPlace(place),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(Icons.check,
                                          color: Colors.white, size: 16),
                                    ),
                                  Text(
                                    place,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cultivation region
                SectionHeader(title: AppStrings.cultivationRegion),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '栽培している地域を選択してください',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          AppStrings.eastJapan,
                          AppStrings.westJapan,
                          AppStrings.chubu,
                          AppStrings.kyushu,
                        ].map((region) {
                          final isSelected =
                              settings.cultivationRegion == region;
                          return GestureDetector(
                            onTap: () => ref
                                .read(settingsProvider.notifier)
                                .setCultivationRegion(region),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(Icons.check,
                                          color: Colors.white, size: 16),
                                    ),
                                  Text(
                                    region,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // App info
                SectionHeader(title: 'アプリ情報'),
                const SizedBox(height: 10),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _InfoTile(
                          icon: Icons.info_outline,
                          title: 'バージョン',
                          value: '1.0.0'),
                      const Divider(height: 1, indent: 56),
                      _InfoTile(
                          icon: Icons.eco_outlined,
                          title: 'アプリ名',
                          value: AppStrings.appName),
                      const Divider(height: 1, indent: 56),
                      _InfoTile(
                          icon: Icons.copyright_outlined,
                          title: '© 2026 VegeGro',
                          value: ''),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(AppStrings.error, style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: AppTextStyles.titleMedium),
          const Spacer(),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
