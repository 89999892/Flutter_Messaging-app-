import 'package:equatable/equatable.dart';

/// ICE Candidate Entity
/// Represents a WebRTC ICE (Interactive Connectivity Establishment) candidate
/// Used for NAT traversal and establishing peer-to-peer connections
class IceCandidateEntity extends Equatable {
  final String id;
  final String callId;
  final String userId;
  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;
  final DateTime createdAt;

  const IceCandidateEntity({
    required this.id,
    required this.callId,
    required this.userId,
    required this.candidate,
    this.sdpMid,
    this.sdpMLineIndex,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        callId,
        userId,
        candidate,
        sdpMid,
        sdpMLineIndex,
        createdAt,
      ];
}

/// SDP (Session Description Protocol) Entity
/// Contains offer/answer for WebRTC connection negotiation
class SdpEntity extends Equatable {
  final String type; // 'offer' or 'answer'
  final String sdp;

  const SdpEntity({
    required this.type,
    required this.sdp,
  });

  bool get isOffer => type == 'offer';
  bool get isAnswer => type == 'answer';

  @override
  List<Object?> get props => [type, sdp];
}

/// Call Session Entity
/// Contains WebRTC session data for a call
class CallSessionEntity extends Equatable {
  final String callId;
  final SdpEntity? offer;
  final SdpEntity? answer;
  final List<IceCandidateEntity> iceCandidates;

  const CallSessionEntity({
    required this.callId,
    this.offer,
    this.answer,
    this.iceCandidates = const [],
  });

  /// Check if session has both offer and answer
  bool get isNegotiated => offer != null && answer != null;

  /// Create a copy with updated fields
  CallSessionEntity copyWith({
    String? callId,
    SdpEntity? offer,
    SdpEntity? answer,
    List<IceCandidateEntity>? iceCandidates,
  }) {
    return CallSessionEntity(
      callId: callId ?? this.callId,
      offer: offer ?? this.offer,
      answer: answer ?? this.answer,
      iceCandidates: iceCandidates ?? this.iceCandidates,
    );
  }

  @override
  List<Object?> get props => [callId, offer, answer, iceCandidates];
}
