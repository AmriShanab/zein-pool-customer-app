import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final _fullDate = DateFormat('EEE, d MMM yyyy');
  static final _shortDate = DateFormat('d MMM yyyy');
  static final _time12h = DateFormat('h:mm a');
  static final _dateWithTime = DateFormat('d MMM yyyy, h:mm a');
  static final _isoDate = DateFormat('yyyy-MM-dd');

  static String toIsoDate(DateTime date) => _isoDate.format(date);

  static String formatFullDate(DateTime date) =>
      _fullDate.format(date.toLocal());

  static String formatShortDate(DateTime date) =>
      _shortDate.format(date.toLocal());

  static String formatTime(DateTime date) => _time12h.format(date.toLocal());

  static String formatDateTime(DateTime date) =>
      _dateWithTime.format(date.toLocal());

  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} – ${formatTime(end)}';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '$hours hr${hours > 1 ? 's' : ''}';
    return '$minutes mins';
  }
}
