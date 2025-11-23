import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_model.dart';

/// Chat model representing a conversation
class ChatModel extends Equatable {
  final String id;
  final List<String> participantIds;
  final MessageModel? lastMessage;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.unreadCount = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create ChatModel from Firestore document
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map? ?? {}),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert ChatModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Get unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  /// Get the other participant ID (for one-on-one chats)
  String? getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Create a copy with updated fields
  ChatModel copyWith({
    String? id,
    List<String>? participantIds,
    MessageModel? lastMessage,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participantIds,
        lastMessage,
        unreadCount,
        createdAt,
        updatedAt,
      ];
}
