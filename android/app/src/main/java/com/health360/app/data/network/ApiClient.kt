package com.health360.app.data.network

import com.google.gson.annotations.SerializedName
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.RequestBody
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.*
import java.util.concurrent.TimeUnit

// === API Response models ===

data class IntakeResponse(val userId: String = "", val message: String = "")

data class ContextResponse(
    @SerializedName("user_id") val userId: String = "",
    val weather: WeatherData? = null,
    @SerializedName("disease_tags") val diseaseTags: List<String> = emptyList(),
    val symptoms: List<String> = emptyList()
)

data class WeatherData(
    val temperature: Double = 0.0,
    val humidity: Double = 0.0,
    val pm25: Double = 0.0,
    val aqi: Int = 0,
    @SerializedName("location_name") val locationName: String = ""
)

data class AnalyzeResponse(
    @SerializedName("has_cough") val hasCough: Boolean = false,
    @SerializedName("has_snoring") val hasSnoring: Boolean? = null,
    @SerializedName("cough_type_analysis") val coughTypeAnalysis: CoughTypeAnalysis? = null,
    val events: List<AudioEvent> = emptyList()
)

data class CoughTypeAnalysis(
    @SerializedName("cough_type") val coughType: String = "",
    val confidence: Double = 0.0
)

data class AudioEvent(val label: String = "", val confidence: Double = 0.0)

data class RecommendationResponse(
    val severity: String = "",
    val recommendations: List<RecCategory> = emptyList()
)

data class RecCategory(val category: String = "", val items: List<RecItem> = emptyList())
data class RecItem(val name: String = "", val description: String = "", val product: RecProduct? = null)
data class RecProduct(val name: String = "", val price: Int = 0)

data class SleepApiResponse(
    val classification: Any? = null,
    @SerializedName("risk_score") val riskScore: Double = 0.0,
    val recommendations: List<SleepRecCategory> = emptyList(),
    @SerializedName("should_see_doctor") val shouldSeeDoctor: Boolean = false
)

data class SleepRecCategory(val category: String = "", val items: List<String> = emptyList())

data class FoodScanApiResponse(
    val foods: List<DetectedFoodApi> = emptyList(),
    @SerializedName("total_nutrition") val totalNutrition: NutritionApi? = null,
    @SerializedName("risk_alerts") val riskAlerts: List<RiskAlertApi> = emptyList()
)

data class DetectedFoodApi(val name: String = "", val confidence: Double = 0.0, val nutrition: NutritionApi? = null)
data class NutritionApi(val calories: Double = 0.0, val fat: Double = 0.0, val sugar: Double = 0.0, val salt: Double = 0.0)
data class RiskAlertApi(val message: String = "", val severity: String = "")

// === API Service ===

interface ApiService {
    @POST("/api/v1/user/intake")
    suspend fun submitIntake(@Body body: Map<String, @JvmSuppressWildcards Any>): IntakeResponse

    @GET("/api/v1/context/{userId}")
    suspend fun getContext(@Path("userId") userId: String): ContextResponse

    @Multipart
    @POST("/api/analyze")
    suspend fun analyzeAudio(
        @Part file: MultipartBody.Part,
        @Part("mode") mode: RequestBody
    ): AnalyzeResponse

    @POST("/api/recommendation")
    suspend fun getRecommendation(@Body body: Map<String, @JvmSuppressWildcards Any>): RecommendationResponse

    @POST("/api/sleep-assessment")
    suspend fun sleepAssessment(@Body body: Map<String, @JvmSuppressWildcards Any>): SleepApiResponse

    @Multipart
    @POST("/api/food-scan")
    suspend fun foodScan(@Part file: MultipartBody.Part, @Query("user_id") userId: String? = null): FoodScanApiResponse
}

// === Singleton Client ===

object ApiClient {
    // 10.0.2.2 = host localhost from Android emulator
    var baseUrl = "http://10.0.2.2:8000"

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .addInterceptor(HttpLoggingInterceptor().apply { level = HttpLoggingInterceptor.Level.BASIC })
        .build()

    val service: ApiService by lazy {
        Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(ApiService::class.java)
    }
}
