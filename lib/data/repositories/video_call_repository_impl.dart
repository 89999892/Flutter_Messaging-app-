import '../../domain/entities/call_entity.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/repositories/video_call_repository.dart';
import '../datasources/supabase/supabase_video_call_datasource.dart';
import '../models/call_session_model.dart';

/// Video Call Repository Implementation
/// Implements the VideoCallRepository interface using Supabase
class VideoCallRepositoryImpl implements VideoCallRepository {
  final SupabaseVideoCallDatasource _datasource;

  VideoCallRepositoryImpl(this._datasource);

  @override
  Future<String> initiateCall({
    required String callerId,
    required String calleeId,
    required SdpEntity sdpOffer,
  }) async {
    final sdpModel = SdpModel.fromEntity(sdpOffer);
    return await _datasource.createCall(
      callerId: callerId,
      calleeId: calleeId,
      sdpOffer: sdpModel,
    );
  }

  @override
  Future<void> answerCall({
    required String callId,
    required SdpEntity sdpAnswer,
  }) async {
    final sdpModel = SdpModel.fromEntity(sdpAnswer);
    await _datasource.updateCallWithAnswer(
      callId: callId,
      sdpAnswer: sdpModel,
    );
  }

  @override
  Future<void> rejectCall(String callId) async {
    await _datasource.updateCallStatus(
      callId: callId,
      status: 'rejected',
    );
  }

  @override
  Future<void> endCall(String callId) async {
    await _datasource.updateCallStatus(
      callId: callId,
      status: 'ended',
    );
  }

  @override
  Future<CallEntity> getCall(String callId) async {
    return await _datasource.getCall(callId);
  }

  @override
  Stream<CallEntity> watchCall(String callId) {
    return _datasource.watchCall(callId);
  }

  @override
  Stream<List<CallEntity>> watchUserCalls(String userId) {
    return _datasource.watchUserCalls(userId);
  }

  @override
  Future<void> sendIceCandidate({
    required String callId,
    required String userId,
    required IceCandidateEntity candidate,
  }) async {
    final candidateModel = IceCandidateModel.fromEntity(candidate);
    await _datasource.insertIceCandidate(
      callId: callId,
      userId: userId,
      candidate: candidateModel,
    );
  }

  @override
  Stream<List<IceCandidateEntity>> watchIceCandidates(String callId) {
    return _datasource.watchIceCandidates(callId);
  }

  @override
  Future<CallSessionEntity> getCallSession(String callId) async {
    final offer = await _datasource.getSdpOffer(callId);
    final answer = await _datasource.getSdpAnswer(callId);

    return CallSessionEntity(
      callId: callId,
      offer: offer,
      answer: answer,
      iceCandidates: const [], // ICE candidates are watched via stream
    );
  }
}
