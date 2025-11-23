import '../../domain/entities/call_entity.dart';

/// Call Model
/// Data transfer object for Call
/// Extends CallEntity and adds JSON serialization
class CallModel extends CallEntity {
  const CallModel({
    required super.id,
    required super.callerId,
    required super.calleeId,
    required super.status,
    required super.createdAt,
    super.startedAt,
    super.endedAt,
  });

  /// Create CallModel from JSON (Supabase response)
  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] as String,
      callerId: json['caller_id'] as String,
      calleeId: json['callee_id'] as String,
      status: _statusFromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
    );
  }

  /// Convert CallModel to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caller_id': callerId,
      'callee_id': calleeId,
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }

  /// Convert CallEntity to CallModel
  factory CallModel.fromEntity(CallEntity entity) {
    return CallModel(
      id: entity.id,
      callerId: entity.callerId,
      calleeId: entity.calleeId,
      status: entity.status,
      createdAt: entity.createdAt,
      startedAt: entity.startedAt,
      endedAt: entity.endedAt,
    );
  }

  /// Convert status enum to string
  static String _statusToString(CallStatus status) {
    switch (status) {
      case CallStatus.ringing:
        return 'ringing';
      case CallStatus.active:
        return 'active';
      case CallStatus.ended:
        return 'ended';
      case CallStatus.rejected:
        return 'rejected';
    }
  }

  /// Convert string to status enum
  static CallStatus _statusFromString(String status) {
    switch (status) {
      case 'ringing':
        return CallStatus.ringing;
      case 'active':
        return CallStatus.active;
      case 'ended':
        return CallStatus.ended;
      case 'rejected':
        return CallStatus.rejected;
      default:
        throw ArgumentError('Unknown call status: $status');
    }
  }
}
