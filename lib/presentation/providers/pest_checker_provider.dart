import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/pest_detection_service.dart';
import '../../domain/entities/pest_diagnosis.dart';

/// 病害虫チェッカーの表示タブ
enum PestCheckerTab { description, treatment, prevention }

/// 病害虫チェッカーの診断状態
class PestCheckerState {
  final PestCheckerTab activeTab;
  final File? selectedImage;
  final bool isAnalyzing;
  final List<PestDiagnosis> results;
  final String? errorMessage;

  const PestCheckerState({
    this.activeTab = PestCheckerTab.description,
    this.selectedImage,
    this.isAnalyzing = false,
    this.results = const [],
    this.errorMessage,
  });

  PestCheckerState copyWith({
    PestCheckerTab? activeTab,
    File? selectedImage,
    bool? isAnalyzing,
    List<PestDiagnosis>? results,
    String? errorMessage,
  }) {
    return PestCheckerState(
      activeTab: activeTab ?? this.activeTab,
      selectedImage: selectedImage ?? this.selectedImage,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }

  bool get hasResults => results.isNotEmpty;
  PestDiagnosis? get topResult => results.isEmpty ? null : results.first;
}

/// 病害虫チェッカーの状態管理
class PestCheckerNotifier extends StateNotifier<PestCheckerState> {
  final PestDetectionService _service;

  PestCheckerNotifier(this._service) : super(const PestCheckerState());

  /// タブを切り替える
  void switchTab(PestCheckerTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  /// 画像を診断する
  Future<void> diagnoseImage(File imageFile) async {
    state = state.copyWith(
      selectedImage: imageFile,
      isAnalyzing: true,
      errorMessage: null,
    );

    try {
      final models = await _service.diagnoseFromFile(imageFile);
      final results = models.map((m) => m.toEntity()).toList();

      state = state.copyWith(
        isAnalyzing: false,
        results: results,
      );
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: '診断に失敗しました。再度お試しください。',
      );
    }
  }

  /// 診断結果をリセット
  void reset() {
    state = const PestCheckerState();
  }
}

/// 病害虫チェッカープロバイダー
final pestCheckerProvider =
    StateNotifierProvider<PestCheckerNotifier, PestCheckerState>((ref) {
  return PestCheckerNotifier(PestDetectionService());
});
