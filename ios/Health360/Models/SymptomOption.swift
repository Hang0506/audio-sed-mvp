import Foundation

enum SymptomGroup: String, CaseIterable {
    case nose = "nose"
    case throatEar = "throat_ear"
    
    var icon: String {
        switch self {
        case .nose: return "👃"
        case .throatEar: return "🗣️👂"
        }
    }
    
    var title: String {
        switch self {
        case .nose: return "Nhóm Triệu Chứng MŨI (Nose)"
        case .throatEar: return "Nhóm TAI - HỌNG & ĐÊM (Throat & Ear)"
        }
    }
}

enum EnabledFeature: String, CaseIterable {
    case weather
    case camera
    case audio
}

struct SymptomOption: Identifiable {
    let id: String
    let group: SymptomGroup
    let title: String
    let triggerDescription: String
    
    static let all: [SymptomOption] = [
        SymptomOption(id: "mui_hat_hoi_lanh", group: .nose, title: "Hắt hơi liên tục khi thời tiết giao mùa", triggerDescription: "Kích hoạt Widget Định vị & Đo chỉ số thời tiết / PM2.5"),
        SymptomOption(id: "mui_ngat_di_ung", group: .nose, title: "Nghẹt mũi, ngứa họng sau ăn đồ lạ, đồ lạnh", triggerDescription: "Kích hoạt Máy Quét Camera AI phân tích dị nguyên thức ăn"),
        SymptomOption(id: "hong_ho_khan_dem", group: .throatEar, title: "Ho khan kịch phát, ngứa cổ rát họng về đêm", triggerDescription: "Kích hoạt Audio AI Mic ghi âm, phân tích tần suất Ho nền"),
        SymptomOption(id: "ngu_ngay_tho_mieng", group: .throatEar, title: "Ngủ ngáy, thở bằng miệng, ù khò khè", triggerDescription: "Kích hoạt Cảm biến âm thanh đo Oxy và tiếng thở ngáy ngủ"),
    ]
}
