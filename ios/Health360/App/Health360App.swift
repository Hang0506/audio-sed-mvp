import SwiftUI

@main
struct Health360App: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var coinManager = CoinManager.shared
    @StateObject private var featureGate = FeatureGateService.shared
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(coinManager)
                    .environmentObject(featureGate)
                    .preferredColorScheme(.dark)
            } else {
                NavigationStack {
                    ENTSurveyView()
                        .environmentObject(coinManager)
                        .environmentObject(featureGate)
                }
                .preferredColorScheme(.dark)
            }
        }
    }
}
