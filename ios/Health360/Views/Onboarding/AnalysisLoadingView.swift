import SwiftUI

struct AnalysisLoadingView: View {
    @EnvironmentObject private var featureGate: FeatureGateService
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var phase: LoadingPhase = .initializing
    
    private enum LoadingPhase {
        case initializing
        case success
    }
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .ds.accentBlue))
                .scaleEffect(1.5)
            
            Text("Đang kết nối API phần cứng...")
                .font(.dsHeadline)
                .foregroundColor(.ds.textPrimary)
            
            // Status card
            VStack(spacing: Spacing.sm) {
                if phase == .initializing {
                    Text("⏳ KHỞI TẠO HỆ THỐNG CẢM BIẾN...")
                        .font(.dsCaption)
                        .foregroundColor(.ds.accentOrange)
                } else {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("✅ Hệ thống sẵn sàng")
                            .font(.dsBody)
                            .fontWeight(.semibold)
                            .foregroundColor(.ds.accentTeal)
                        
                        ForEach(Array(featureGate.enabledFeatures), id: \.rawValue) { feature in
                            Text("• \(featureLabel(feature))")
                                .font(.dsCaption)
                                .foregroundColor(.ds.muted)
                        }
                    }
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity)
            .background(Color.ds.card)
            .cornerRadius(10)
            .padding(.horizontal, Spacing.lg)
            
            Spacer()
        }
        .background(Color.ds.bg.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { phase = .success }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                hasCompletedOnboarding = true
            }
        }
    }
    
    private func featureLabel(_ feature: EnabledFeature) -> String {
        switch feature {
        case .weather: return "Widget Thời tiết & PM2.5"
        case .camera: return "Camera AI Quét Dị nguyên"
        case .audio: return "Audio AI Mic Ghi âm"
        }
    }
}
