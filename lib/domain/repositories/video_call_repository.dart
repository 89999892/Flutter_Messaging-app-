import '../entities/call_entity.dart';
import '../entities/call_session_entity.dart';

/// Video Call Repository Interface
/// Defines the contract for video call operations
/// Implementations will use Supabase for signaling
abstract class VideoCallRepository {
  /// Initiate a new video call
  /// Returns the call ID
  Future<String> initiateCall({
    required String callerId,
    required String calleeId,
    required SdpEntity sdpOffer,
  });

  /// Answer an incoming call
  Future<void> answerCall({
    required String callId,
    required SdpEntity sdpAnswer,
  });

  /// Reject an incoming call
  Future<void> rejectCall(String callId);

  /// End an active call
  Future<void> endCall(String callId);

  /// Get call details by ID
  Future<CallEntity> getCall(String callId);

  /// Watch a call for real-time updates
  /// Returns a stream that emits call updates
  Stream<CallEntity> watchCall(String callId);

  /// Watch calls for a specific user (as caller or callee)
  /// Useful for detecting incoming calls
  Stream<List<CallEntity>> watchUserCalls(String userId);

  /// Send an ICE candidate for connection establishment
  Future<void> sendIceCandidate({
    required String callId,
    required String userId,
    required IceCandidateEntity candidate,
  });

  /// Watch ICE candidates for a call
  /// Returns a stream of new ICE candidates
  Stream<List<IceCandidateEntity>> watchIceCandidates(String callId);

  /// Get call session data (SDP offer/answer and ICE candidates)
  Future<CallSessionEntity> getCallSession(String callId);
}
