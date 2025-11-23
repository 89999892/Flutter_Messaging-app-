import '../../domain/entities/call_session_entity.dart';

/// ICE Candidate Model
/// Data transfer object for ICE Candidate
class IceCandidateModel extends IceCandidateEntity {
  const IceCandidateModel({
    required super.id,
    required super.callId,
    required super.userId,
    required super.candidate,
    super.sdpMid,
    super.sdpMLineIndex,
    required super.createdAt,
  });

  /// Create from JSON (Supabase response)
  factory IceCandidateModel.fromJson(Map<String, dynamic> json) {
    final candidateData = json['candidate'] as Map<String, dynamic>;

    return IceCandidateModel(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      userId: json['user_id'] as String,
      candidate: candidateData['candidate'] as String,
      sdpMid: candidateData['sdpMid'] as String?,
      sdpMLineIndex: candidateData['sdpMLineIndex'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'call_id': callId,
      'user_id': userId,
      'candidate': {
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
      },
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert from entity
  factory IceCandidateModel.fromEntity(IceCandidateEntity entity) {
    return IceCandidateModel(
      id: entity.id,
      callId: entity.callId,
      userId: entity.userId,
      candidate: entity.candidate,
      sdpMid: entity.sdpMid,
      sdpMLineIndex: entity.sdpMLineIndex,
      createdAt: entity.createdAt,
    );
  }
}

/// SDP Model
/// Data transfer object for SDP
class SdpModel extends SdpEntity {
  const SdpModel({
    required super.type,
    required super.sdp,
  });

  /// Create from JSON
  factory SdpModel.fromJson(Map<String, dynamic> json) {
    return SdpModel(
      type: json['type'] as String,
      sdp: json['sdp'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sdp': sdp,
    };
  }

  /// Convert from entity
  factory SdpModel.fromEntity(SdpEntity entity) {
    return SdpModel(
      type: entity.type,
      sdp: entity.sdp,
    );
  }
}
