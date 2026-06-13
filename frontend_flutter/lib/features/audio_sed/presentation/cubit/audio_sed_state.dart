import '../../domain/entities/analysis_result.dart';

sealed class AudioSedState {
  const AudioSedState();
}

final class AudioSedInitial extends AudioSedState {
  const AudioSedInitial();
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

  const AudioSedAnalysisSuccess({
    required this.result,
    required this.mode,
  });
}

final class AudioSedError extends AudioSedState {
  final String message;

  const AudioSedError(this.message);
}
