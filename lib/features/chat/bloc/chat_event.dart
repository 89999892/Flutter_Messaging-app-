import 'package:equatable/equatable.dart';
import '../../../common/models/message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserChats extends ChatEvent {
  final String userId;
  const LoadUserChats(this.userId);
  @override
  List<Object?> get props => [userId];
}

class LoadChatMessages extends ChatEvent {
  final String chatId;
  const LoadChatMessages(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

class SendMessage extends ChatEvent {
  final MessageModel message;
  const SendMessage(this.message);
  @override
  List<Object?> get props => [message];
}

class CreateChat extends ChatEvent {
  final List<String> participantIds;
  const CreateChat(this.participantIds);
  @override
  List<Object?> get props => [participantIds];
}

class UpdateChatStream extends ChatEvent {
  final List<dynamic> data;
  const UpdateChatStream(this.data);
  @override
  List<Object?> get props => [data];
}
