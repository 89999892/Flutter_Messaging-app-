import '../repositories/video_call_repository.dart';

/// End Call Use Case
/// Business logic for ending an active video call
class EndCallUseCase {
  final VideoCallRepository _repository;

  EndCallUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [callId]: ID of the call to end
  ///
  /// Throws: Exception if call doesn't exist
  Future<void> execute(String callId) async {
    // Validation
    if (callId.isEmpty) {
      throw ArgumentError('Call ID cannot be empty');
    }

    // End the call
    await _repository.endCall(callId);
  }
}
