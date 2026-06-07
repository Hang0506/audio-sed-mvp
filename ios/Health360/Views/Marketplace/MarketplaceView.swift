import SwiftUI

struct MarketplaceView: View {
    @EnvironmentObject var coinManager: CoinManager
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    private let vouchers: [Voucher] = [
        Voucher(name: "🎟️ Voucher 50K Xịt Mũi Sinufresh", description: "Voucher đổi bằng xu tích luỹ từ hành động bảo vệ hệ hô hấp.", cost: 500),
        Voucher(name: "🎟️ Voucher 30K Khẩu Trang Y Tế", description: "Khẩu trang lọc bụi PM2.5 cho ngày AQI cao.", cost: 300),
        Voucher(name: "🎟️ Voucher 100K Khám Tai Mũi Họng", description: "Giảm giá khám chuyên khoa TMH tại Nhà Thuốc.", cost: 1000),
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GamifiedHeaderView(userName: "Minh Tuấn", diseaseTag: "TIẾT KIỆM TỪ SỨC KHOẺ")
                
                VStack(spacing: 12) {
                    ForEach(vouchers) { voucher in
                        VoucherCard(voucher: voucher) {
                            if coinManager.spendCoins(voucher.cost) {
                                alertMessage = "Đổi voucher thành công!"
                            } else {
                                alertMessage = "Không đủ xu!"
                            }
                            showAlert = true
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color.ds.bg)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

// MARK: - Models

private struct Voucher: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let cost: Int
}

// MARK: - VoucherCard

private struct VoucherCard: View {
    let voucher: Voucher
    let onRedeem: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(voucher.name)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.ds.textPrimary)
            Text(voucher.description)
                .font(.dsCaption)
                .foregroundColor(.ds.muted)
            HStack {
                Text("\(voucher.cost) xu")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.ds.accentOrange)
                Spacer()
                Button(action: onRedeem) {
                    Text("ĐỔI VOUCHER NGAY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.ds.accentBlue)
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.ds.card)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ds.border, lineWidth: 1))
    }
}
