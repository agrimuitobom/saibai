import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/crop_model.dart';
import '../../providers/crop_provider.dart';
import '../../widgets/common/app_card.dart';

class GrowingCropsScreen extends ConsumerStatefulWidget {
  const GrowingCropsScreen({super.key});

  @override
  ConsumerState<GrowingCropsScreen> createState() =>
      _GrowingCropsScreenState();
}

class _GrowingCropsScreenState extends ConsumerState<GrowingCropsScreen> {
  final _nameController = TextEditingController();
  DateTime _plantingDate = DateTime.now();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('ja'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _plantingDate = picked);
  }

  Future<void> _addCrop() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(growingCropsProvider.notifier).addCrop(
          _nameController.text.trim(),
          _plantingDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
    _nameController.clear();
    _notesController.clear();
    setState(() => _plantingDate = DateTime.now());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.cropAdded)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(growingCropsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.growingCropsScreen),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('作物を追加する', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 16),

                    Text(AppStrings.cropItem,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: AppStrings.cropNameHint,
                        prefixIcon:
                            Icon(Icons.eco_outlined, color: AppColors.primary),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return '作物名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    Text(AppStrings.plantingDate,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('yyyy年M月d日', 'ja')
                                  .format(_plantingDate),
                              style: AppTextStyles.bodyMedium,
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('メモ（任意）',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'メモを入力（任意）',
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addCrop,
                        icon: const Icon(Icons.add),
                        label: const Text(AppStrings.addCrop),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(AppStrings.growingCropsScreen,
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),

            cropsAsync.when(
              data: (crops) {
                if (crops.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          const Text('🌱', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text(
                            '育てている作物を追加しましょう！',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: crops
                      .map((crop) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _GrowingCropTile(crop: crop),
                          ))
                      .toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(AppStrings.error,
                  style: AppTextStyles.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowingCropTile extends ConsumerWidget {
  final GrowingCropModel crop;

  const _GrowingCropTile({required this.crop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysSince =
        DateTime.now().difference(crop.plantingDate).inDays;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🌿', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop.name, style: AppTextStyles.titleLarge),
                const SizedBox(height: 2),
                Text(
                  '植え付け：${DateFormat('yyyy年M月d日', 'ja').format(crop.plantingDate)}',
                  style: AppTextStyles.bodySmall,
                ),
                if (daysSince >= 0)
                  Text(
                    '$daysSince日目',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (crop.notes != null && crop.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      crop.notes!,
                      style: AppTextStyles.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 20),
            onPressed: () {
              ref.read(growingCropsProvider.notifier).deleteCrop(crop.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.cropDeleted)),
              );
            },
          ),
        ],
      ),
    );
  }
}
