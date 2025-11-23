import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/models/user_model.dart';
import '../../../common/theme/app_theme.dart';
import '../../../injection_container.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final String? currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return UserModel.fromJson({...data, 'id': doc.id});
          }).where((user) {
            // Filter out current user
            if (user.id == currentUserId) return false;

            // Filter by search query
            if (_searchQuery.isEmpty) return true;
            return user.displayName.toLowerCase().contains(_searchQuery) ||
                user.email.toLowerCase().contains(_searchQuery);
          }).toList();

          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user.displayName),
                subtitle: Text(user.email),
                onTap: () => _startChat(context, currentUserId!, user),
              );
            },
          );
        },
      ),
    );
  }

  void _startChat(
      BuildContext context, String currentUserId, UserModel otherUser) {
    // We need to create a chat or get existing one
    // We'll use the ChatBloc to handle this

    // For simplicity, we'll use a BlocProvider here to create the chat
    // But since we want to navigate to ChatScreen, we can do it in two ways:
    // 1. Create chat via Bloc, wait for success, then navigate.
    // 2. Navigate to ChatScreen with a "pending" state or just pass IDs and let ChatScreen handle creation?
    // The ChatScreen expects a chatId. So we must get the ID first.

    // Let's show a loading dialog while we create/fetch the chat
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Use a temporary Bloc to create the chat
    final chatBloc = sl<ChatBloc>();
    chatBloc.add(CreateChat([currentUserId, otherUser.id]));

    // Listen to the stream for the result
    // This is a bit hacky for a one-off operation, but it works with our BLoC pattern
    late final StreamSubscription subscription;
    subscription = chatBloc.stream.listen((state) {
      if (state is ChatOperationSuccess && state.chatId != null) {
        subscription.cancel();
        chatBloc.close();
        Navigator.pop(context); // Close loading dialog

        // Navigate to chat screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: state.chatId!,
              chatName: otherUser.displayName,
              otherUserId: otherUser.id,
            ),
          ),
        );
      } else if (state is ChatError) {
        subscription.cancel();
        chatBloc.close();
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.message}')),
        );
      }
    });
  }
}
