import 'package:equatable/equatable.dart';

/// Call Status Enum
/// Represents the current state of a video call
enum CallStatus {
  ringing, // Call initiated, waiting for answer
  active, // Call in progress
  ended, // Call completed normally
  rejected, // Call rejected by callee
}

/// Call Entity
/// Pure business object representing a video call
/// This is independent of any data source (Firebase, Supabase, etc.)
class CallEntity extends Equatable {
  final String id;
  final String callerId;
  final String calleeId;
  final CallStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const CallEntity({
    required this.id,
    required this.callerId,
    required this.calleeId,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  /// Create a copy with updated fields
  CallEntity copyWith({
    String? id,
    String? callerId,
    String? calleeId,
    CallStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return CallEntity(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      calleeId: calleeId ?? this.calleeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  /// Check if call is active
  bool get isActive => status == CallStatus.active;

  /// Check if call is ringing
  bool get isRinging => status == CallStatus.ringing;

  /// Check if call has ended
  bool get hasEnded =>
      status == CallStatus.ended || status == CallStatus.rejected;

  /// Get call duration (if call has started)
  Duration? get duration {
    if (startedAt == null) return null;
    final endTime = endedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  @override
  List<Object?> get props => [
        id,
        callerId,
        calleeId,
        status,
        createdAt,
        startedAt,
        endedAt,
      ];
}
