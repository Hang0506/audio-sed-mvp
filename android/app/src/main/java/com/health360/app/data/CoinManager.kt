package com.health360.app.data

import android.content.Context
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue

object CoinManager {
    private const val PREF_KEY = "masterCoins"
    var coins by mutableIntStateOf(750)
        private set

    fun init(context: Context) {
        val prefs = context.getSharedPreferences("health360", Context.MODE_PRIVATE)
        coins = prefs.getInt(PREF_KEY, 750)
    }

    fun addCoins(amount: Int, context: Context) {
        coins += amount
        save(context)
    }

    fun spendCoins(amount: Int, context: Context): Boolean {
        if (coins < amount) return false
        coins -= amount
        save(context)
        return true
    }

    private fun save(context: Context) {
        context.getSharedPreferences("health360", Context.MODE_PRIVATE).edit().putInt(PREF_KEY, coins).apply()
    }
}
