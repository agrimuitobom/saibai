import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'crop_provider.dart';
import 'task_provider.dart';

/// サンプルのタスクと作物を追加して、関係する画面を更新する。
Future<void> addSampleData(WidgetRef ref) async {
  await ref.read(taskRepositoryProvider).addSampleData();
  ref.invalidate(tasksProvider);
  ref.invalidate(growingCropsProvider);
}

/// タスクと育てている作物をすべて消して、関係する画面を更新する。
Future<void> clearAllData(WidgetRef ref) async {
  await ref.read(taskRepositoryProvider).clearAll();
  ref.invalidate(tasksProvider);
  ref.invalidate(growingCropsProvider);
}
