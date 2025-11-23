import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<LoadUserChats>(_onLoadUserChats);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessage>(_onSendMessage);
    on<CreateChat>(_onCreateChat);
  }

  Future<void> _onLoadUserChats(
    LoadUserChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await emit.forEach(
      _chatRepository.getUserChats(event.userId),
      onData: (chats) => ChatLoaded(chats),
      onError: (error, stackTrace) => ChatError(error.toString()),
    );
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await emit.forEach(
      _chatRepository.getChatMessages(event.chatId),
      onData: (messages) => ChatMessagesLoaded(messages, event.chatId),
      onError: (error, stackTrace) => ChatError(error.toString()),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print(
          'Sending message: ${event.message.content} to ${event.message.chatId}');
      await _chatRepository.sendMessage(event.message);
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onCreateChat(
    CreateChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('Creating chat for: ${event.participantIds}');
      final chatId =
          await _chatRepository.getOrCreateChat(event.participantIds);
      print('Chat created/found: $chatId');
      emit(ChatOperationSuccess('Chat created successfully', chatId: chatId));
    } catch (e) {
      print('Error creating chat: $e');
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
