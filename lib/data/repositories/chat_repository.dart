import '../../common/models/chat_model.dart';
import '../../common/models/message_model.dart';
import '../providers/firebase_firestore_provider.dart';
import 'package:uuid/uuid.dart';

/// Chat Repository
/// Abstracts chat and message operations
abstract class ChatRepository {
  Stream<List<ChatModel>> getUserChats(String userId);
  Stream<List<MessageModel>> getChatMessages(String chatId);
  Future<void> sendMessage(MessageModel message);
  Future<void> markAsRead(String chatId, String messageId, String userId);
  Future<String> createChat(List<String> participantIds);
  Future<String> getOrCreateChat(List<String> participantIds);
}

/// Implementation of ChatRepository
class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestoreProvider _firestoreProvider;
  final Uuid _uuid = const Uuid();

  ChatRepositoryImpl(this._firestoreProvider);

  @override
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestoreProvider.getUserChats(userId);
  }

  @override
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestoreProvider.getChatMessages(chatId);
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    await _firestoreProvider.sendMessage(message);
  }

  @override
  Future<void> markAsRead(
      String chatId, String messageId, String userId) async {
    await _firestoreProvider.markMessageAsRead(chatId, messageId, userId);
  }

  @override
  Future<String> createChat(List<String> participantIds) async {
    return await _firestoreProvider.createChat(participantIds);
  }

  @override
  Future<String> getOrCreateChat(List<String> participantIds) async {
    // Try to find existing chat
    final existingChatId =
        await _firestoreProvider.findChatBetweenUsers(participantIds);

    if (existingChatId != null) {
      return existingChatId;
    }

    // Create new chat if none exists
    return await createChat(participantIds);
  }

  /// Helper to create a message
  MessageModel createMessage({
    required String chatId,
    required String senderId,
    required String content,
    required MessageType type,
    String? mediaUrl,
  }) {
    return MessageModel(
      id: _uuid.v4(),
      chatId: chatId,
      senderId: senderId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      mediaUrl: mediaUrl,
    );
  }
}
