import SwiftUI

// MARK: - Models

struct DetectedFood: Identifiable {
    let id = UUID()
    let nameVi: String
    let confidence: Double
    let calories: Double
    let fat: Double
    let sugar: Double
    let salt: Double
}

struct FoodRiskAlert: Identifiable {
    let id = UUID()
    let message: String
    let severity: String
}

// MARK: - Mock Data

private let mockFoods: [DetectedFood] = [
    DetectedFood(nameVi: "Phở bò tái", confidence: 0.94, calories: 480, fat: 12, sugar: 3, salt: 2.8),
    DetectedFood(nameVi: "Nem chua rán", confidence: 0.87, calories: 320, fat: 22, sugar: 1, salt: 1.9),
    DetectedFood(nameVi: "Nước ngọt có ga", confidence: 0.91, calories: 140, fat: 0, sugar: 39, salt: 0.1),
]

private let mockAlerts: [FoodRiskAlert] = [
    FoodRiskAlert(message: "⚠️ Purine cao từ thịt bò — nguy cơ tăng Axit Uric", severity: "Cao"),
]

// MARK: - View

struct FoodResultView: View {
    @State private var expandedId: UUID?

    private var totalCalories: Double { mockFoods.reduce(0) { $0 + $1.calories } }
    private var totalFat: Double { mockFoods.reduce(0) { $0 + $1.fat } }
    private var totalSugar: Double { mockFoods.reduce(0) { $0 + $1.sugar } }
    private var totalSalt: Double { mockFoods.reduce(0) { $0 + $1.salt } }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                // Detected foods
                ForEach(mockFoods) { food in
                    foodCard(food)
                }

                // Total summary
                summaryCard

                // Risk alerts
                if !mockAlerts.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Cảnh báo sức khỏe")
                            .font(.dsHeadline)
                            .foregroundColor(.ds.textPrimary)
                        ForEach(mockAlerts) { alert in
                            HStack(spacing: 10) {
                                Circle().fill(Color.ds.accentRed).frame(width: 8, height: 8)
                                Text(alert.message)
                                    .font(.dsCaption)
                                    .foregroundColor(.ds.textPrimary)
                            }
                            .padding(12)
                            .background(Color.ds.card)
                            .cornerRadius(8)
                        }
                    }
                }

                // CTA
                Button(action: {}) {
                    Text("Mua thực phẩm thay thế tốt hơn")
                        .font(.dsHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(Color.ds.accentTeal)
                        .cornerRadius(12)
                }
            }
            .padding(Spacing.md)
        }
        .background(Color.ds.bg.ignoresSafeArea())
        .navigationTitle("Kết quả phân tích")
    }

    // MARK: - Components

    private func foodCard(_ food: DetectedFood) -> some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: Spacing.md) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.ds.border)
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "fork.knife").foregroundColor(.ds.muted))
                VStack(alignment: .leading, spacing: 2) {
                    Text(food.nameVi)
                        .font(.dsBody)
                        .foregroundColor(.ds.textPrimary)
                    Text("\(Int(food.confidence * 100))% chính xác")
                        .font(.dsCaption)
                        .foregroundColor(.ds.muted)
                }
                Spacer()
                Image(systemName: expandedId == food.id ? "chevron.up" : "chevron.down")
                    .foregroundColor(.ds.muted)
            }
            .contentShape(Rectangle())
            .onTapGesture { withAnimation { expandedId = expandedId == food.id ? nil : food.id } }

            // Expandable nutrition
            if expandedId == food.id {
                VStack(spacing: Spacing.sm) {
                    nutritionRow("Calories", value: food.calories, unit: "kcal", threshold: (300, 500))
                    nutritionRow("Chất béo", value: food.fat, unit: "g", threshold: (10, 20))
                    nutritionRow("Đường", value: food.sugar, unit: "g", threshold: (10, 25))
                    nutritionRow("Muối", value: food.salt, unit: "g", threshold: (1.5, 2.5))
                }
                .padding(.top, Spacing.sm)
            }
        }
        .padding(Spacing.md)
        .background(Color.ds.card)
        .cornerRadius(12)
    }

    private func nutritionRow(_ label: String, value: Double, unit: String, threshold: (Double, Double)) -> some View {
        HStack {
            Text(trafficLight(value, threshold: threshold))
            Text(label)
                .font(.dsCaption)
                .foregroundColor(.ds.muted)
            Spacer()
            Text("\(Int(value)) \(unit)")
                .font(.dsCaption)
                .foregroundColor(.ds.textPrimary)
        }
    }

    private func trafficLight(_ value: Double, threshold: (Double, Double)) -> String {
        if value < threshold.0 { return "🟢" }
        if value < threshold.1 { return "🟡" }
        return "🔴"
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Tổng bữa ăn")
                .font(.dsHeadline)
                .foregroundColor(.ds.textPrimary)
            HStack {
                summaryItem("Calories", "\(Int(totalCalories)) kcal")
                summaryItem("Béo", "\(Int(totalFat))g")
                summaryItem("Đường", "\(Int(totalSugar))g")
                summaryItem("Muối", String(format: "%.1fg", totalSalt))
            }
        }
        .padding(Spacing.md)
        .background(Color.ds.card)
        .cornerRadius(12)
    }

    private func summaryItem(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.dsBody).foregroundColor(.ds.accentBlue)
            Text(label).font(.dsCaption).foregroundColor(.ds.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        FoodResultView()
    }
}
