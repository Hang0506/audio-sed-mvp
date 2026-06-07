package com.health360.app.ui.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DarkColorScheme = darkColorScheme(
    primary = DS.accentBlue,
    secondary = DS.accentTeal,
    tertiary = DS.accentPurple,
    background = DS.bg,
    surface = DS.card,
    onPrimary = Color.White,
    onBackground = DS.textPrimary,
    onSurface = DS.textPrimary,
    error = DS.accentRed
)

@Composable
fun Health360Theme(darkTheme: Boolean = true, content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        content = content
    )
}
