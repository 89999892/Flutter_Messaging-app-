import '../repositories/video_call_repository.dart';

/// Reject Call Use Case
/// Business logic for rejecting an incoming video call
class RejectCallUseCase {
  final VideoCallRepository _repository;

  RejectCallUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [callId]: ID of the call to reject
  ///
  /// Throws: Exception if call doesn't exist
  Future<void> execute(String callId) async {
    // Validation
    if (callId.isEmpty) {
      throw ArgumentError('Call ID cannot be empty');
    }

    // Reject the call
    await _repository.rejectCall(callId);
  }
}
