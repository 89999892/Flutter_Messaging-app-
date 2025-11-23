import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../domain/entities/call_entity.dart';

/// Video Call States
abstract class VideoCallState extends Equatable {
  const VideoCallState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no active call
class VideoCallInitial extends VideoCallState {
  const VideoCallInitial();
}

/// Watching for incoming calls
class VideoCallWatching extends VideoCallState {
  final String userId;

  const VideoCallWatching(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Initiating a call (creating offer)
class VideoCallInitiating extends VideoCallState {
  final String calleeId;

  const VideoCallInitiating(this.calleeId);

  @override
  List<Object?> get props => [calleeId];
}

/// Call is ringing (waiting for answer)
class VideoCallRinging extends VideoCallState {
  final CallEntity call;
  final bool isOutgoing;

  const VideoCallRinging({
    required this.call,
    required this.isOutgoing,
  });

  @override
  List<Object?> get props => [call, isOutgoing];
}

/// Call is active (connected)
class VideoCallActive extends VideoCallState {
  final CallEntity call;
  final RTCVideoRenderer? localRenderer;
  final RTCVideoRenderer? remoteRenderer;
  final bool isMuted;
  final bool isCameraOff;

  const VideoCallActive({
    required this.call,
    this.localRenderer,
    this.remoteRenderer,
    this.isMuted = false,
    this.isCameraOff = false,
  });

  @override
  List<Object?> get props => [
        call,
        localRenderer,
        remoteRenderer,
        isMuted,
        isCameraOff,
      ];

  VideoCallActive copyWith({
    CallEntity? call,
    RTCVideoRenderer? localRenderer,
    RTCVideoRenderer? remoteRenderer,
    bool? isMuted,
    bool? isCameraOff,
  }) {
    return VideoCallActive(
      call: call ?? this.call,
      localRenderer: localRenderer ?? this.localRenderer,
      remoteRenderer: remoteRenderer ?? this.remoteRenderer,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
    );
  }
}

/// Call ended
class VideoCallEnded extends VideoCallState {
  final String reason;

  const VideoCallEnded(this.reason);

  @override
  List<Object?> get props => [reason];
}

/// Call rejected
class VideoCallRejected extends VideoCallState {
  final String callId;

  const VideoCallRejected(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// Error occurred
class VideoCallError extends VideoCallState {
  final String message;

  const VideoCallError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Incoming call notification
class VideoCallIncoming extends VideoCallState {
  final CallEntity call;

  const VideoCallIncoming(this.call);

  @override
  List<Object?> get props => [call];
}
