package com.health360.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.health360.app.data.FeatureGate
import com.health360.app.ui.theme.DS
import com.health360.app.ui.theme.Spacing
import kotlinx.coroutines.delay

@Composable
fun AnalysisLoadingScreen(onDone: () -> Unit) {
    val context = LocalContext.current
    var phase by remember { mutableIntStateOf(0) }

    LaunchedEffect(Unit) {
        delay(1200)
        phase = 1
        delay(1300)
        FeatureGate.setOnboardingDone(context)
        onDone()
    }

    Column(
        modifier = Modifier.fillMaxSize().background(DS.bg).padding(Spacing.xl.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        CircularProgressIndicator(color = DS.accentBlue, strokeWidth = 3.dp)
        Spacer(Modifier.height(Spacing.lg.dp))
        Text("Đang kết nối API phần cứng...", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = DS.textPrimary)
        Spacer(Modifier.height(Spacing.lg.dp))

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(DS.card)
                .padding(Spacing.lg.dp)
        ) {
            if (phase == 0) {
                Text("⏳ KHỞI TẠO...\nĐang phân tích hồ sơ triệu chứng", fontSize = 13.sp, color = DS.muted)
            } else {
                Text(
                    "✅ Phân tích hồ sơ hoàn tất\n✅ Cấu hình cảm biến AI\n✅ Kết nối dữ liệu thời tiết\n✅ Sẵn sàng theo dõi sức khỏe",
                    fontSize = 13.sp, color = DS.accentTeal
                )
            }
        }
    }
}
