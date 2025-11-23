import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../common/models/chat_model.dart';
import '../../common/models/message_model.dart';
import '../../common/models/user_model.dart';

/// Firebase Firestore Provider
/// Handles direct interaction with Firestore database
class FirebaseFirestoreProvider {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  FirebaseFirestoreProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== User Operations ====================

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUser(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  // ==================== Chat Operations ====================

  /// Get user chats
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  /// Create new chat
  Future<String> createChat(List<String> participantIds) async {
    try {
      final chatId = _uuid.v4();
      final now = DateTime.now();

      // Sort participant IDs to ensure consistency
      final sortedIds = List<String>.from(participantIds)..sort();

      final chat = ChatModel(
        id: chatId,
        participantIds: sortedIds,
        unreadCount: {for (var id in sortedIds) id: 0},
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('chats').doc(chatId).set(chat.toJson());
      return chatId;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  /// Get chat by ID
  Future<ChatModel?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) return null;
      return ChatModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  /// Find existing chat between users
  Future<String?> findChatBetweenUsers(List<String> userIds) async {
    try {
      // Sort IDs to match how we create them
      final sortedIds = List<String>.from(userIds)..sort();

      final snapshot = await _firestore
          .collection('chats')
          .where('participantIds', isEqualTo: sortedIds)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.id;
    } catch (e) {
      return null;
    }
  }

  // ==================== Message Operations ====================

  /// Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  /// Send message
  Future<void> sendMessage(MessageModel message) async {
    try {
      final batch = _firestore.batch();

      // Add message to subcollection
      final messageRef = _firestore
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .doc(message.id);

      batch.set(messageRef, message.toJson());

      // Update chat's last message and timestamp
      final chatRef = _firestore.collection('chats').doc(message.chatId);

      // Get current chat to update unread counts
      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        throw Exception('Chat document ${message.chatId} not found');
      }

      final chat = ChatModel.fromJson({...chatDoc.data()!, 'id': chatDoc.id});

      // Increment unread count for all participants except sender
      final updatedUnreadCount = Map<String, int>.from(chat.unreadCount);
      for (var participantId in chat.participantIds) {
        if (participantId != message.senderId) {
          updatedUnreadCount[participantId] =
              (updatedUnreadCount[participantId] ?? 0) + 1;
        }
      }

      batch.update(chatRef, {
        'lastMessage': message.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount': updatedUnreadCount,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(
      String chatId, String messageId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Update message readBy array
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      batch.update(messageRef, {
        'readBy': FieldValue.arrayUnion([userId]),
      });

      // Reset unread count for this user
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'unreadCount.$userId': 0,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  /// Mark all messages in chat as read
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      throw Exception('Failed to mark chat as read: $e');
    }
  }
}
