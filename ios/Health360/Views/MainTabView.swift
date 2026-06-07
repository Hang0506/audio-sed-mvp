import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var coinManager: CoinManager
    @EnvironmentObject private var featureGate: FeatureGateService
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Trang chủ", systemImage: "house.fill") }
            
            WeeklyReviewView()
                .tabItem { Label("Tổng kết", systemImage: "chart.bar.fill") }
            
            MarketplaceView()
                .tabItem { Label("Đổi thưởng", systemImage: "gift.fill") }
        }
        .tint(.ds.accentBlue)
    }
}
