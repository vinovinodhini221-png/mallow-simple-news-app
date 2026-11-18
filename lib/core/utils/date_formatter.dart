class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Formats date to 'MMM d, yyyy', e.g., 'Feb 27, 2023'.
  static String format(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

    final localDate = date.toLocal();
    final month = _months[localDate.month - 1];
    final day = localDate.day;
    final year = localDate.year;

    return '$month $day, $year';
  }

  /// Formats date to relative string (e.g. '6 hours ago') or falls back to 'MMM d, yyyy'.
  static String formatRelative(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

    final now = DateTime.now();
    final difference = now.difference(date.toLocal());

    if (difference.isNegative || difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return format(date);
    }
  }
}
