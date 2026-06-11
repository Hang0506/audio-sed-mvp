import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/usecases/analyze_audio.dart';
import '../../domain/usecases/download_sample.dart';
import '../../domain/usecases/get_samples.dart';
import 'audio_sed_state.dart';

class AudioSedCubit extends Cubit<AudioSedState> {
  final GetSamples _getSamples;
  final DownloadSample _downloadSample;
  final AnalyzeAudio _analyzeAudio;

  final _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  int _elapsedSeconds = 0;
  List<String> _cachedSamples = [];
  String? _recordingPath;

  AudioSedCubit({
    required GetSamples getSamples,
    required DownloadSample downloadSample,
    required AnalyzeAudio analyzeAudio,
  })  : _getSamples = getSamples,
      _downloadSample = downloadSample,
      _analyzeAudio = analyzeAudio,
      super(const AudioSedInitial());

  Future<void> fetchSamples() async {
    emit(const AudioSedSamplesLoading());
    final result = await _getSamples();
    result.fold(
      (failure) {
        _cachedSamples = [];
        emit(AudioSedError(failure.message, samples: const []));
      },
      (samples) {
        _cachedSamples = samples;
        emit(AudioSedSamplesLoaded(samples));
      },
    );
  }

  Future<void> startRecording(String mode) async {
    try {
      // Check microphone permission using permission_handler
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        emit(AudioSedError(
          'Không có quyền truy cập microphone. Vui lòng cấp quyền trong cài đặt.',
          samples: _cachedSamples,
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
      emit(AudioSedError('Lỗi khi bắt đầu thu âm: $e', samples: _cachedSamples));
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
          (failure) => emit(AudioSedError(failure.message, samples: _cachedSamples)),
          (analysisResult) => emit(AudioSedAnalysisSuccess(
            result: analysisResult,
            mode: mode,
            samples: _cachedSamples,
          )),
        );
      } else {
        emit(AudioSedError('Không tìm thấy tệp tin thu âm', samples: _cachedSamples));
      }
    } catch (e) {
      emit(AudioSedError('Lỗi khi dừng thu âm và phân tích: $e', samples: _cachedSamples));
    }
  }

  Future<void> analyzeSampleFile(String filename, String mode) async {
    emit(const AudioSedAnalyzing());
    try {
      final downloadResult = await _downloadSample(filename);
      
      await downloadResult.fold(
        (failure) async => emit(AudioSedError(failure.message, samples: _cachedSamples)),
        (localPath) async {
          final result = await _analyzeAudio(
            AnalyzeAudioParams(filePath: localPath, mode: mode),
          );

          result.fold(
            (failure) => emit(AudioSedError(failure.message, samples: _cachedSamples)),
            (analysisResult) => emit(AudioSedAnalysisSuccess(
              result: analysisResult,
              mode: mode,
              samples: _cachedSamples,
            )),
          );
        },
      );
    } catch (e) {
      emit(AudioSedError('Lỗi phân tích tệp mẫu: $e', samples: _cachedSamples));
    }
  }

  void reset() {
    emit(AudioSedSamplesLoaded(_cachedSamples));
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    return super.close();
  }
}
