import SwiftUI

final class FeatureGateService: ObservableObject {
    static let shared = FeatureGateService()
    
    @AppStorage("selectedSymptomIDs") private var storedSymptoms: String = ""
    
    var symptomIDs: Set<String> {
        get { Set(storedSymptoms.split(separator: ",").map(String.init)) }
        set { storedSymptoms = newValue.joined(separator: ",") }
    }
    
    var enabledFeatures: Set<EnabledFeature> {
        var features = Set<EnabledFeature>()
        if symptomIDs.contains("mui_hat_hoi_lanh") { features.insert(.weather) }
        if symptomIDs.contains("mui_ngat_di_ung") { features.insert(.camera) }
        if symptomIDs.contains("hong_ho_khan_dem") || symptomIDs.contains("ngu_ngay_tho_mieng") { features.insert(.audio) }
        return features
    }
    
    func isEnabled(_ feature: EnabledFeature) -> Bool {
        enabledFeatures.contains(feature)
    }
    
    func saveSymptoms(_ ids: Set<String>) {
        symptomIDs = ids
    }
}
