import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_theme.dart';
import '../../../injection_container.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_event.dart';
import '../../authentication/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_screen.dart';
import 'user_search_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user ID from AuthBloc
    // Get current user ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    final String? currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: User not found')),
      );
    }

    return BlocProvider(
      create: (context) => sl<ChatBloc>()..add(LoadUserChats(currentUserId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Search functionality (local filter)
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatLoaded) {
              if (state.chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No chats yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _navigateToUserSearch(context),
                        child: const Text('Start a Conversation'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: state.chats.length,
                itemBuilder: (context, index) {
                  final chat = state.chats[index];
                  // Determine the other participant's name (basic logic)
                  // In a real app, we'd look up the user details or store them in the chat model
                  // For now, let's assume the chat name is set or we use a placeholder
                  final chatName = 'Chat'; // Placeholder
                  final lastMessage =
                      chat.lastMessage?.content ?? 'No messages';
                  final time = DateFormat.jm().format(chat.updatedAt);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        chatName.isNotEmpty ? chatName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      chatName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (chat.getUnreadCount(currentUserId) > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chat.getUnreadCount(currentUserId)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chat.id,
                            chatName: chatName,
                            otherUserId: chat.participantIds
                                .firstWhere((id) => id != currentUserId),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (state is ChatError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToUserSearch(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _navigateToUserSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserSearchScreen()),
    );
  }
}
