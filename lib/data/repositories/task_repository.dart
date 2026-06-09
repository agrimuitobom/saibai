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
