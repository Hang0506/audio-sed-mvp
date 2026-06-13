import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/usecases/analyze_audio.dart';
import 'audio_sed_state.dart';

class AudioSedCubit extends Cubit<AudioSedState> {
  final AnalyzeAudio _analyzeAudio;

  final _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  int _elapsedSeconds = 0;
  String? _recordingPath;

  AudioSedCubit({
    required AnalyzeAudio analyzeAudio,
  })  : _analyzeAudio = analyzeAudio,
        super(const AudioSedInitial());

  Future<void> startRecording(String mode) async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        emit(const AudioSedError(
          'Không có quyền truy cập microphone. Vui lòng cấp quyền trong cài đặt.',
        ));
        return;
      }

      final tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          numChannels: 1,
          sampleRate: 16000,
        ),
        path: _recordingPath!,
      );

      _elapsedSeconds = 0;
      emit(AudioSedRecording(_elapsedSeconds));

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        _elapsedSeconds++;
        if (_elapsedSeconds >= 5) {
          timer.cancel();
          await stopRecordingAndAnalyze(mode);
        } else {
          emit(AudioSedRecording(_elapsedSeconds));
        }
      });
    } catch (e) {
      emit(AudioSedError('Lỗi khi bắt đầu thu âm: $e'));
    }
  }

  Future<void> stopRecordingAndAnalyze(String mode) async {
    _recordingTimer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        emit(const AudioSedAnalyzing());
        
        final result = await _analyzeAudio(
          AnalyzeAudioParams(filePath: path, mode: mode),
        );

        result.fold(
          (failure) => emit(AudioSedError(failure.message)),
          (analysisResult) => emit(AudioSedAnalysisSuccess(
            result: analysisResult,
            mode: mode,
          )),
        );
      } else {
        emit(const AudioSedError('Không tìm thấy tệp tin thu âm'));
      }
    } catch (e) {
      emit(AudioSedError('Lỗi khi dừng thu âm và phân tích: $e'));
    }
  }

  void reset() {
    emit(const AudioSedInitial());
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    return super.close();
  }
}
