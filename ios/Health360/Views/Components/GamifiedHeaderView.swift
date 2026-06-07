import SwiftUI

struct GamifiedHeaderView: View {
    @EnvironmentObject var coinManager: CoinManager
    let userName: String
    let diseaseTag: String
    var subtitleColor: Color = .ds.accentBlue
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Chào \(userName) 👋")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(.ds.textPrimary)
                Text(diseaseTag)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(subtitleColor)
            }
            Spacer()
            HStack(spacing: 6) {
                Text("\(coinManager.coins)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.ds.accentOrange)
                    .scaleEffect(coinManager.animateCoinChange ? 1.2 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: coinManager.animateCoinChange)
                Text("🪙")
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color.ds.accentOrange.opacity(0.12))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.ds.accentOrange.opacity(0.25), lineWidth: 1))
            .cornerRadius(30)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: "0c1220"))
    }
}
