import SwiftUI

struct ENTSurveyView: View {
    @EnvironmentObject private var featureGate: FeatureGateService
    @State private var selectedIDs: Set<String> = []
    @State private var navigateToLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("SÀNG LỌC LÂM SÀNG")
                        .font(.dsCaption)
                        .fontWeight(.bold)
                        .foregroundColor(.ds.accentBlue)
                        .textCase(.uppercase)
                    
                    Text("Chỉ Số Tai-Mũi-Họng")
                        .font(.dsTitle)
                        .foregroundColor(.ds.textPrimary)
                }
                
                // Question
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Cặp triệu chứng nào đang làm phiền bạn nhất?")
                        .font(.dsHeadline)
                        .foregroundColor(.ds.textPrimary)
                    
                    Text("Chọn để AI kích hoạt cảm biến đo lường tương ứng phần cứng.")
                        .font(.dsCaption)
                        .foregroundColor(.ds.muted)
                }
                
                // Symptom groups
                ForEach(SymptomGroup.allCases, id: \.rawValue) { group in
                    symptomGroupSection(group)
                }
                
                // CTA
                Button(action: submitSurvey) {
                    Text("Phân Tích Hồ Sơ Gốc ➔")
                        .font(.dsHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(selectedIDs.isEmpty ? Color.ds.border : Color.ds.accentBlue)
                        .cornerRadius(12)
                }
                .disabled(selectedIDs.isEmpty)
            }
            .padding(Spacing.md)
        }
        .background(Color.ds.bg.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToLoading) {
            AnalysisLoadingView()
                .environmentObject(featureGate)
        }
    }
    
    @ViewBuilder
    private func symptomGroupSection(_ group: SymptomGroup) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("\(group.icon) \(group.title)")
                .font(.dsCaption)
                .fontWeight(.semibold)
                .foregroundColor(group == .nose ? .ds.accentBlue : .ds.accentPurple)
            
            let options = SymptomOption.all.filter { $0.group == group }
            ForEach(options) { option in
                symptomCard(option, accentColor: group == .nose ? .ds.accentBlue : .ds.accentPurple)
            }
        }
    }
    
    @ViewBuilder
    private func symptomCard(_ option: SymptomOption, accentColor: Color) -> some View {
        let isSelected = selectedIDs.contains(option.id)
        
        Button {
            if isSelected { selectedIDs.remove(option.id) }
            else { selectedIDs.insert(option.id) }
        } label: {
            HStack(alignment: .top, spacing: Spacing.sm) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? accentColor : .ds.muted)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                        .font(.dsBody)
                        .fontWeight(.semibold)
                        .foregroundColor(.ds.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(option.triggerDescription)
                        .font(.dsCaption)
                        .foregroundColor(.ds.muted)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(Spacing.md)
            .background(Color.ds.card)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? accentColor : .ds.border, lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func submitSurvey() {
        featureGate.saveSymptoms(selectedIDs)
        navigateToLoading = true
    }
}
