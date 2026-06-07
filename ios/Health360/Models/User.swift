import Foundation

struct UserProfile: Codable {
    var symptomIDs: Set<String>
    var diseaseTags: [String]
    var name: String
    
    static let `default` = UserProfile(symptomIDs: [], diseaseTags: ["ENT"], name: "Minh Tuấn")
}
