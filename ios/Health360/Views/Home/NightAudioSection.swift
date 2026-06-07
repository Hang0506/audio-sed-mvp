import SwiftUI
import AVFoundation

struct NightAudioSection: View {
    @State private var isActivated = false
    @State private var barHeights: [CGFloat] = [0.3, 0.6, 0.9, 0.5, 0.7]
    @EnvironmentObject var coinManager: CoinManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Purple left-bordered card
            HStack(alignment: .top) {
                Rectangle()
                    .fill(Color.ds.accentPurple)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("🎙️ TRỢ LÝ ĐÊM AUDIO AI")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.ds.accentPurple)
                        Spacer()
                        HStack(spacing: 4) {
                            PulseDotPurple()
                            Text("MIC ACTIVE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.ds.accentPurple)
                        }
                    }
                    
                    Text("Theo dõi tiếng Ho, Ngáy, Thở dốc trong đêm. AI phân tích tần suất & cường độ âm thanh bất thường.")
                        .font(.system(size: 11))
                        .foregroundColor(.ds.muted)
                    
                    // Waveform
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.ds.accentPurple.opacity(0.7))
                                .frame(width: 6, height: barHeights[i] * 30)
                        }
                    }
                    .frame(height: 30, alignment: .bottom)
                    .onAppear { animateBars() }
                }
                .padding(.vertical, 4)
            }
            .padding(12)
            .background(Color.ds.card)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ds.accentPurple.opacity(0.3), lineWidth: 1))
            
            // CTA Button
            Button(action: activateMic) {
                Text(isActivated ? "✓ ĐÃ BẬT MIC — ĐANG GHI ÂM NỀN..." : "KÍCH HOẠT ĐO ĐÊM +100 COINS")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(isActivated ? .ds.accentTeal : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isActivated ? Color.ds.accentTeal.opacity(0.12) : Color.ds.accentTeal)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ds.accentTeal.opacity(0.4), lineWidth: 1))
            }
            .disabled(isActivated)
        }
    }
    
    private func activateMic() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    isActivated = true
                    coinManager.addCoins(100)
                }
            }
        }
    }
    
    private func animateBars() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                barHeights = (0..<5).map { _ in CGFloat.random(in: 0.2...1.0) }
            }
        }
    }
}

private struct PulseDotPurple: View {
    @State private var pulse = false
    
    var body: some View {
        Circle()
            .fill(Color.ds.accentPurple)
            .frame(width: 6, height: 6)
            .opacity(pulse ? 1 : 0.4)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever()) { pulse = true }
            }
    }
}
