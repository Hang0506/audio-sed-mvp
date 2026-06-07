package com.health360.app.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.navigation.compose.*
import com.health360.app.data.FeatureGate
import com.health360.app.ui.screens.*
import com.health360.app.ui.theme.DS

private enum class Tab(val label: String, val icon: ImageVector, val route: String) {
    HOME("Trang chủ", Icons.Default.Home, "home"),
    REVIEW("Tổng kết", Icons.Default.DateRange, "weekly_review"),
    MARKET("Đổi thưởng", Icons.Default.Star, "marketplace")
}

@Composable
fun MainNavigation() {
    val context = LocalContext.current
    val navController = rememberNavController()
    val startDest = if (FeatureGate.hasCompletedOnboarding(context)) "home" else "survey"
    var selectedTab by remember { mutableStateOf(Tab.HOME) }
    val navBackStack by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStack?.destination?.route
    val showBottomBar = currentRoute in listOf("home", "weekly_review", "marketplace")

    Scaffold(
        containerColor = DS.bg,
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(containerColor = DS.card, tonalElevation = 0.dp) {
                    Tab.entries.forEach { tab ->
                        NavigationBarItem(
                            selected = selectedTab == tab,
                            onClick = {
                                selectedTab = tab
                                navController.navigate(tab.route) {
                                    popUpTo("home") { saveState = true }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            icon = { Icon(tab.icon, contentDescription = tab.label) },
                            label = { Text(tab.label) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = DS.accentBlue,
                                selectedTextColor = DS.accentBlue,
                                unselectedIconColor = DS.muted,
                                unselectedTextColor = DS.muted,
                                indicatorColor = DS.accentBlue.copy(alpha = 0.1f)
                            )
                        )
                    }
                }
            }
        }
    ) { padding ->
        NavHost(navController, startDestination = startDest, modifier = Modifier.padding(padding)) {
            composable("survey") {
                ENTSurveyScreen(onNext = { navController.navigate("loading") { popUpTo("survey") { inclusive = true } } })
            }
            composable("loading") {
                AnalysisLoadingScreen(onDone = { navController.navigate("home") { popUpTo("loading") { inclusive = true } } })
            }
            composable("home") { HomeScreen() }
            composable("weekly_review") { WeeklyReviewScreen() }
            composable("marketplace") { MarketplaceScreen() }
        }
    }
}
