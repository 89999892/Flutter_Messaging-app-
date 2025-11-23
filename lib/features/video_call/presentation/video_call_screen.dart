import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../bloc/video_call_bloc.dart';
import '../bloc/video_call_event.dart';
import '../bloc/video_call_state.dart';

/// Video Call Screen
/// Displays active video call with local and remote video
class VideoCallScreen extends StatelessWidget {
  final String callId;
  final bool isOutgoing;

  const VideoCallScreen({
    super.key,
    required this.callId,
    required this.isOutgoing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<VideoCallBloc, VideoCallState>(
        listener: (context, state) {
          if (state is VideoCallEnded) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.reason)),
            );
          } else if (state is VideoCallError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VideoCallActive) {
            return _buildActiveCall(context, state);
          } else if (state is VideoCallRinging) {
            return _buildRingingCall(context, state);
          } else if (state is VideoCallInitiating) {
            return _buildInitiating(context);
          }

          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildActiveCall(BuildContext context, VideoCallActive state) {
    return Stack(
      children: [
        // Remote video (full screen)
        if (state.remoteRenderer != null)
          Positioned.fill(
            child: RTCVideoView(
              state.remoteRenderer!,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          )
        else
          const Center(
            child: Text(
              'Connecting...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

        // Local video (small preview)
        if (state.localRenderer != null)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RTCVideoView(
                  state.localRenderer!,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),

        // Call controls
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: _buildCallControls(context, state),
        ),

        // Call duration
        Positioned(
          top: 50,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatDuration(state.call.duration),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRingingCall(BuildContext context, VideoCallRinging state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_in_talk, size: 80, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            state.isOutgoing ? 'Calling...' : 'Incoming Call',
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 48),
          if (state.isOutgoing)
            ElevatedButton.icon(
              onPressed: () {
                context.read<VideoCallBloc>().add(EndVideoCall(state.call.id));
              },
              icon: const Icon(Icons.call_end),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitiating(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 24),
          Text(
            'Initiating call...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(BuildContext context, VideoCallActive state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute/Unmute
        _buildControlButton(
          icon: state.isMuted ? Icons.mic_off : Icons.mic,
          label: state.isMuted ? 'Unmute' : 'Mute',
          onPressed: () {
            context.read<VideoCallBloc>().add(const ToggleMicrophone());
          },
          backgroundColor: state.isMuted ? Colors.red : Colors.white24,
        ),

        // Camera On/Off
        _buildControlButton(
          icon: state.isCameraOff ? Icons.videocam_off : Icons.videocam,
          label: state.isCameraOff ? 'Camera Off' : 'Camera On',
          onPressed: () {
            context.read<VideoCallBloc>().add(const ToggleCamera());
          },
          backgroundColor: state.isCameraOff ? Colors.red : Colors.white24,
        ),

        // Switch Camera
        _buildControlButton(
          icon: Icons.cameraswitch,
          label: 'Switch',
          onPressed: () {
            context.read<VideoCallBloc>().add(const SwitchCamera());
          },
          backgroundColor: Colors.white24,
        ),

        // End Call
        _buildControlButton(
          icon: Icons.call_end,
          label: 'End',
          onPressed: () {
            context.read<VideoCallBloc>().add(EndVideoCall(state.call.id));
          },
          backgroundColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
