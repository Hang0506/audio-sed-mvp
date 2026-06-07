import SwiftUI
import Combine

final class CoinManager: ObservableObject {
    static let shared = CoinManager()
    
    @AppStorage("masterCoins") var coins: Int = 750
    @Published var animateCoinChange = false
    
    private init() {}
    
    func addCoins(_ amount: Int) {
        coins += amount
        animateCoinChange = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.animateCoinChange = false
        }
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        return true
    }
}
