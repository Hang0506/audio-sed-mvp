import '../../domain/entities/analysis_result.dart';

sealed class AudioSedState {
  const AudioSedState();
}

final class AudioSedInitial extends AudioSedState {
  const AudioSedInitial();
}

final class AudioSedSamplesLoading extends AudioSedState {
  const AudioSedSamplesLoading();
}

final class AudioSedSamplesLoaded extends AudioSedState {
  final List<String> samples;
  const AudioSedSamplesLoaded(this.samples);
}

final class AudioSedRecording extends AudioSedState {
  final int elapsedSeconds;
  const AudioSedRecording(this.elapsedSeconds);
}

final class AudioSedAnalyzing extends AudioSedState {
  const AudioSedAnalyzing();
}

final class AudioSedAnalysisSuccess extends AudioSedState {
  final AnalysisResult result;
  final String mode;
  final List<String> samples; // keep samples cached

  const AudioSedAnalysisSuccess({
    required this.result,
    required this.mode,
    required this.samples,
  });
}

final class AudioSedError extends AudioSedState {
  final String message;
  final List<String> samples; // keep samples cached

  const AudioSedError(this.message, {required this.samples});
}
