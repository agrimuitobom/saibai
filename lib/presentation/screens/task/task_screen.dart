import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/task.dart';
import '../../providers/task_provider.dart';

/// タスク画面
/// ワイヤーフレーム：何をするか・いつするか・カテゴリー・追加ボタン
class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTasks = ref.watch(pendingTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.taskTitle,
          style: AppTextStyles.headlineSmall,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // タスク追加フォーム
          _AddTaskForm(),
          const Divider(),
          // タスク一覧
          Expanded(
            child: pendingTasks.isEmpty
                ? _EmptyTaskView()
                : _TaskList(tasks: pendingTasks),
          ),
        ],
      ),
    );
  }
}

/// タスク追加フォーム（ワイヤーフレーム準拠）
class _AddTaskForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends ConsumerState<_AddTaskForm> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TaskCategory _selectedCategory = TaskCategory.watering;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 何をするか（ワイヤーフレーム準拠）
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: AppStrings.taskWhatToDo,
              labelText: AppStrings.taskWhatToDo,
              prefixIcon:
                  const Icon(Icons.edit, color: AppColors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // いつするか（ワイヤーフレーム準拠）
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surface,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18,
                            color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormatter.toJapaneseDate(_selectedDate),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // カテゴリー（ワイヤーフレーム準拠）
              Expanded(
                child: _CategoryDropdown(
                  value: _selectedCategory,
                  onChanged: (cat) {
                    if (cat != null) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 追加ボタン（ワイヤーフレームの「追加ボタン」）
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                AppStrings.taskAddButton,
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ja'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タスク名を入力してください')),
      );
      return;
    }

    ref.read(taskProvider.notifier).addTask(
          title: _titleController.text.trim(),
          dueDate: _selectedDate,
          category: _selectedCategory,
        );

    _titleController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategory = TaskCategory.watering;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('タスクを追加しました')),
    );
  }
}

/// カテゴリードロップダウン
class _CategoryDropdown extends StatelessWidget {
  final TaskCategory value;
  final ValueChanged<TaskCategory?> onChanged;

  const _CategoryDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TaskCategory>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: AppStrings.taskCategory,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      items: TaskCategory.values
          .map(
            (cat) => DropdownMenuItem(
              value: cat,
              child: Text('${cat.emoji} ${cat.label}'),
            ),
          )
          .toList(),
    );
  }
}

/// タスクリスト
class _TaskList extends ConsumerWidget {
  final List<Task> tasks;

  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TaskListItem(task: task);
      },
    );
  }
}

/// タスクリストアイテム
class _TaskListItem extends ConsumerWidget {
  final Task task;

  const _TaskListItem({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(taskProvider.notifier).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('タスクを削除しました')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? AppColors.surfaceVariant
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: task.isCompleted
                ? AppColors.divider
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            // チェックボックス
            GestureDetector(
              onTap: () =>
                  ref.read(taskProvider.notifier).toggleComplete(task.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.primary
                        : AppColors.cardBorder,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check,
                        color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // カテゴリー絵文字
            Text(
              task.category.emoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 10),
            // タスク詳細
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormatter.toTaskDeadline(task.dueDate),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _getDeadlineColor(task.dueDate),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.category.label,
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDeadlineColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;

    if (diff < 0) return AppColors.error;
    if (diff == 0) return AppColors.warning;
    return AppColors.onSurfaceVariant;
  }
}

/// 空状態
class _EmptyTaskView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.task_alt,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('タスクがありません', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          Text('上のフォームからタスクを追加しましょう',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
