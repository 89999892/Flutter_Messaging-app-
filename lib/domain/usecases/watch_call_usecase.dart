import '../entities/call_entity.dart';
import '../repositories/video_call_repository.dart';

/// Watch Call Use Case
/// Business logic for observing real-time call updates
class WatchCallUseCase {
  final VideoCallRepository _repository;

  WatchCallUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [callId]: ID of the call to watch
  ///
  /// Returns: Stream of call updates
  Stream<CallEntity> execute(String callId) {
    // Validation
    if (callId.isEmpty) {
      throw ArgumentError('Call ID cannot be empty');
    }

    // Watch the call
    return _repository.watchCall(callId);
  }
}
