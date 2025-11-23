import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../common/models/message_model.dart';
import '../../../common/theme/app_theme.dart';
import '../../../injection_container.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context, String currentUserId) {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
      chatId: widget.chatId,
      senderId: currentUserId,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    context.read<ChatBloc>().add(SendMessage(message));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final String? currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text('Error: User not found')));
    }

    return BlocProvider(
      create: (context) => sl<ChatBloc>()..add(LoadChatMessages(widget.chatId)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.chatName.isNotEmpty
                          ? widget.chatName[0].toUpperCase()
                          : '?',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.chatName),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ChatMessagesLoaded) {
                        final messages = state.messages;

                        if (messages.isEmpty) {
                          return const Center(child: Text('Say hello! 👋'));
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Show newest at bottom
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId == currentUserId;

                            return _buildMessageBubble(message, isMe, context);
                          },
                        );
                      } else if (state is ChatError) {
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                _buildMessageInput(context, currentUserId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(
      MessageModel message, bool isMe, BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.jm().format(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, String currentUserId) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              color: AppColors.primary,
              onPressed: () {
                // Attachments (to be implemented)
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 19, 17, 17),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _sendMessage(context, currentUserId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
