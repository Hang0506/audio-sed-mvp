import SwiftUI

enum TimeOfDay: String, CaseIterable {
    case morning = "Sáng"
    case noon = "Trưa"
    case night = "Đêm"
    
    var icon: String {
        switch self {
        case .morning: return "🌅"
        case .noon: return "☀️"
        case .night: return "🌙"
        }
    }
    
    static var current: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return .morning
        case 12..<18: return .noon
        default: return .night
        }
    }
}

struct HomeView: View {
    @State private var timeOfDay: TimeOfDay = .current
    @EnvironmentObject var featureGate: FeatureGateService
    
    var body: some View {
        VStack(spacing: 0) {
            GamifiedHeaderView(
                userName: "Minh Tuấn",
                diseaseTag: "VIÊM MŨI DỊ ỨNG THỜI TIẾT"
            )
            
            // Time-of-day picker (demo override)
            Picker("", selection: $timeOfDay) {
                ForEach(TimeOfDay.allCases, id: \.self) { t in
                    Text("\(t.icon) \(t.rawValue)").tag(t)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Timeline header
                    HStack(spacing: 6) {
                        Text(timeOfDay.icon)
                            .font(.system(size: 14))
                        Text(timelineLabel)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.ds.muted)
                    }
                    .padding(.horizontal, 20)
                    
                    // Conditional content
                    Group {
                        switch timeOfDay {
                        case .morning:
                            if featureGate.isEnabled(.weather) {
                                MorningWeatherCard()
                            } else {
                                featureLockedCard("Thời tiết")
                            }
                        case .noon:
                            if featureGate.isEnabled(.camera) {
                                CameraScannerSection()
                            } else {
                                featureLockedCard("Camera AI")
                            }
                        case .night:
                            if featureGate.isEnabled(.audio) {
                                NightAudioSection()
                            } else {
                                featureLockedCard("Audio AI")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)
            }
        }
        .background(Color.ds.bg)
    }
    
    private var timelineLabel: String {
        switch timeOfDay {
        case .morning: return "BUỔI SÁNG — CẢNH BÁO THỜI TIẾT"
        case .noon: return "BUỔI TRƯA — QUÉT THỨC ĂN"
        case .night: return "BAN ĐÊM — THEO DÕI ÂM THANH"
        }
    }
    
    private func featureLockedCard(_ name: String) -> some View {
        VStack(spacing: 8) {
            Text("🔒")
                .font(.system(size: 28))
            Text("Tính năng \(name) chưa kích hoạt")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.ds.muted)
            Text("Hoàn thành khảo sát ENT để mở khoá.")
                .font(.system(size: 11))
                .foregroundColor(.ds.muted.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.ds.card)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ds.border, lineWidth: 1))
    }
}
