import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';

const _uuid = Uuid();

/// タスクリストの状態管理
class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super(_sampleTasks);

  /// タスクを追加
  void addTask({
    required String title,
    String? description,
    required DateTime dueDate,
    required TaskCategory category,
    String? relatedCropId,
  }) {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      category: category,
      relatedCropId: relatedCropId,
      createdAt: DateTime.now(),
    );
    state = [...state, task];
  }

  /// タスクの完了状態をトグル
  void toggleComplete(String taskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
  }

  /// タスクを削除
  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  /// タスクを更新
  void updateTask(Task updated) {
    state = state.map((task) {
      return task.id == updated.id ? updated : task;
    }).toList();
  }
}

/// タスクプロバイダー
final taskProvider =
    StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

/// 未完了タスクのみ
final pendingTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((t) => !t.isCompleted).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});

/// 本日のタスク
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final today = DateTime.now();
  return tasks.where((t) {
    final due = t.dueDate;
    return !t.isCompleted &&
        due.year == today.year &&
        due.month == today.month &&
        due.day == today.day;
  }).toList();
});

/// サンプルデータ
final _sampleTasks = [
  Task(
    id: '1',
    title: 'トマトに水やり',
    dueDate: DateTime.now(),
    category: TaskCategory.watering,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Task(
    id: '2',
    title: 'バジルの追肥',
    dueDate: DateTime.now().add(const Duration(days: 2)),
    category: TaskCategory.fertilizing,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Task(
    id: '3',
    title: 'キュウリの収穫',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    category: TaskCategory.harvesting,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];
