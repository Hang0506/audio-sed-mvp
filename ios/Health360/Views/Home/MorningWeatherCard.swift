import SwiftUI

struct MorningWeatherCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Orange left-bordered card
            HStack(alignment: .top) {
                Rectangle()
                    .fill(Color.ds.accentOrange)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("⚠️ NGUY CƠ KÍCH ỨNG MŨI: 85%")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.ds.accentOrange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.ds.accentOrange.opacity(0.12))
                            .cornerRadius(4)
                        Spacer()
                        Text("AQI: 162 😷")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.ds.accentOrange)
                    }
                    
                    Text("Độ ẩm giảm sâu đột ngột (52%) & Bụi mịn PM2.5 tăng mạnh.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.ds.textPrimary)
                    
                    Text("Niêm mạc mũi mất độ ẩm → dễ hắt hơi liên tục & ngạt mũi khi ra ngoài.")
                        .font(.system(size: 11))
                        .foregroundColor(.ds.muted)
                }
                .padding(.vertical, 4)
            }
            .padding(12)
            .background(Color.ds.card)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ds.border, lineWidth: 1))
            
            // Habit task
            HabitTaskRow(
                title: "Vệ sinh cuốn mũi bằng nước muối ấm",
                description: "Loại bỏ bụi mịn bám dính gây kích ứng hắt hơi.",
                reward: 50
            )
        }
    }
}
