import SwiftUI

struct AnalyzeResponse: Decodable {
    let hasCough: Bool
    let hasSnoring: Bool?
    let coughTypeAnalysis: CoughAnalysis?

    struct CoughAnalysis: Decodable {
        let coughType: String
        let confidence: Double
    }
}

struct ScannerView: View {
    enum ScanMode: String, CaseIterable {
        case nutrition = "🥗 Dinh Dưỡng"
        case respiratory = "🎙️ Hô Hấp"
    }

    @State private var mode: ScanMode = .respiratory
    @StateObject private var recorder = AudioRecorder()
    @State private var result: AnalyzeResponse?
    @State private var isAnalyzing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                Picker("Mode", selection: $mode) {
                    ForEach(ScanMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)

                switch mode {
                case .respiratory: respiratoryContent
                case .nutrition: nutritionContent
                }

                Spacer()
            }
            .padding(.top, Spacing.md)
            .background(Color.ds.bg.ignoresSafeArea())
            .navigationTitle("Quét sinh trắc")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Respiratory Mode

    @ViewBuilder
    private var respiratoryContent: some View {
        VStack(spacing: Spacing.lg) {
            AudioWaveView(isRecording: recorder.isRecording)
                .padding(.top, Spacing.xl)

            if recorder.isRecording {
                Text("\(5 - recorder.recordingTime)s")
                    .font(.dsTitle).foregroundColor(.ds.textPrimary)
            }

            // Record button
            Button { recorder.isRecording ? recorder.stopRecording() : startAnalysis() } label: {
                Circle()
                    .fill(recorder.isRecording ? Color.ds.accentRed : Color.ds.accentPurple)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                            .font(.title2).foregroundColor(.white)
                    )
            }

            if isAnalyzing {
                ProgressView("Đang phân tích...").foregroundColor(.ds.muted)
            }

            if let r = result {
                resultCard(r)
            }

            if let err = errorMessage {
                Text(err).font(.dsCaption).foregroundColor(.ds.accentRed)
            }
        }
    }

    @ViewBuilder
    private func resultCard(_ r: AnalyzeResponse) -> some View {
        VStack(spacing: Spacing.sm) {
            if let analysis = r.coughTypeAnalysis {
                HStack {
                    Text("Loại ho:").foregroundColor(.ds.muted)
                    Text(analysis.coughType).foregroundColor(.ds.textPrimary).bold()
                }
                HStack {
                    Text("Độ tin cậy:").foregroundColor(.ds.muted)
                    Text("\(Int(analysis.confidence * 100))%").foregroundColor(.ds.accentBlue).bold()
                }
            }

            if r.hasCough {
                Label("Phát hiện ho — xem Tổng kết tuần", systemImage: "lungs.fill")
                    .font(.dsCaption).foregroundColor(.ds.accentOrange)
            }
            if r.hasSnoring == true {
                Label("Phát hiện ngáy — xem Tổng kết tuần", systemImage: "bed.double.fill")
                    .font(.dsCaption).foregroundColor(.ds.accentPurple)
            }
        }
        .padding(Spacing.md)
        .background(Color.ds.card).cornerRadius(12)
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Nutrition Mode

    @ViewBuilder
    private var nutritionContent: some View {
        VStack(spacing: Spacing.lg) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ds.card)
                .frame(height: 280)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 48)).foregroundColor(.ds.muted)
                )
                .padding(.horizontal, Spacing.md)

            NavigationLink {
                // FoodCameraView() — created by other agent
                Text("FoodCameraView placeholder").foregroundColor(.ds.muted)
            } label: {
                Label("Chụp thực phẩm", systemImage: "camera.circle.fill")
                    .font(.dsHeadline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(Spacing.md)
                    .background(Color.ds.accentBlue).cornerRadius(12)
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - Actions

    private func startAnalysis() {
        result = nil
        errorMessage = nil
        recorder.startRecording()

        // Wait for recording to finish, then analyze
        Task {
            while recorder.isRecording { try? await Task.sleep(nanoseconds: 200_000_000) }
            guard let data = recorder.audioData else { return }
            await analyze(data)
        }
    }

    private func analyze(_ data: Data) async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        // Build multipart request
        let boundary = UUID().uuidString
        var body = Data()
        body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\nContent-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"mode\"\r\n\r\nv2\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        guard let url = URL(string: APIClient.shared.baseURL + "/api/analyze") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        do {
            let (resData, _) = try await URLSession.shared.data(for: req)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            result = try decoder.decode(AnalyzeResponse.self, from: resData)
        } catch {
            errorMessage = "Lỗi phân tích: \(error.localizedDescription)"
        }
    }
}
