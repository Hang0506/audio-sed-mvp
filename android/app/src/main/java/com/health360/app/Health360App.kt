package com.health360.app

import android.app.Application
import com.health360.app.data.CoinManager
import com.health360.app.data.FeatureGate

class Health360App : Application() {
    override fun onCreate() {
        super.onCreate()
        CoinManager.init(this)
        FeatureGate.init(this)
    }
}
