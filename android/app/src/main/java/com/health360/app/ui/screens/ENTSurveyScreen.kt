package com.health360.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
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
import com.health360.app.data.model.SymptomGroup
import com.health360.app.data.model.SymptomOption
import com.health360.app.ui.theme.DS
import com.health360.app.ui.theme.Spacing

@Composable
fun ENTSurveyScreen(onNext: () -> Unit) {
    val context = LocalContext.current
    var selected by remember { mutableStateOf(setOf<String>()) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DS.bg)
            .padding(Spacing.lg.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(Spacing.md.dp)
    ) {
        Text("SÀNG LỌC LÂM SÀNG", fontSize = 12.sp, color = DS.accentBlue, fontWeight = FontWeight.Bold)
        Text("Chỉ Số Tai-Mũi-Họng", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = DS.textPrimary)
        Spacer(Modifier.height(Spacing.sm.dp))
        Text("Chọn triệu chứng bạn gặp thường xuyên", fontSize = 14.sp, color = DS.muted)
        Text("(có thể chọn nhiều mục)", fontSize = 12.sp, color = DS.muted)

        Spacer(Modifier.height(Spacing.md.dp))

        SymptomGroup.entries.forEach { group ->
            val color = if (group == SymptomGroup.NOSE) DS.accentBlue else DS.accentPurple
            Text("${group.icon} ${group.title}", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = color)
            Spacer(Modifier.height(Spacing.sm.dp))

            SymptomOption.all.filter { it.group == group }.forEach { option ->
                val isSelected = option.id in selected
                val borderColor = if (isSelected) color else DS.border
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .border(1.dp, borderColor, RoundedCornerShape(12.dp))
                        .background(if (isSelected) color.copy(alpha = 0.08f) else DS.card)
                        .clickable { selected = if (isSelected) selected - option.id else selected + option.id }
                        .padding(Spacing.md.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = isSelected,
                        onCheckedChange = { selected = if (isSelected) selected - option.id else selected + option.id },
                        colors = CheckboxDefaults.colors(checkedColor = color, uncheckedColor = DS.border)
                    )
                    Spacer(Modifier.width(Spacing.sm.dp))
                    Column {
                        Text(option.title, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = DS.textPrimary)
                        Text(option.triggerDescription, fontSize = 11.sp, color = DS.muted)
                    }
                }
                Spacer(Modifier.height(Spacing.sm.dp))
            }
            Spacer(Modifier.height(Spacing.md.dp))
        }

        Spacer(Modifier.weight(1f))

        Button(
            onClick = {
                FeatureGate.saveSymptoms(selected, context)
                onNext()
            },
            enabled = selected.isNotEmpty(),
            modifier = Modifier.fillMaxWidth().height(52.dp),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(containerColor = DS.accentBlue)
        ) {
            Text("Phân Tích Hồ Sơ Gốc ➤", fontSize = 16.sp, fontWeight = FontWeight.Bold)
        }
    }
}
