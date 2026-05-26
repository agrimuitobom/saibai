import 'package:intl/intl.dart';

/// 日付・時刻のフォーマットユーティリティ
class DateFormatter {
  DateFormatter._();

  /// 日本語の日付表示（例: 2024年5月15日）
  static String toJapaneseDate(DateTime date) {
    return DateFormat('yyyy年M月d日', 'ja').format(date);
  }

  /// 日本語の曜日付き日付（例: 2024年5月15日（水））
  static String toJapaneseDateWithWeekday(DateTime date) {
    return DateFormat('yyyy年M月d日(E)', 'ja').format(date);
  }

  /// 短い日付表示（例: 5/15）
  static String toShortDate(DateTime date) {
    return DateFormat('M/d', 'ja').format(date);
  }

  /// 時刻表示（例: 14:30）
  static String toTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// 相対時間表示（例: 3分前、2時間前）
  static String toRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分前';
    if (diff.inHours < 24) return '${diff.inHours}時間前';
    if (diff.inDays < 7) return '${diff.inDays}日前';
    return toJapaneseDate(date);
  }

  /// タスク期限表示（例: 今日、明日、5月20日）
  static String toTaskDeadline(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff < 0) return '期限切れ';
    if (diff == 0) return '今日';
    if (diff == 1) return '明日';
    if (diff < 7) return '${diff}日後';
    return DateFormat('M月d日', 'ja').format(date);
  }
}
