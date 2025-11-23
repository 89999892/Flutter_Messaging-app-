import 'package:equatable/equatable.dart';
import '../../../domain/entities/call_session_entity.dart';

/// Video Call Events
abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();

  @override
  List<Object?> get props => [];
}

/// Initiate a new video call
class InitiateVideoCall extends VideoCallEvent {
  final String calleeId;
  final String callerId;

  const InitiateVideoCall({
    required this.calleeId,
    required this.callerId,
  });

  @override
  List<Object?> get props => [calleeId, callerId];
}

/// Answer an incoming video call
class AnswerVideoCall extends VideoCallEvent {
  final String callId;

  const AnswerVideoCall(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// Reject an incoming video call
class RejectVideoCall extends VideoCallEvent {
  final String callId;

  const RejectVideoCall(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// End the current video call
class EndVideoCall extends VideoCallEvent {
  final String callId;

  const EndVideoCall(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// Toggle microphone mute
class ToggleMicrophone extends VideoCallEvent {
  const ToggleMicrophone();
}

/// Toggle camera on/off
class ToggleCamera extends VideoCallEvent {
  const ToggleCamera();
}

/// Switch between front and back camera
class SwitchCamera extends VideoCallEvent {
  const SwitchCamera();
}

/// ICE candidate received from remote peer
class IceCandidateReceived extends VideoCallEvent {
  final String callId;
  final IceCandidateEntity candidate;

  const IceCandidateReceived({
    required this.callId,
    required this.candidate,
  });

  @override
  List<Object?> get props => [callId, candidate];
}

/// Call status updated (from real-time subscription)
class CallStatusUpdated extends VideoCallEvent {
  final String callId;
  final String status;

  const CallStatusUpdated({
    required this.callId,
    required this.status,
  });

  @override
  List<Object?> get props => [callId, status];
}

/// Watch for incoming calls
class WatchIncomingCalls extends VideoCallEvent {
  final String userId;

  const WatchIncomingCalls(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Stop watching for calls
class StopWatchingCalls extends VideoCallEvent {
  const StopWatchingCalls();
}
