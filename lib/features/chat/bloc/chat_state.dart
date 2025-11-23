import 'package:equatable/equatable.dart';
import '../../../common/models/chat_model.dart';
import '../../../common/models/message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatModel> chats;
  const ChatLoaded(this.chats);
  @override
  List<Object?> get props => [chats];
}

class ChatMessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  final String chatId;
  const ChatMessagesLoaded(this.messages, this.chatId);
  @override
  List<Object?> get props => [messages, chatId];
}

class ChatOperationSuccess extends ChatState {
  final String message;
  final String? chatId; // Optional, useful when a new chat is created
  const ChatOperationSuccess(this.message, {this.chatId});
  @override
  List<Object?> get props => [message, chatId];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
