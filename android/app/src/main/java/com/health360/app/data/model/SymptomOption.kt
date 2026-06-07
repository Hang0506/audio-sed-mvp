package com.health360.app.data.model

enum class SymptomGroup(val icon: String, val title: String) {
    NOSE("\uD83D\uDC43", "Nhóm Triệu Chứng MŨI (Nose)"),
    THROAT_EAR("\uD83D\uDDE3\uFE0F\uD83D\uDC42", "Nhóm TAI - HỌNG & ĐÊM (Throat & Ear)")
}

enum class EnabledFeature { WEATHER, CAMERA, AUDIO }

data class SymptomOption(
    val id: String,
    val group: SymptomGroup,
    val title: String,
    val triggerDescription: String
) {
    companion object {
        val all = listOf(
            SymptomOption("mui_hat_hoi_lanh", SymptomGroup.NOSE, "Hắt hơi liên tục khi thời tiết giao mùa", "Kích hoạt Widget Định vị & Đo chỉ số thời tiết / PM2.5"),
            SymptomOption("mui_ngat_di_ung", SymptomGroup.NOSE, "Nghẹt mũi, ngứa họng sau ăn đồ lạ, đồ lạnh", "Kích hoạt Máy Quét Camera AI phân tích dị nguyên thức ăn"),
            SymptomOption("hong_ho_khan_dem", SymptomGroup.THROAT_EAR, "Ho khan kịch phát, ngứa cổ rát họng về đêm", "Kích hoạt Audio AI Mic ghi âm, phân tích tần suất Ho nền"),
            SymptomOption("ngu_ngay_tho_mieng", SymptomGroup.THROAT_EAR, "Ngủ ngáy, thở bằng miệng, ù khò khè", "Kích hoạt Cảm biến âm thanh đo Oxy và tiếng thở ngáy ngủ")
        )
    }
}

data class FoodScanResult(
    val name: String,
    val risk: String,
    val description: String,
    val action: String
) {
    companion object {
        val entFoodDB = mapOf(
            "haisan" to FoodScanResult("MÓN ĂN: LẨU HẢI SẢN (92%)", "⚠️ Nguy cơ kích ứng: NHÓM TRIỆU CHỨNG MŨI", "Thực phẩm chứa Histamine tự do. Theo khảo sát bạn dễ ngứa họng và ngạt mũi sau ăn, món ăn này sẽ tăng nguy cơ sung huyết niêm mạc xoang.", "💡 Khuyên dùng: Sử dụng nước lọc ấm sau ăn. Hãy dùng bình xịt rửa mũi trước khi đi ngủ tối nay."),
            "dalanh" to FoodScanResult("ĐỒ UỐNG: NƯỚC ĐÁ LẠNH (96%)", "⚠️ Nguy cơ kích ứng: NHÓM HO / RÁT HỌNG ĐÊM", "Nhiệt độ thấp làm co mao mạch hầu họng đột ngột, kích hoạt cơn ho rát kịch phát vào ban đêm.", "💡 Khuyên dùng: Giữ ấm vùng cổ họng. Ngậm một ngụm nước ấm ngay lập tức.")
        )
    }
}

data class Voucher(val name: String, val description: String, val cost: Int) {
    companion object {
        val all = listOf(
            Voucher("🎟️ Voucher 50K Xịt Mũi Sinufresh", "Voucher đổi bằng xu tích luỹ từ hành động bảo vệ hệ hô hấp.", 500),
            Voucher("🎟️ Voucher 30K Khẩu Trang Y Tế", "Khẩu trang lọc bụi PM2.5 cho ngày AQI cao.", 300),
            Voucher("🎟️ Voucher 100K Khám TMH", "Giảm giá khám chuyên khoa Tai Mũi Họng.", 1000)
        )
    }
}
