import 'package:equatable/equatable.dart';

/// タスクカテゴリー
enum TaskCategory {
  watering,
  fertilizing,
  harvesting,
  planting,
  pestControl,
  pruning,
  other,
}

extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.watering:
        return '水やり';
      case TaskCategory.fertilizing:
        return '施肥';
      case TaskCategory.harvesting:
        return '収穫';
      case TaskCategory.planting:
        return '植え付け';
      case TaskCategory.pestControl:
        return '病害虫対策';
      case TaskCategory.pruning:
        return '剪定・摘芯';
      case TaskCategory.other:
        return 'その他';
    }
  }

  String get emoji {
    switch (this) {
      case TaskCategory.watering:
        return '💧';
      case TaskCategory.fertilizing:
        return '🌱';
      case TaskCategory.harvesting:
        return '🌾';
      case TaskCategory.planting:
        return '🌿';
      case TaskCategory.pestControl:
        return '🐛';
      case TaskCategory.pruning:
        return '✂️';
      case TaskCategory.other:
        return '📝';
    }
  }
}

/// タスクエンティティ
class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskCategory category;
  final bool isCompleted;
  final String? relatedCropId;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.category,
    this.isCompleted = false,
    this.relatedCropId,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskCategory? category,
    bool? isCompleted,
    String? relatedCropId,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      relatedCropId: relatedCropId ?? this.relatedCropId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, dueDate, isCompleted];
}
