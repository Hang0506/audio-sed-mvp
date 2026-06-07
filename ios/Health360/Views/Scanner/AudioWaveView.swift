import SwiftUI

struct AudioWaveView: View {
    let isRecording: Bool
    @State private var barHeights: [CGFloat] = Array(repeating: 0.3, count: 5)

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color.ds.accentPurple, Color.ds.accentPurple.opacity(0.5)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 60 * barHeights[i])
            }
        }
        .frame(height: 60)
        .onChange(of: isRecording) { recording in
            if recording { startPulse() } else { resetBars() }
        }
        .onAppear { breathe() }
    }

    private func startPulse() {
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            guard isRecording else { timer.invalidate(); return }
            withAnimation(.easeInOut(duration: 0.15)) {
                barHeights = (0..<5).map { _ in CGFloat.random(in: 0.2...1.0) }
            }
        }
    }

    private func resetBars() {
        withAnimation(.easeInOut(duration: 0.4)) {
            barHeights = Array(repeating: 0.3, count: 5)
        }
        breathe()
    }

    private func breathe() {
        guard !isRecording else { return }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            barHeights = (0..<5).map { _ in CGFloat.random(in: 0.25...0.4) }
        }
    }
}
