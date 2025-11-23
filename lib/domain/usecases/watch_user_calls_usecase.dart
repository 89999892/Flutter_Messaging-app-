import '../entities/call_entity.dart';
import '../repositories/video_call_repository.dart';

/// Watch User Calls Use Case
/// Business logic for observing incoming and outgoing calls for a user
class WatchUserCallsUseCase {
  final VideoCallRepository _repository;

  WatchUserCallsUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [userId]: ID of the user to watch calls for
  ///
  /// Returns: Stream of calls where user is caller or callee
  Stream<List<CallEntity>> execute(String userId) {
    // Validation
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    // Watch user's calls
    return _repository.watchUserCalls(userId);
  }
}
