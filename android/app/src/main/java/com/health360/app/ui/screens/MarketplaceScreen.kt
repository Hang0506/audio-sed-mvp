package com.health360.app.ui.screens

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.health360.app.data.CoinManager
import com.health360.app.data.model.Voucher
import com.health360.app.ui.theme.DS
import com.health360.app.ui.theme.Spacing

@Composable
fun MarketplaceScreen() {
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DS.bg)
            .padding(Spacing.lg.dp),
        verticalArrangement = Arrangement.spacedBy(Spacing.md.dp)
    ) {
        Text("🎁 Trung Tâm Đổi Thưởng", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = DS.textPrimary)
        Text("Số xu hiện tại: 🪙 ${CoinManager.coins}", fontSize = 14.sp, color = DS.accentOrange)

        Spacer(Modifier.height(Spacing.sm.dp))

        Voucher.all.forEach { voucher ->
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(DS.card)
                    .padding(Spacing.lg.dp),
                verticalArrangement = Arrangement.spacedBy(Spacing.sm.dp)
            ) {
                Text(voucher.name, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = DS.textPrimary)
                Text(voucher.description, fontSize = 12.sp, color = DS.muted)
                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                    Text("${voucher.cost} 🪙", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = DS.accentOrange)
                    Button(
                        onClick = {
                            val success = CoinManager.spendCoins(voucher.cost, context)
                            Toast.makeText(context, if (success) "✅ Đổi thành công!" else "❌ Không đủ xu", Toast.LENGTH_SHORT).show()
                        },
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
                        shape = RoundedCornerShape(8.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = DS.accentBlue)
                    ) { Text("ĐỔI VOUCHER NGAY", fontSize = 11.sp, fontWeight = FontWeight.Bold) }
                }
            }
        }
    }
}
