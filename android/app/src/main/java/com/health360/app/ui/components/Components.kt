package com.health360.app.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.health360.app.ui.theme.DS
import com.health360.app.ui.theme.Spacing
import kotlin.math.min

@Composable
fun CircularGauge(value: Double, maxValue: Double, unit: String, statusColor: Color, modifier: Modifier = Modifier) {
    val progress = (value / maxValue).coerceIn(0.0, 1.0).toFloat()
    Box(modifier = modifier.size(160.dp), contentAlignment = Alignment.Center) {
        Canvas(modifier = Modifier.fillMaxSize().padding(12.dp)) {
            val stroke = Stroke(width = 10.dp.toPx(), cap = StrokeCap.Round)
            drawArc(DS.border, 0f, 360f, false, style = stroke)
            drawArc(statusColor, -90f, 360f * progress, false, style = stroke)
        }
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("${value.toInt()}", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = DS.textPrimary)
            Text(unit, fontSize = 12.sp, color = DS.muted)
        }
    }
}

@Composable
fun ContextTile(icon: String, value: String, label: String, borderColor: Color? = null) {
    val shape = RoundedCornerShape(10.dp)
    Column(
        modifier = Modifier
            .clip(shape)
            .background(DS.card)
            .then(if (borderColor != null) Modifier.background(borderColor.copy(alpha = 0.1f)) else Modifier)
            .padding(Spacing.md.dp)
            .width(IntrinsicSize.Min),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(Spacing.sm.dp)
    ) {
        Text(icon, fontSize = 20.sp)
        Text(value, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = DS.textPrimary)
        Text(label, fontSize = 12.sp, color = DS.muted)
    }
}

@Composable
fun AlertCard(message: String, color: Color, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(DS.card)
            .padding(Spacing.md.dp),
        horizontalArrangement = Arrangement.spacedBy(Spacing.md.dp)
    ) {
        Box(Modifier.width(4.dp).height(48.dp).background(color, RoundedCornerShape(2.dp)))
        Text(message, fontSize = 14.sp, color = DS.muted, modifier = Modifier.weight(1f))
    }
}

@Composable
fun BadgeTag(text: String, color: Color = DS.accentBlue) {
    Text(
        text, fontSize = 12.sp, color = DS.textPrimary,
        modifier = Modifier
            .background(color.copy(alpha = 0.2f), RoundedCornerShape(12.dp))
            .padding(horizontal = Spacing.sm.dp, vertical = Spacing.xs.dp)
    )
}

@Composable
fun TaskCheckRow(title: String, reward: String, isChecked: Boolean, onToggle: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(10.dp))
            .background(DS.card)
            .clickable(onClick = onToggle)
            .padding(Spacing.md.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(Spacing.md.dp)
    ) {
        Checkbox(checked = isChecked, onCheckedChange = { onToggle() }, colors = CheckboxDefaults.colors(checkedColor = DS.accentTeal))
        Text(
            title, fontSize = 14.sp, color = DS.textPrimary,
            textDecoration = if (isChecked) TextDecoration.LineThrough else null,
            modifier = Modifier.weight(1f)
        )
        Text(reward, fontSize = 12.sp, color = DS.accentOrange)
    }
}

@Composable
fun AudioWaveView(isRecording: Boolean, modifier: Modifier = Modifier) {
    val infiniteTransition = rememberInfiniteTransition(label = "wave")
    val heights = (0..4).map { i ->
        infiniteTransition.animateFloat(
            initialValue = if (isRecording) 0.3f else 0.25f,
            targetValue = if (isRecording) 1f else 0.4f,
            animationSpec = infiniteRepeatable(
                animation = tween(300 + i * 80, easing = FastOutSlowInEasing),
                repeatMode = RepeatMode.Reverse
            ), label = "bar$i"
        )
    }
    Row(modifier = modifier.height(60.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        heights.forEach { h ->
            Box(Modifier.width(8.dp).fillMaxHeight(h.value).background(DS.accentPurple, RoundedCornerShape(4.dp)))
        }
    }
}
