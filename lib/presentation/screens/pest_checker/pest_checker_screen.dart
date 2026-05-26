import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/pest_diagnosis.dart';
import '../../providers/pest_checker_provider.dart';

/// 病害虫チェッカー画面
/// ワイヤーフレーム：病害虫の説明・対処法・対策・予防の3タブ
class PestCheckerScreen extends ConsumerWidget {
  const PestCheckerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pestCheckerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.pestCheckerTitle,
          style: AppTextStyles.headlineSmall,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: state.hasResults
          ? _DiagnosisResultView(diagnosis: state.topResult!)
          : _ImageCaptureView(),
    );
  }
}

/// 画像撮影・選択ビュー（診断前）
class _ImageCaptureView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pestCheckerProvider);
    final notifier = ref.read(pestCheckerProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ヘッダー説明文
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.camera_alt,
                    color: AppColors.primaryDark,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '植物の写真を撮ってください',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '病気や病害虫が疑われる葉・茎・実の部分を撮影するとより正確に診断できます',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 画像プレビューエリア
            if (state.selectedImage != null && !state.isAnalyzing)
              Container(
                height: 240,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: FileImage(state.selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // 診断中インジケーター
            if (state.isAnalyzing) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.pestCheckerAnalyzing,
                      style: AppTextStyles.bodyLarge,
                    ),
                    Text(
                      'AIが画像を解析しています...',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            // エラーメッセージ
            if (state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style:
                            AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // カメラ撮影ボタン
            _ActionButton(
              icon: Icons.camera_alt,
              label: AppStrings.pestCheckerCamera,
              color: AppColors.primary,
              onTap: state.isAnalyzing
                  ? null
                  : () => _pickImage(
                        context,
                        ref,
                        ImageSource.camera,
                      ),
            ),
            const SizedBox(height: 12),
            // アルバム選択ボタン
            _ActionButton(
              icon: Icons.photo_library,
              label: AppStrings.pestCheckerGallery,
              color: AppColors.secondary,
              onTap: state.isAnalyzing
                  ? null
                  : () => _pickImage(
                        context,
                        ref,
                        ImageSource.gallery,
                      ),
            ),
            const SizedBox(height: 32),
            // 病害虫情報セクション（ワイヤーフレームの3ボタン）
            _PestInfoButtons(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        await ref
            .read(pestCheckerProvider.notifier)
            .diagnoseImage(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errorPermissionCamera)),
        );
      }
    }
  }
}

/// 病害虫情報の3ボタン（ワイヤーフレーム準拠）
class _PestInfoButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pestCheckerProvider);
    final notifier = ref.read(pestCheckerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '病害虫について学ぶ',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: 12),
        // 病害虫の説明
        _InfoButton(
          label: AppStrings.pestCheckerDescription,
          isSelected: state.activeTab == PestCheckerTab.description,
          onTap: () => notifier.switchTab(PestCheckerTab.description),
        ),
        const SizedBox(height: 10),
        // 対処法
        _InfoButton(
          label: AppStrings.pestCheckerTreatment,
          isSelected: state.activeTab == PestCheckerTab.treatment,
          onTap: () => notifier.switchTab(PestCheckerTab.treatment),
        ),
        const SizedBox(height: 10),
        // 対策・予防
        _InfoButton(
          label: AppStrings.pestCheckerPrevention,
          isSelected: state.activeTab == PestCheckerTab.prevention,
          onTap: () => notifier.switchTab(PestCheckerTab.prevention),
        ),
        const SizedBox(height: 16),
        // 選択されたタブのコンテンツ
        _PestInfoContent(tab: state.activeTab),
      ],
    );
  }
}

/// 情報ボタン（ワイヤーフレームの大きめ角丸ボタン）
class _InfoButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InfoButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: AppTextStyles.headlineSmall.copyWith(
            color: isSelected ? AppColors.primaryDark : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// タブコンテンツ表示
class _PestInfoContent extends StatelessWidget {
  final PestCheckerTab tab;

  const _PestInfoContent({required this.tab});

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case PestCheckerTab.description:
        return _buildDescription();
      case PestCheckerTab.treatment:
        return _buildTreatment();
      case PestCheckerTab.prevention:
        return _buildPrevention();
    }
  }

  Widget _buildDescription() {
    return _InfoCard(
      title: '主な病害虫の種類',
      items: const [
        _InfoItem(
          emoji: '🐛',
          title: 'アブラムシ',
          description: '葉や茎に集団で寄生し、植物の汁を吸います。ウイルス病を媒介することもあります。',
        ),
        _InfoItem(
          emoji: '🕷️',
          title: 'ハダニ',
          description: '高温乾燥時に発生しやすい。葉に細かい斑点ができ、枯れることがあります。',
        ),
        _InfoItem(
          emoji: '🦋',
          title: 'コナジラミ',
          description: '白い小さな虫。葉の裏に寄生し、ウイルス病を媒介します。',
        ),
        _InfoItem(
          emoji: '🍄',
          title: 'うどんこ病',
          description: '白い粉状のカビが葉に広がります。風通しが悪い環境で発生しやすいです。',
        ),
        _InfoItem(
          emoji: '💧',
          title: '疫病',
          description: '梅雨時期に多発する病気。葉や茎に水浸状の斑点が現れ急速に進展します。',
        ),
      ],
    );
  }

  Widget _buildTreatment() {
    return _InfoCard(
      title: '対処法',
      items: const [
        _InfoItem(
          emoji: '💊',
          title: '殺虫・殺菌剤の使用',
          description: '症状に合った薬剤を選び、用法・用量を守って散布します。早期発見・早期対処が重要です。',
        ),
        _InfoItem(
          emoji: '✂️',
          title: '患部の除去',
          description: '発病・被害を受けた葉や茎を早期に除去します。除去した部位はゴミとして処分してください。',
        ),
        _InfoItem(
          emoji: '🚿',
          title: '水による洗浄',
          description: 'アブラムシ等には強めの水流で洗い流すことが有効です。葉の裏も忘れずに。',
        ),
        _InfoItem(
          emoji: '🌿',
          title: '天敵の活用',
          description: 'テントウムシやハチなどの益虫を呼び込むことでアブラムシを自然防除できます。',
        ),
      ],
    );
  }

  Widget _buildPrevention() {
    return _InfoCard(
      title: '対策・予防',
      items: const [
        _InfoItem(
          emoji: '🌬️',
          title: '風通しを良くする',
          description: '株間を適切に保ち、密植を避けます。剪定で中の空気が流れるようにしましょう。',
        ),
        _InfoItem(
          emoji: '💧',
          title: '適切な水管理',
          description: '過湿を避け、葉に水がかからないよう株元に水やりします。夕方の水やりは病気の原因に。',
        ),
        _InfoItem(
          emoji: '🌱',
          title: '土壌管理',
          description: 'バランスの良い施肥で植物を健康に保ちます。連作障害に注意しましょう。',
        ),
        _InfoItem(
          emoji: '🔍',
          title: '定期的な観察',
          description: '毎日観察することで早期発見が可能です。特に葉の裏や茎の付け根を確認しましょう。',
        ),
        _InfoItem(
          emoji: '🛡️',
          title: '防虫ネットの使用',
          description: '防虫ネットで物理的に害虫の侵入を防ぎます。特に苗の時期は効果的です。',
        ),
      ],
    );
  }
}

/// 情報カードウィジェット
class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          ...items.map((item) => _buildItem(item)),
        ],
      ),
    );
  }

  Widget _buildItem(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(item.description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String emoji;
  final String title;
  final String description;

  const _InfoItem({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

/// アクションボタン（カメラ・アルバム）
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTextStyles.button,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 診断結果表示ビュー
class _DiagnosisResultView extends ConsumerWidget {
  final PestDiagnosis diagnosis;

  const _DiagnosisResultView({required this.diagnosis});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pestCheckerProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          // 画像プレビュー
          if (state.selectedImage != null)
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(state.selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 診断結果ヘッダー
                _ResultHeader(diagnosis: diagnosis),
                const SizedBox(height: 16),
                // 対処法セクション
                if (diagnosis.treatments.isNotEmpty) ...[
                  Text(
                    AppStrings.pestCheckerTreatment,
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  ...diagnosis.treatments.map(
                    (t) => _TreatmentCard(treatment: t),
                  ),
                  const SizedBox(height: 16),
                ],
                // 予防セクション
                if (diagnosis.preventionTips.isNotEmpty) ...[
                  Text(
                    AppStrings.pestCheckerPrevention,
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: diagnosis.preventionTips
                          .map(
                            (tip) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('✅ ',
                                      style: TextStyle(fontSize: 14)),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // 再診断ボタン
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(pestCheckerProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('もう一度診断する'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 診断結果ヘッダー
class _ResultHeader extends StatelessWidget {
  final PestDiagnosis diagnosis;

  const _ResultHeader({required this.diagnosis});

  Color get _severityColor {
    switch (diagnosis.severity) {
      case SeverityLevel.none:
        return AppColors.pestSafe;
      case SeverityLevel.mild:
        return AppColors.pestWarning;
      case SeverityLevel.moderate:
        return AppColors.pestWarning;
      case SeverityLevel.severe:
        return AppColors.pestDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                diagnosis.severity == SeverityLevel.none
                    ? Icons.check_circle
                    : Icons.warning_amber_rounded,
                color: _severityColor,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnosis.pestName,
                      style: AppTextStyles.headlineMedium,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _severityColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            diagnosis.severity.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '信頼度: ${diagnosis.confidencePercent}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (diagnosis.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              diagnosis.description,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// 対処法カード
class _TreatmentCard extends StatelessWidget {
  final PestTreatment treatment;

  const _TreatmentCard({required this.treatment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(treatment.title, style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          ...treatment.steps.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
