import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../domain/entities/call_entity.dart';
import '../../../domain/entities/call_session_entity.dart';
import '../../../domain/usecases/answer_call_usecase.dart';
import '../../../domain/usecases/end_call_usecase.dart';
import '../../../domain/usecases/initiate_call_usecase.dart';
import '../../../domain/usecases/reject_call_usecase.dart';
import '../../../domain/usecases/send_ice_candidate_usecase.dart';
import '../../../domain/usecases/watch_call_usecase.dart';
import '../../../domain/usecases/watch_user_calls_usecase.dart';
import 'video_call_event.dart';
import 'video_call_state.dart';

/// Video Call BLoC
/// Manages video call state and WebRTC connections
class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final InitiateCallUseCase _initiateCallUseCase;
  final AnswerCallUseCase _answerCallUseCase;
  final EndCallUseCase _endCallUseCase;
  final RejectCallUseCase _rejectCallUseCase;
  final SendIceCandidateUseCase _sendIceCandidateUseCase;
  final WatchCallUseCase _watchCallUseCase;
  final WatchUserCallsUseCase _watchUserCallsUseCase;

  // WebRTC components
  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;
  MediaStream? _localStream;

  // Subscriptions
  StreamSubscription? _callSubscription;
  StreamSubscription? _userCallsSubscription;
  StreamSubscription? _iceCandidatesSubscription;

  // Current call ID
  String? _currentCallId;

  VideoCallBloc({
    required InitiateCallUseCase initiateCallUseCase,
    required AnswerCallUseCase answerCallUseCase,
    required EndCallUseCase endCallUseCase,
    required RejectCallUseCase rejectCallUseCase,
    required SendIceCandidateUseCase sendIceCandidateUseCase,
    required WatchCallUseCase watchCallUseCase,
    required WatchUserCallsUseCase watchUserCallsUseCase,
  })  : _initiateCallUseCase = initiateCallUseCase,
        _answerCallUseCase = answerCallUseCase,
        _endCallUseCase = endCallUseCase,
        _rejectCallUseCase = rejectCallUseCase,
        _sendIceCandidateUseCase = sendIceCandidateUseCase,
        _watchCallUseCase = watchCallUseCase,
        _watchUserCallsUseCase = watchUserCallsUseCase,
        super(const VideoCallInitial()) {
    on<InitiateVideoCall>(_onInitiateCall);
    on<AnswerVideoCall>(_onAnswerCall);
    on<RejectVideoCall>(_onRejectCall);
    on<EndVideoCall>(_onEndCall);
    on<ToggleMicrophone>(_onToggleMicrophone);
    on<ToggleCamera>(_onToggleCamera);
    on<SwitchCamera>(_onSwitchCamera);
    on<WatchIncomingCalls>(_onWatchIncomingCalls);
    on<StopWatchingCalls>(_onStopWatchingCalls);
    on<CallStatusUpdated>(_onCallStatusUpdated);
  }

  /// Initialize WebRTC peer connection
  Future<void> _initializePeerConnection() async {
    final configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun.l.google.com:19302',
            'stun:stun1.l.google.com:19302',
          ]
        }
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    // Set up event handlers
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (_currentCallId != null) {
        // Send ICE candidate to remote peer via Supabase
        _sendIceCandidateUseCase.execute(
          callId: _currentCallId!,
          userId: '', // TODO: Get current user ID
          candidate: IceCandidateEntity(
            id: '',
            callId: _currentCallId!,
            userId: '',
            candidate: candidate.candidate ?? '',
            sdpMid: candidate.sdpMid,
            sdpMLineIndex: candidate.sdpMLineIndex,
            createdAt: DateTime.now(),
          ),
        );
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer?.srcObject = event.streams[0];
      }
    };
  }

  /// Get local media stream (camera + microphone)
  Future<MediaStream> _getLocalStream() async {
    final constraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
        'width': 1280,
        'height': 720,
      }
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    return _localStream!;
  }

  /// Handle initiate call event
  Future<void> _onInitiateCall(
    InitiateVideoCall event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      emit(VideoCallInitiating(event.calleeId));

      // Initialize WebRTC
      await _initializePeerConnection();
      _localRenderer = RTCVideoRenderer();
      _remoteRenderer = RTCVideoRenderer();
      await _localRenderer!.initialize();
      await _remoteRenderer!.initialize();

      // Get local media stream
      final localStream = await _getLocalStream();
      _localRenderer!.srcObject = localStream;

      // Add tracks to peer connection
      localStream.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, localStream);
      });

      // Create SDP offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Initiate call via use case
      final callId = await _initiateCallUseCase.execute(
        callerId: event.callerId,
        calleeId: event.calleeId,
        sdpOffer: SdpEntity(
          type: 'offer',
          sdp: offer.sdp ?? '',
        ),
      );

      _currentCallId = callId;

      // Watch for call updates
      _callSubscription = _watchCallUseCase.execute(callId).listen(
        (call) {
          add(CallStatusUpdated(callId: callId, status: call.status.name));
        },
      );

      emit(VideoCallRinging(
        call: CallEntity(
          id: callId,
          callerId: event.callerId,
          calleeId: event.calleeId,
          status: CallStatus.ringing,
          createdAt: DateTime.now(),
        ),
        isOutgoing: true,
      ));
    } catch (e) {
      emit(VideoCallError('Failed to initiate call: $e'));
    }
  }

  /// Handle answer call event
  Future<void> _onAnswerCall(
    AnswerVideoCall event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      // Initialize WebRTC
      await _initializePeerConnection();
      _localRenderer = RTCVideoRenderer();
      _remoteRenderer = RTCVideoRenderer();
      await _localRenderer!.initialize();
      await _remoteRenderer!.initialize();

      // Get local media stream
      final localStream = await _getLocalStream();
      _localRenderer!.srcObject = localStream;

      // Add tracks to peer connection
      localStream.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, localStream);
      });

      // TODO: Get SDP offer from Supabase and set remote description
      // TODO: Create SDP answer and send to Supabase

      _currentCallId = event.callId;

      // Answer call via use case
      await _answerCallUseCase.execute(
        callId: event.callId,
        sdpAnswer: const SdpEntity(type: 'answer', sdp: ''), // TODO: Real SDP
      );

      emit(VideoCallActive(
        call: CallEntity(
          id: event.callId,
          callerId: '',
          calleeId: '',
          status: CallStatus.active,
          createdAt: DateTime.now(),
        ),
        localRenderer: _localRenderer,
        remoteRenderer: _remoteRenderer,
      ));
    } catch (e) {
      emit(VideoCallError('Failed to answer call: $e'));
    }
  }

  /// Handle reject call event
  Future<void> _onRejectCall(
    RejectVideoCall event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      await _rejectCallUseCase.execute(event.callId);
      emit(VideoCallRejected(event.callId));
      await _cleanup();
    } catch (e) {
      emit(VideoCallError('Failed to reject call: $e'));
    }
  }

  /// Handle end call event
  Future<void> _onEndCall(
    EndVideoCall event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      await _endCallUseCase.execute(event.callId);
      emit(const VideoCallEnded('Call ended'));
      await _cleanup();
    } catch (e) {
      emit(VideoCallError('Failed to end call: $e'));
    }
  }

  /// Handle toggle microphone event
  Future<void> _onToggleMicrophone(
    ToggleMicrophone event,
    Emitter<VideoCallState> emit,
  ) async {
    if (state is VideoCallActive) {
      final currentState = state as VideoCallActive;
      final newMutedState = !currentState.isMuted;

      // Toggle audio tracks
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = !newMutedState;
      });

      emit(currentState.copyWith(isMuted: newMutedState));
    }
  }

  /// Handle toggle camera event
  Future<void> _onToggleCamera(
    ToggleCamera event,
    Emitter<VideoCallState> emit,
  ) async {
    if (state is VideoCallActive) {
      final currentState = state as VideoCallActive;
      final newCameraState = !currentState.isCameraOff;

      // Toggle video tracks
      _localStream?.getVideoTracks().forEach((track) {
        track.enabled = !newCameraState;
      });

      emit(currentState.copyWith(isCameraOff: newCameraState));
    }
  }

  /// Handle switch camera event
  Future<void> _onSwitchCamera(
    SwitchCamera event,
    Emitter<VideoCallState> emit,
  ) async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  /// Handle watch incoming calls event
  Future<void> _onWatchIncomingCalls(
    WatchIncomingCalls event,
    Emitter<VideoCallState> emit,
  ) async {
    emit(VideoCallWatching(event.userId));

    _userCallsSubscription =
        _watchUserCallsUseCase.execute(event.userId).listen(
      (calls) {
        // Find incoming ringing calls
        final incomingCall = calls.firstWhere(
          (call) => call.calleeId == event.userId && call.isRinging,
          orElse: () => calls.first,
        );

        if (incomingCall.isRinging && incomingCall.calleeId == event.userId) {
          emit(VideoCallIncoming(incomingCall));
        }
      },
    );
  }

  /// Handle stop watching calls event
  Future<void> _onStopWatchingCalls(
    StopWatchingCalls event,
    Emitter<VideoCallState> emit,
  ) async {
    await _userCallsSubscription?.cancel();
    _userCallsSubscription = null;
    emit(const VideoCallInitial());
  }

  /// Handle call status updated event
  Future<void> _onCallStatusUpdated(
    CallStatusUpdated event,
    Emitter<VideoCallState> emit,
  ) async {
    if (event.status == 'active' && state is VideoCallRinging) {
      final ringingState = state as VideoCallRinging;
      emit(VideoCallActive(
        call: ringingState.call.copyWith(status: CallStatus.active),
        localRenderer: _localRenderer,
        remoteRenderer: _remoteRenderer,
      ));
    } else if (event.status == 'ended') {
      emit(const VideoCallEnded('Call ended by remote peer'));
      await _cleanup();
    } else if (event.status == 'rejected') {
      emit(VideoCallRejected(event.callId));
      await _cleanup();
    }
  }

  /// Cleanup resources
  Future<void> _cleanup() async {
    await _callSubscription?.cancel();
    await _userCallsSubscription?.cancel();
    await _iceCandidatesSubscription?.cancel();

    _localStream?.getTracks().forEach((track) => track.stop());
    await _localStream?.dispose();

    await _localRenderer?.dispose();
    await _remoteRenderer?.dispose();

    await _peerConnection?.close();
    await _peerConnection?.dispose();

    _peerConnection = null;
    _localRenderer = null;
    _remoteRenderer = null;
    _localStream = null;
    _currentCallId = null;
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }
}
