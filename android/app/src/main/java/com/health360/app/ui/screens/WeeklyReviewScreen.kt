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
import com.health360.app.data.CoinManager
import com.health360.app.ui.theme.DS
import com.health360.app.ui.theme.Spacing

@Composable
fun WeeklyReviewScreen() {
    val context = LocalContext.current
    var claimed by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DS.bg)
            .padding(Spacing.lg.dp),
        verticalArrangement = Arrangement.spacedBy(Spacing.lg.dp)
    ) {
        Text("📊 Tổng Kết Tuần", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = DS.textPrimary)

        // Comparison rows
        ComparisonRow("CƠN HO KHAN", "6 lần/đêm", "1 lần/đêm", DS.accentRed, DS.accentTeal)
        ComparisonRow("TIẾNG THỞ NGÁY", "42 phút", "12 phút", DS.accentOrange, DS.accentTeal)

        Spacer(Modifier.height(Spacing.md.dp))

        // Weekly bonus card
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(DS.card)
                .padding(Spacing.xl.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(Spacing.md.dp)
        ) {
            Text("THƯỞNG TUẦN", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = DS.muted)
            Text("🪙 +450 COINS", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = DS.accentOrange)
            Text("Bạn đã hoàn thành 12/14 nhiệm vụ sức khỏe", fontSize = 13.sp, color = DS.muted)

            Button(
                onClick = { if (!claimed) { claimed = true; CoinManager.addCoins(450, context) } },
                enabled = !claimed,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(10.dp),
                colors = ButtonDefaults.buttonColors(containerColor = DS.accentOrange)
            ) { Text(if (claimed) "✅ Đã nhận" else "NHẬN THƯỞNG", fontSize = 14.sp, fontWeight = FontWeight.Bold) }
        }
    }
}

@Composable
private fun ComparisonRow(label: String, before: String, after: String, fromColor: androidx.compose.ui.graphics.Color, toColor: androidx.compose.ui.graphics.Color) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(DS.card)
            .padding(Spacing.lg.dp),
        verticalArrangement = Arrangement.spacedBy(Spacing.sm.dp)
    ) {
        Text(label, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = DS.muted)
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(Spacing.sm.dp)) {
            Text(before, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = fromColor)
            Text("→", fontSize = 16.sp, color = DS.muted)
            Text(after, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = toColor)
        }
    }
}
