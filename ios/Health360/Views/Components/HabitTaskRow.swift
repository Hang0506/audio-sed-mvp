import SwiftUI

struct HabitTaskRow: View {
    let title: String
    let description: String
    let reward: Int
    @State private var isDone = false
    @EnvironmentObject var coinManager: CoinManager
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isDone ? .ds.muted : .ds.textPrimary)
                    .strikethrough(isDone)
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.ds.muted)
            }
            Spacer()
            Text(isDone ? "✓ +\(reward)" : "🪙 +\(reward)")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(isDone ? .ds.accentTeal : .ds.accentOrange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((isDone ? Color.ds.accentTeal : Color.ds.accentOrange).opacity(0.08))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke((isDone ? Color.ds.accentTeal : Color.ds.accentOrange).opacity(0.15), lineWidth: 1))
        }
        .padding(14)
        .background(Color(hex: "0f172a"))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(isDone ? Color.ds.accentTeal.opacity(0.4) : Color.ds.border, lineWidth: 1))
        .cornerRadius(10)
        .onTapGesture {
            guard !isDone else { return }
            isDone = true
            coinManager.addCoins(reward)
        }
    }
}
