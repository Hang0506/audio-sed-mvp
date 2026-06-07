import SwiftUI

struct FoodScanResult {
    let name: String
    let risk: String
    let description: String
    let action: String
}

private let entFoodDB: [String: FoodScanResult] = [
    "haisan": FoodScanResult(
        name: "MÓN ĂN: LẨU HẢI SẢN (92%)",
        risk: "⚠️ Nguy cơ kích ứng: NHÓM TRIỆU CHỨNG MŨI",
        description: "Thực phẩm chứa Histamine tự do. Theo khảo sát bạn dễ ngứa họng và ngạt mũi sau ăn, món ăn này sẽ tăng nguy cơ sung huyết niêm mạc xoang.",
        action: "💡 Khuyên dùng: Sử dụng nước lọc ấm sau ăn. Hãy dùng bình xịt rửa mũi trước khi đi ngủ tối nay."
    ),
    "dalanh": FoodScanResult(
        name: "ĐỒ UỐNG: NƯỚC ĐÁ LẠNH (96%)",
        risk: "⚠️ Nguy cơ kích ứng: NHÓM HO / RÁT HỌNG ĐÊM",
        description: "Nhiệt độ thấp làm co mao mạch hầu họng đột ngột, kích hoạt cơn ho rát kịch phát vào ban đêm.",
        action: "💡 Khuyên dùng: Giữ ấm vùng cổ họng. Ngậm một ngụm nước ấm ngay lập tức."
    ),
]

struct CameraScannerSection: View {
    @State private var scanResult: FoodScanResult?
    @State private var scanLineOffset: CGFloat = 0
    @State private var hasScannedOnce = false
    @EnvironmentObject var coinManager: CoinManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("📸 MÁY QUÉT CAMERA AI (ENT NUTRITION)")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.ds.accentBlue)
                Spacer()
                PulseDot(color: .ds.accentBlue)
                Text("LENS LIVE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.ds.accentBlue)
            }
            .padding(12)
            .background(Color.ds.card)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.ds.border, lineWidth: 1))
            
            // Viewfinder
            ZStack {
                Color(hex: "0a0f1a")
                
                // Corner brackets
                CornerBrackets()
                
                // Scan line
                Rectangle()
                    .fill(Color.ds.accentBlue.opacity(0.6))
                    .frame(height: 2)
                    .offset(y: scanLineOffset)
                
                Text("Đưa đồ ăn/thức uống vào khung ngắm...")
                    .font(.system(size: 11))
                    .foregroundColor(.ds.muted)
            }
            .frame(height: 160)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ds.border, lineWidth: 1))
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                    scanLineOffset = 60
                }
            }
            
            // Food buttons
            HStack(spacing: 10) {
                FoodButton(label: "🍲 Lẩu Hải Sản") { scanFood("haisan") }
                FoodButton(label: "🧊 Nước Đá Lạnh") { scanFood("dalanh") }
            }
            
            // Result card
            if let result = scanResult {
                ScanResultCard(result: result)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
    
    private func scanFood(_ key: String) {
        withAnimation(.easeOut(duration: 0.3)) {
            scanResult = entFoodDB[key]
        }
        if !hasScannedOnce {
            hasScannedOnce = true
            coinManager.addCoins(50)
        }
    }
}

// MARK: - Sub-components

private struct PulseDot: View {
    let color: Color
    @State private var pulse = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .opacity(pulse ? 1 : 0.4)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever()) { pulse = true }
            }
    }
}

private struct CornerBrackets: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let len: CGFloat = 20
            let pad: CGFloat = 16
            
            Path { p in
                // Top-left
                p.move(to: CGPoint(x: pad, y: pad + len))
                p.addLine(to: CGPoint(x: pad, y: pad))
                p.addLine(to: CGPoint(x: pad + len, y: pad))
                // Top-right
                p.move(to: CGPoint(x: w - pad - len, y: pad))
                p.addLine(to: CGPoint(x: w - pad, y: pad))
                p.addLine(to: CGPoint(x: w - pad, y: pad + len))
                // Bottom-left
                p.move(to: CGPoint(x: pad, y: h - pad - len))
                p.addLine(to: CGPoint(x: pad, y: h - pad))
                p.addLine(to: CGPoint(x: pad + len, y: h - pad))
                // Bottom-right
                p.move(to: CGPoint(x: w - pad - len, y: h - pad))
                p.addLine(to: CGPoint(x: w - pad, y: h - pad))
                p.addLine(to: CGPoint(x: w - pad, y: h - pad - len))
            }
            .stroke(Color.ds.accentBlue, lineWidth: 2)
        }
    }
}

private struct FoodButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.ds.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.ds.card)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.ds.accentBlue.opacity(0.3), lineWidth: 1))
        }
    }
}

private struct ScanResultCard: View {
    let result: FoodScanResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.name)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.ds.accentOrange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.ds.accentOrange.opacity(0.12))
                .cornerRadius(4)
            
            Text(result.risk)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.ds.accentRed)
            
            Text(result.description)
                .font(.system(size: 12))
                .foregroundColor(.ds.textPrimary)
            
            Text(result.action)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.ds.accentTeal)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.ds.accentTeal.opacity(0.08))
                .cornerRadius(8)
        }
        .padding(12)
        .background(Color.ds.card)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ds.border, lineWidth: 1))
    }
}
