package com.health360.app.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.health360.app.data.CoinManager
import com.health360.app.data.FeatureGate
import com.health360.app.data.model.EnabledFeature
import com.health360.app.data.model.FoodScanResult
import com.health360.app.ui.components.AudioWaveView
import com.health360.app.ui.components.BadgeTag
import com.health360.app.ui.components.TaskCheckRow
import com.health360.app.ui.theme.DS
import com.health360.app.ui.theme.Spacing

private enum class TimeOfDay(val label: String) { MORNING("Sáng"), NOON("Trưa"), NIGHT("Đêm") }

@Composable
fun HomeScreen() {
    val context = LocalContext.current
    var timeOfDay by remember { mutableStateOf(TimeOfDay.MORNING) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DS.bg)
            .verticalScroll(rememberScrollState())
            .padding(Spacing.lg.dp),
        verticalArrangement = Arrangement.spacedBy(Spacing.md.dp)
    ) {
        // Gamified Header
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(modifier = Modifier.weight(1f)) {
                Text("Xin chào, Minh 👋", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = DS.textPrimary)
                BadgeTag("Viêm mũi dị ứng", DS.accentPurple)
            }
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(16.dp))
                    .background(DS.accentOrange.copy(alpha = 0.15f))
                    .padding(horizontal = 12.dp, vertical = 6.dp)
            ) {
                Text("🪙 ${CoinManager.coins}", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = DS.accentOrange)
            }
        }

        // Time of Day Picker
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(10.dp))
                .background(DS.card)
                .padding(4.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            TimeOfDay.entries.forEach { tod ->
                val isActive = timeOfDay == tod
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(8.dp))
                        .background(if (isActive) DS.accentBlue.copy(alpha = 0.2f) else DS.card)
                        .clickable { timeOfDay = tod }
                        .padding(vertical = 10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(tod.label, fontSize = 14.sp, fontWeight = if (isActive) FontWeight.Bold else FontWeight.Normal, color = if (isActive) DS.accentBlue else DS.muted)
                }
            }
        }

        // Content based on time + feature gate
        when (timeOfDay) {
            TimeOfDay.MORNING -> if (FeatureGate.isEnabled(EnabledFeature.WEATHER)) MorningWeatherCard(context) else FeatureLockedCard("Thời tiết")
            TimeOfDay.NOON -> if (FeatureGate.isEnabled(EnabledFeature.CAMERA)) NoonCameraCard() else FeatureLockedCard("Camera AI")
            TimeOfDay.NIGHT -> if (FeatureGate.isEnabled(EnabledFeature.AUDIO)) NightAudioCard(context) else FeatureLockedCard("Audio AI")
        }
    }
}

@Composable
private fun MorningWeatherCard(context: android.content.Context) {
    var taskDone by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .border(1.dp, DS.accentOrange, RoundedCornerShape(12.dp))
            .background(DS.card)
            .padding(Spacing.lg.dp),
        verticalArrangement = Arrangement.spacedBy(Spacing.sm.dp)
    ) {
        Text("🌤️ CẢNH BÁO THỜI TIẾT", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = DS.accentOrange)
        Text("Chỉ số AQI: 162 — Không tốt cho nhóm nhạy cảm", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = DS.textPrimary)
        Spacer(Modifier.height(Spacing.xs.dp))
        Text("Nguy cơ kích ứng: 85%", fontSize = 13.sp, color = DS.accentRed)
        Text("Bụi mịn PM2.5 đang ở mức CAO. Hôm nay hạn chế ra ngoài vào khung giờ 10h-14h. Đeo khẩu trang y tế nếu phải di chuyển.", fontSize = 13.sp, color = DS.muted)
    }

    TaskCheckRow(
        title = "Đeo khẩu trang khi ra ngoài",
        reward = "+50 🪙",
        isChecked = taskDone,
        onToggle = {
            if (!taskDone) {
                taskDone = true
                CoinManager.addCoins(50, context)
            }
        }
    )
}

@Composable
private fun NoonCameraCard() {
    var scanResult by remember { mutableStateOf<FoodScanResult?>(null) }

    // Scan line animation
    val infiniteTransition = rememberInfiniteTransition(label = "scanline")
    val scanOffset by infiniteTransition.animateFloat(
        initialValue = 0f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(2000, easing = LinearEasing), RepeatMode.Restart), label = "offset"
    )

    Column(verticalArrangement = Arrangement.spacedBy(Spacing.md.dp)) {
        // Viewfinder
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(DS.card)
                .border(1.dp, DS.accentBlue, RoundedCornerShape(12.dp)),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("📷", fontSize = 32.sp)
                Text("Hướng camera vào món ăn", fontSize = 13.sp, color = DS.muted)
            }
            // Scan line indicator
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(2.dp)
                    .offset(y = (180 * scanOffset - 90).dp)
                    .background(DS.accentBlue.copy(alpha = 0.6f))
            )
        }

        // Food buttons
        Row(horizontalArrangement = Arrangement.spacedBy(Spacing.sm.dp)) {
            listOf("haisan" to "🦐 Hải sản", "dalanh" to "🧊 Đá lạnh").forEach { (key, label) ->
                OutlinedButton(
                    onClick = { scanResult = FoodScanResult.entFoodDB[key] },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(10.dp),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = DS.textPrimary)
                ) { Text(label, fontSize = 13.sp) }
            }
        }

        // Result card
        scanResult?.let { result ->
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(DS.card)
                    .padding(Spacing.lg.dp),
                verticalArrangement = Arrangement.spacedBy(Spacing.sm.dp)
            ) {
                Text(result.name, fontSize = 14.sp, fontWeight = FontWeight.Bold, color = DS.textPrimary)
                Text(result.risk, fontSize = 13.sp, color = DS.accentOrange)
                Text(result.description, fontSize = 12.sp, color = DS.muted)
                Spacer(Modifier.height(Spacing.xs.dp))
                Text(result.action, fontSize = 12.sp, color = DS.accentTeal)
            }
        }
    }
}

@Composable
private fun NightAudioCard(context: android.content.Context) {
    var claimed by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .border(1.dp, DS.accentPurple, RoundedCornerShape(12.dp))
            .background(DS.card)
            .padding(Spacing.lg.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(Spacing.md.dp)
    ) {
        Text("🎙️ THEO DÕI ÂM THANH ĐÊM", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = DS.accentPurple)
        AudioWaveView(isRecording = true, modifier = Modifier.fillMaxWidth())

        // Pulse indicator
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(Spacing.sm.dp)) {
            Box(Modifier.size(8.dp).background(DS.accentRed, CircleShape))
            Text("MIC ACTIVE — Đang ghi âm giấc ngủ", fontSize = 12.sp, color = DS.muted)
        }

        Button(
            onClick = {
                if (!claimed) { claimed = true; CoinManager.addCoins(100, context) }
            },
            enabled = !claimed,
            shape = RoundedCornerShape(10.dp),
            colors = ButtonDefaults.buttonColors(containerColor = DS.accentPurple)
        ) {
            Text(if (claimed) "✅ Đã nhận +100 🪙" else "Hoàn thành đêm nay → +100 🪙", fontSize = 13.sp)
        }
    }
}

@Composable
private fun FeatureLockedCard(name: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(DS.card)
            .padding(Spacing.xl.dp),
        contentAlignment = Alignment.Center
    ) {
        Text("🔒 $name chưa được kích hoạt\n(Chọn triệu chứng liên quan trong khảo sát)", fontSize = 13.sp, color = DS.muted, textAlign = TextAlign.Center)
    }
}
