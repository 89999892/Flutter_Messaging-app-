import 'package:intl/intl.dart';

/// Date and time formatting utilities
class DateFormatter {
  /// Format timestamp for message display (e.g., "10:30 AM" or "Yesterday")
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(dateTime);
    } else {
      // Older - show date
      return DateFormat('MMM d').format(dateTime);
    }
  }

  /// Format timestamp for chat list (e.g., "10:30 AM", "Yesterday", "12/25")
  static String formatChatListTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 365) {
      // This year - show month and day
      return DateFormat('MMM d').format(dateTime);
    } else {
      // Older - show full date
      return DateFormat('M/d/yy').format(dateTime);
    }
  }

  /// Format full date and time (e.g., "December 25, 2024 at 10:30 AM")
  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat('MMMM d, y \'at\' h:mm a').format(dateTime);
  }

  /// Format last seen time (e.g., "Last seen 5 minutes ago")
  static String formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) {
      return 'Last seen recently';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return 'Last seen ${formatChatListTime(lastSeen)}';
    }
  }
}
