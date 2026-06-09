import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/app_card.dart';

final _selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final _focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(_selectedDayProvider);
    final focusedDay = ref.watch(_focusedDayProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.calendar),
        backgroundColor: AppColors.primary,
      ),
      body: tasksAsync.when(
        data: (tasks) {
          Map<DateTime, List<TaskModel>> eventMap = {};
          for (final task in tasks) {
            final key = DateTime(
                task.dueDate.year, task.dueDate.month, task.dueDate.day);
            eventMap.putIfAbsent(key, () => []).add(task);
          }

          List<TaskModel> getEvents(DateTime day) {
            final key = DateTime(day.year, day.month, day.day);
            return eventMap[key] ?? [];
          }

          final selectedTasks = getEvents(selectedDay);

          return Column(
            children: [
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.only(bottom: 8),
                child: TableCalendar<TaskModel>(
                  locale: 'ja',
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2027, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                  eventLoader: getEvents,
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle:
                        const TextStyle(color: Colors.white70),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle:
                        const TextStyle(color: AppColors.primary),
                    todayDecoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(color: Colors.white),
                    outsideTextStyle:
                        const TextStyle(color: Colors.white38),
                    markerDecoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    markerSize: 5,
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        TextStyle(color: Colors.white, fontSize: 16),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle:
                        TextStyle(color: Colors.white70, fontSize: 12),
                    weekendStyle:
                        TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  onDaySelected: (selected, focused) {
                    ref.read(_selectedDayProvider.notifier).state = selected;
                    ref.read(_focusedDayProvider.notifier).state = focused;
                  },
                  onPageChanged: (focused) {
                    ref.read(_focusedDayProvider.notifier).state = focused;
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_note,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('M月d日（E）', 'ja').format(selectedDay),
                            style: AppTextStyles.headlineSmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'のタスク',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: selectedTasks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.event_available,
                                        size: 48,
                                        color: AppColors.primary),
                                    const SizedBox(height: 8),
                                    Text(
                                      'この日のタスクはありません',
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(
                                              color:
                                                  AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: selectedTasks.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final task = selectedTasks[i];
                                  return AppCard(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          task.isCompleted
                                              ? Icons.check_circle
                                              : Icons
                                                  .radio_button_unchecked,
                                          color: task.isCompleted
                                              ? AppColors.success
                                              : AppColors.primary,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            task.title,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              decoration: task.isCompleted
                                                  ? TextDecoration
                                                      .lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            task.category,
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                                    color:
                                                        AppColors.primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(AppStrings.error, style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}
