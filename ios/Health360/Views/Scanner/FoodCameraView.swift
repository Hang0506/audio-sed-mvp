import SwiftUI

struct FoodCameraView: View {
    @StateObject private var camera = CameraManager()
    @State private var isAnalyzing = false
    @State private var showResult = false
    @State private var flashOn = false

    var body: some View {
        ZStack {
            Color.ds.bg.ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                // Viewfinder
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.ds.card)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.ds.muted)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    .padding(.horizontal, Spacing.md)

                Spacer()

                // Controls
                HStack(spacing: Spacing.xl) {
                    // Gallery
                    Button(action: {}) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.ds.textPrimary)
                    }

                    // Capture
                    Button(action: capture) {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 4)
                            .frame(width: 72, height: 72)
                            .overlay(Circle().fill(Color.white).padding(6))
                    }

                    // Flash
                    Button(action: { flashOn.toggle() }) {
                        Image(systemName: flashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title2)
                            .foregroundColor(flashOn ? .ds.accentOrange : .ds.textPrimary)
                    }
                }
                .padding(.bottom, Spacing.xl)
            }

            // Analyzing overlay
            if isAnalyzing {
                Color.black.opacity(0.6).ignoresSafeArea()
                VStack(spacing: Spacing.md) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                    Text("Đang phân tích...")
                        .font(.dsHeadline)
                        .foregroundColor(.white)
                }
            }
        }
        .navigationTitle("Quét thực phẩm")
        .navigationDestination(isPresented: $showResult) {
            FoodResultView()
        }
        .onAppear { camera.requestPermission() }
    }

    private func capture() {
        isAnalyzing = true
        camera.capturePhoto()
        // Simulate analysis delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isAnalyzing = false
            showResult = true
        }
    }
}

#Preview {
    NavigationStack {
        FoodCameraView()
    }
}
