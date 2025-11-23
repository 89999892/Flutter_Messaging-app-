import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Message type enumeration
enum MessageType {
  text,
  image,
  video,
  file,
}

/// Message model representing a chat message
class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final List<String> readBy;
  final String? mediaUrl;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.readBy = const [],
    this.mediaUrl,
  });

  /// Create MessageModel from Firestore document
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      readBy: List<String>.from(json['readBy'] as List? ?? []),
      mediaUrl: json['mediaUrl'] as String?,
    );
  }

  /// Convert MessageModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
      'mediaUrl': mediaUrl,
    };
  }

  /// Check if message is read by a specific user
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  /// Create a copy with updated fields
  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    List<String>? readBy,
    String? mediaUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        content,
        type,
        timestamp,
        readBy,
        mediaUrl,
      ];
}
