package com.health360.app.data.model

data class AnalyzeResponse(
    val hasCough: Boolean,
    val hasSnoring: Boolean? = null,
    val coughTypeAnalysis: CoughAnalysis? = null
) {
    data class CoughAnalysis(val coughType: String, val confidence: Double)
}

data class FoodScanResponse(
    val foods: List<DetectedFood>,
    val totalNutrition: Nutrition? = null,
    val riskAlerts: List<RiskAlert> = emptyList()
) {
    data class DetectedFood(val name: String, val confidence: Double, val nutrition: Nutrition)
    data class Nutrition(val calories: Double, val fat: Double, val sugar: Double, val salt: Double)
    data class RiskAlert(val message: String, val severity: String)
}
