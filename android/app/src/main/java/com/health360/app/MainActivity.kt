package com.health360.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.isSystemInDarkTheme
import com.health360.app.ui.navigation.MainNavigation
import com.health360.app.ui.theme.Health360Theme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            Health360Theme(darkTheme = true) {
                MainNavigation()
            }
        }
    }
}
