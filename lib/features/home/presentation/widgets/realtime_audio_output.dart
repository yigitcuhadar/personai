import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../cubit/home_cubit.dart';

class RealtimeAudioOutput extends StatefulWidget {
  const RealtimeAudioOutput({super.key});

  @override
  State<RealtimeAudioOutput> createState() => _RealtimeAudioOutputState();
}

class _RealtimeAudioOutputState extends State<RealtimeAudioOutput> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  late final Future<void> _rendererInit;
  final Set<String> _trackIds = <String>{};
  MediaStream? _remoteStream;
  StreamSubscription<MediaStreamTrack>? _trackSub;

  @override
  void initState() {
    super.initState();
    _rendererInit = _renderer.initialize();
    _trackSub = context.read<HomeCubit>().remoteAudioTracks.listen(_handleTrack);
  }

  Future<void> _handleTrack(MediaStreamTrack track) async {
    await _rendererInit;
    if (_trackIds.contains(track.id)) return;
    _trackIds.add(track.id!);
    final stream = await _ensureStream();
    await stream.addTrack(track);
    _renderer.srcObject = stream;
  }

  Future<MediaStream> _ensureStream() async {
    if (_remoteStream != null) return _remoteStream!;
    _remoteStream = await createLocalMediaStream('openai-remote-audio');
    return _remoteStream!;
  }

  void _clearStream() {
    _trackIds.clear();
    _renderer.srcObject = null;
    final stream = _remoteStream;
    _remoteStream = null;
    if (stream != null) {
      unawaited(stream.dispose());
    }
  }

  @override
  void dispose() {
    if (_trackSub != null) {
      unawaited(_trackSub!.cancel());
    }
    _clearStream();
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status != HomeStatus.connected) {
          _clearStream();
        }
      },
      child: Offstage(
        offstage: true,
        child: RTCVideoView(_renderer),
      ),
    );
  }
}
