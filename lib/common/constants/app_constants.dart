/// Firebase collection names
class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // Storage paths
  static const String userPhotosPath = 'users';
  static const String chatMediaPath = 'chats';
}

/// App-wide constants
class AppConstants {
  static const String appName = 'Messaging App';
  static const int messagePageSize = 50;
  static const int chatListPageSize = 20;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration typingIndicatorDuration = Duration(seconds: 3);
}

/// Route constants
class RouteConstants {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String chatList = '/chats';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
}
