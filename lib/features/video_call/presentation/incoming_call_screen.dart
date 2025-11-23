import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/call_entity.dart';
import '../bloc/video_call_bloc.dart';
import '../bloc/video_call_event.dart';

/// Incoming Call Screen
/// Shows incoming call notification with accept/reject buttons
class IncomingCallScreen extends StatelessWidget {
  final CallEntity call;
  final String callerName;

  const IncomingCallScreen({
    super.key,
    required this.call,
    this.callerName = 'Unknown',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60),

            // Caller info
            Column(
              children: [
                // Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade700,
                  ),
                  child: Center(
                    child: Text(
                      callerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Caller name
                Text(
                  callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Call type
                const Text(
                  'Incoming video call',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // Ringing animation
                const Icon(
                  Icons.phone_in_talk,
                  color: Colors.white,
                  size: 40,
                ),
              ],
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject button
                  _buildActionButton(
                    icon: Icons.call_end,
                    label: 'Decline',
                    color: Colors.red,
                    onPressed: () {
                      context
                          .read<VideoCallBloc>()
                          .add(RejectVideoCall(call.id));
                      Navigator.of(context).pop();
                    },
                  ),

                  // Accept button
                  _buildActionButton(
                    icon: Icons.videocam,
                    label: 'Accept',
                    color: Colors.green,
                    onPressed: () {
                      context
                          .read<VideoCallBloc>()
                          .add(AnswerVideoCall(call.id));
                      Navigator.of(context).pop();
                      // Navigate to video call screen
                      // Navigator.push(...);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 8,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
