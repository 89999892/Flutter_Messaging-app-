import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/call_model.dart';
import '../../models/call_session_model.dart';
import 'supabase_client_provider.dart';

/// Supabase Video Call Datasource
/// Handles all Supabase operations for video calling
class SupabaseVideoCallDatasource {
  final SupabaseClient _client;
  final Uuid _uuid = const Uuid();

  SupabaseVideoCallDatasource([SupabaseClient? client])
      : _client = client ?? SupabaseClientProvider.instance;

  // Table names
  static const String _callsTable = 'calls';
  static const String _iceCandidatesTable = 'ice_candidates';

  /// Create a new call
  Future<String> createCall({
    required String callerId,
    required String calleeId,
    required SdpModel sdpOffer,
  }) async {
    final callId = _uuid.v4();

    await _client.from(_callsTable).insert({
      'id': callId,
      'caller_id': callerId,
      'callee_id': calleeId,
      'status': 'ringing',
      'sdp_offer': sdpOffer.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    });

    return callId;
  }

  /// Update call with SDP answer
  Future<void> updateCallWithAnswer({
    required String callId,
    required SdpModel sdpAnswer,
  }) async {
    await _client.from(_callsTable).update({
      'sdp_answer': sdpAnswer.toJson(),
      'status': 'active',
      'started_at': DateTime.now().toIso8601String(),
    }).eq('id', callId);
  }

  /// Update call status
  Future<void> updateCallStatus({
    required String callId,
    required String status,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
    };

    if (status == 'ended' || status == 'rejected') {
      updates['ended_at'] = DateTime.now().toIso8601String();
    }

    await _client.from(_callsTable).update(updates).eq('id', callId);
  }

  /// Get call by ID
  Future<CallModel> getCall(String callId) async {
    final response =
        await _client.from(_callsTable).select().eq('id', callId).single();

    return CallModel.fromJson(response);
  }

  /// Watch call for real-time updates
  Stream<CallModel> watchCall(String callId) {
    return _client
        .from(_callsTable)
        .stream(primaryKey: ['id'])
        .eq('id', callId)
        .map((data) => CallModel.fromJson(data.first));
  }

  /// Watch calls for a user (incoming and outgoing)
  Stream<List<CallModel>> watchUserCalls(String userId) {
    return _client
        .from(_callsTable)
        .stream(primaryKey: ['id'])
        .inFilter('caller_id', [userId])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => CallModel.fromJson(json)).toList());
  }

  /// Insert ICE candidate
  Future<void> insertIceCandidate({
    required String callId,
    required String userId,
    required IceCandidateModel candidate,
  }) async {
    await _client.from(_iceCandidatesTable).insert({
      'id': _uuid.v4(),
      'call_id': callId,
      'user_id': userId,
      'candidate': {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      },
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Watch ICE candidates for a call
  Stream<List<IceCandidateModel>> watchIceCandidates(String callId) {
    return _client
        .from(_iceCandidatesTable)
        .stream(primaryKey: ['id'])
        .eq('call_id', callId)
        .order('created_at', ascending: true)
        .map((data) =>
            data.map((json) => IceCandidateModel.fromJson(json)).toList());
  }

  /// Get SDP offer for a call
  Future<SdpModel?> getSdpOffer(String callId) async {
    final response = await _client
        .from(_callsTable)
        .select('sdp_offer')
        .eq('id', callId)
        .single();

    final sdpOfferJson = response['sdp_offer'];
    if (sdpOfferJson == null) return null;

    return SdpModel.fromJson(sdpOfferJson as Map<String, dynamic>);
  }

  /// Get SDP answer for a call
  Future<SdpModel?> getSdpAnswer(String callId) async {
    final response = await _client
        .from(_callsTable)
        .select('sdp_answer')
        .eq('id', callId)
        .single();

    final sdpAnswerJson = response['sdp_answer'];
    if (sdpAnswerJson == null) return null;

    return SdpModel.fromJson(sdpAnswerJson as Map<String, dynamic>);
  }
}
