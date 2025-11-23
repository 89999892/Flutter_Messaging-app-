import '../entities/call_session_entity.dart';
import '../repositories/video_call_repository.dart';

/// Send ICE Candidate Use Case
/// Business logic for sending WebRTC ICE candidates during call setup
class SendIceCandidateUseCase {
  final VideoCallRepository _repository;

  SendIceCandidateUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [callId]: ID of the call
  /// - [userId]: ID of the user sending the candidate
  /// - [candidate]: ICE candidate to send
  ///
  /// Throws: Exception if sending fails
  Future<void> execute({
    required String callId,
    required String userId,
    required IceCandidateEntity candidate,
  }) async {
    // Validation
    if (callId.isEmpty) {
      throw ArgumentError('Call ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    // Send the ICE candidate
    await _repository.sendIceCandidate(
      callId: callId,
      userId: userId,
      candidate: candidate,
    );
  }
}
