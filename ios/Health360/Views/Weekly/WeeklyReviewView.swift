import SwiftUI

struct WeeklyReviewView: View {
    @EnvironmentObject var coinManager: CoinManager
    @State private var claimed = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GamifiedHeaderView(userName: "Minh Tuấn", diseaseTag: "TRIỆU CHỨNG ĐANG GIẢM DẦN", subtitleColor: .ds.accentTeal)
                
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Hệ hô hấp của bạn đang cải thiện rõ rệt sau 1 tuần thực hiện các bài tập.")
                        .font(.dsCaption)
                        .foregroundColor(.ds.muted)
                    
                    // Audio AI Results Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎙️ Kết quả Audio AI ghi âm ban đêm")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.ds.textPrimary)
                        
                        ComparisonRow(label: "CƠN HO KHAN", beforeValue: "6 lần/đêm", afterValue: "1 lần/đêm", beforeColor: .ds.accentRed, afterColor: .ds.accentTeal)
                        ComparisonRow(label: "TIẾNG THỞ NGÁY", beforeValue: "42 phút", afterValue: "12 phút", beforeColor: .ds.accentOrange, afterColor: .ds.accentTeal)
                    }
                    .padding(16)
                    .background(Color.ds.card)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ds.border, lineWidth: 1))
                    
                    // Weekly Bonus Card
                    VStack(spacing: 12) {
                        Text("Thành quả bảo vệ hệ hô hấp")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.ds.textPrimary)
                        
                        Text("🪙 +450 COINS")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.ds.accentOrange)
                        
                        Button {
                            guard !claimed else { return }
                            coinManager.addCoins(450)
                            claimed = true
                        } label: {
                            Text(claimed ? "✓ ĐÃ NHẬN XU THƯỞNG TUẦN" : "THU HOẠCH PHẦN THƯỞNG TUẦN")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "1a1a2e"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(claimed ? Color.ds.muted : Color.ds.accentOrange)
                                .cornerRadius(12)
                        }
                        .disabled(claimed)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(colors: [Color(hex: "2d1b00"), Color(hex: "1a1000")], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.ds.accentOrange.opacity(0.3), lineWidth: 1))
                }
                .padding(20)
            }
        }
        .background(Color.ds.bg)
    }
}

// MARK: - ComparisonRow

private struct ComparisonRow: View {
    let label: String
    let beforeValue: String
    let afterValue: String
    let beforeColor: Color
    let afterColor: Color
    
    var body: some View {
        HStack {
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.ds.muted)
                Text(beforeValue)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(beforeColor)
            }.frame(maxWidth: .infinity)
            
            Text("➤")
                .foregroundColor(.ds.muted)
                .font(.system(size: 14, weight: .bold))
            
            VStack(spacing: 4) {
                Text("HIỆN TẠI")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.ds.muted)
                Text(afterValue)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(afterColor)
            }.frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(Color(hex: "0f172a"))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ds.border, lineWidth: 1))
    }
}
