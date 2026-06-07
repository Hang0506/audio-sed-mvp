package com.health360.app.data

import android.content.Context
import com.health360.app.data.model.EnabledFeature

object FeatureGate {
    private const val PREF_KEY = "selectedSymptomIDs"
    private var symptomIDs = setOf<String>()

    fun init(context: Context) {
        val stored = context.getSharedPreferences("health360", Context.MODE_PRIVATE).getString(PREF_KEY, "") ?: ""
        symptomIDs = stored.split(",").filter { it.isNotBlank() }.toSet()
    }

    fun saveSymptoms(ids: Set<String>, context: Context) {
        symptomIDs = ids
        context.getSharedPreferences("health360", Context.MODE_PRIVATE).edit().putString(PREF_KEY, ids.joinToString(",")).apply()
    }

    fun isEnabled(feature: EnabledFeature): Boolean = when (feature) {
        EnabledFeature.WEATHER -> "mui_hat_hoi_lanh" in symptomIDs
        EnabledFeature.CAMERA -> "mui_ngat_di_ung" in symptomIDs
        EnabledFeature.AUDIO -> "hong_ho_khan_dem" in symptomIDs || "ngu_ngay_tho_mieng" in symptomIDs
    }

    fun hasCompletedOnboarding(context: Context): Boolean =
        context.getSharedPreferences("health360", Context.MODE_PRIVATE).getBoolean("onboarding_done", false)

    fun setOnboardingDone(context: Context) {
        context.getSharedPreferences("health360", Context.MODE_PRIVATE).edit().putBoolean("onboarding_done", true).apply()
    }
}
