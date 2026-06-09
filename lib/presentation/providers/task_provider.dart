import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(
  TasksNotifier.new,
);

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() async {
    return ref.read(taskRepositoryProvider).getTasks();
  }

  Future<void> addTask(String title, DateTime dueDate, String category) async {
    await ref.read(taskRepositoryProvider).addTask(title, dueDate, category);
    ref.invalidateSelf();
  }

  Future<void> toggleTask(String id) async {
    await ref.read(taskRepositoryProvider).toggleTask(id);
    ref.invalidateSelf();
  }

  Future<void> deleteTask(String id) async {
    await ref.read(taskRepositoryProvider).deleteTask(id);
    ref.invalidateSelf();
  }
}
