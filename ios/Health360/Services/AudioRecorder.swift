import Foundation
import AVFoundation

@MainActor
final class AudioRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: Int = 0
    @Published var audioData: Data?

    private var timer: Timer?
    private let duration = 5

    // MARK: - Phase 2: Real AVAudioRecorder path
    // private var audioRecorder: AVAudioRecorder?
    // private var recordingURL: URL { FileManager.default.temporaryDirectory.appendingPathComponent("recording.wav") }
    // private let settings: [String: Any] = [
    //     AVFormatIDKey: kAudioFormatLinearPCM,
    //     AVSampleRateKey: 16000.0,
    //     AVNumberOfChannelsKey: 1,
    //     AVLinearPCMBitDepthKey: 16,
    //     AVLinearPCMIsFloatKey: false
    // ]

    func startRecording() {
        // MVP: simulate recording with timer
        audioData = nil
        recordingTime = 0
        isRecording = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isRecording else { return }
                self.recordingTime += 1
                if self.recordingTime >= self.duration {
                    self.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        timer?.invalidate()
        timer = nil
        isRecording = false
        // MVP: placeholder data (replace with real audio in Phase 2)
        audioData = Data(count: 16000 * 2 * duration) // 16kHz * 16bit * 5s
    }
}
