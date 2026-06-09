import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/crop_model.dart';
import '../../data/repositories/crop_repository.dart';
import '../../data/repositories/task_repository.dart';

final cropRepositoryProvider = Provider<CropRepository>((ref) => CropRepository());

final allCropsProvider = Provider<List<CropModel>>((ref) {
  return ref.read(cropRepositoryProvider).getAllCrops();
});

final cropSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredCropsProvider = Provider<List<CropModel>>((ref) {
  final query = ref.watch(cropSearchQueryProvider);
  return ref.read(cropRepositoryProvider).searchCrops(query);
});

final cropDetailProvider = Provider.family<CropModel?, String>((ref, id) {
  return ref.read(cropRepositoryProvider).getCropById(id);
});

// Growing crops
final growingCropsProvider =
    AsyncNotifierProvider<GrowingCropsNotifier, List<GrowingCropModel>>(
  GrowingCropsNotifier.new,
);

class GrowingCropsNotifier extends AsyncNotifier<List<GrowingCropModel>> {
  @override
  Future<List<GrowingCropModel>> build() async {
    return ref.read(taskRepositoryProvider).getGrowingCrops();
  }

  Future<void> addCrop(String name, DateTime plantingDate, {String? notes}) async {
    await ref.read(taskRepositoryProvider).addGrowingCrop(name, plantingDate, notes: notes);
    ref.invalidateSelf();
  }

  Future<void> deleteCrop(String id) async {
    await ref.read(taskRepositoryProvider).deleteGrowingCrop(id);
    ref.invalidateSelf();
  }
}
