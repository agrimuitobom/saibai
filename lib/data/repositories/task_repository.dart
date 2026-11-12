import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/crop_model.dart';

class TaskRepository {
  static const String _tasksKey = 'tasks';
  static const String _growingCropsKey = 'growing_crops';
  final _uuid = const Uuid();

  Future<List<TaskModel>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_tasksKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addTask(String title, DateTime dueDate, String category) async {
    final tasks = await getTasks();
    final newTask = TaskModel(
      id: _uuid.v4(),
      title: title,
      dueDate: dueDate,
      category: category,
      createdAt: DateTime.now(),
    );
    tasks.add(newTask);
    await _saveTasks(tasks);
  }

  Future<void> toggleTask(String id) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(isCompleted: !tasks[index].isCompleted);
      await _saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _saveTasks(tasks);
  }

  /// 初めて開いた人が画面の様子をつかめるよう、作物とタスクの例を追加する。
  Future<void> addSampleData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime day(int offset) => today.add(Duration(days: offset));

    final crops = await getGrowingCrops();
    crops.addAll([
      GrowingCropModel(
          id: _uuid.v4(),
          name: 'ミニトマト',
          plantingDate: day(-40),
          notes: 'ベランダのプランター。わき芽かきを忘れずに'),
      GrowingCropModel(
          id: _uuid.v4(),
          name: '小松菜',
          plantingDate: day(-14),
          notes: '間引きながら収穫'),
      GrowingCropModel(
          id: _uuid.v4(), name: 'バジル', plantingDate: day(-25)),
    ]);
    await _saveGrowingCrops(crops);

    final tasks = await getTasks();
    TaskModel task(String title, int offset, String category,
            {bool done = false}) =>
        TaskModel(
          id: _uuid.v4(),
          title: title,
          dueDate: day(offset),
          category: category,
          isCompleted: done,
          createdAt: now,
        );
    tasks.addAll([
      task('ミニトマトの水やり', 0, '水やり'),
      task('小松菜の間引き', 0, 'その他'),
      task('バジルの摘心', 0, '剪定'),
      task('ミニトマトに追肥', 1, '施肥'),
      task('葉の裏の害虫チェック', 2, '病害虫対策'),
      task('小松菜の収穫', 5, '収穫'),
      task('バジルの水やり', -1, '水やり', done: true),
    ]);
    await _saveTasks(tasks);
  }

  /// タスクと育てている作物をすべて消す。
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
    await prefs.remove(_growingCropsKey);
  }

  Future<void> _saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  Future<List<GrowingCropModel>> getGrowingCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_growingCropsKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((e) => GrowingCropModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addGrowingCrop(String name, DateTime plantingDate, {String? notes}) async {
    final crops = await getGrowingCrops();
    final newCrop = GrowingCropModel(
      id: _uuid.v4(),
      name: name,
      plantingDate: plantingDate,
      notes: notes,
    );
    crops.add(newCrop);
    await _saveGrowingCrops(crops);
  }

  Future<void> deleteGrowingCrop(String id) async {
    final crops = await getGrowingCrops();
    crops.removeWhere((c) => c.id == id);
    await _saveGrowingCrops(crops);
  }

  Future<void> _saveGrowingCrops(List<GrowingCropModel> crops) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_growingCropsKey, jsonEncode(crops.map((c) => c.toJson()).toList()));
  }
}
