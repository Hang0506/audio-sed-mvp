"""Sleep quality assessment and recommendation engine.

Khi AI phát hiện Snoring/Breathing bất thường (không có Cough),
hệ thống chuyển sang flow khảo sát giấc ngủ — sàng lọc nguy cơ
ngưng thở khi ngủ (OSA) và gợi ý chăm sóc.

Lưu ý: Đây KHÔNG phải chẩn đoán y khoa. Chỉ là sàng lọc sơ bộ.
"""

from dataclasses import dataclass, field


@dataclass
class SleepAssessment:
    snoring_freq: str = "often"          # rarely, often, every_night
    daytime_sleepiness: str = "mild"     # none, mild, severe
    apnea_observed: str = "no"           # no, yes
    body_type: str = "normal"            # normal, overweight, obese
    sleep_symptoms: list[str] = field(default_factory=list)
    # From audio
    audio_snoring_confidence: float = 0.5
    audio_breathing_confidence: float = 0.5


def calculate_osa_risk(assessment: SleepAssessment) -> dict:
    """Tính điểm nguy cơ OSA dựa trên STOP-Bang simplified."""
    score = 0
    factors = []

    # Snoring frequency
    if assessment.snoring_freq == "every_night":
        score += 3
        factors.append("Ngáy mỗi đêm")
    elif assessment.snoring_freq == "often":
        score += 2
        factors.append("Ngáy thường xuyên")
    else:
        score += 1

    # Daytime sleepiness
    if assessment.daytime_sleepiness == "severe":
        score += 3
        factors.append("Buồn ngủ ban ngày mức độ nặng")
    elif assessment.daytime_sleepiness == "mild":
        score += 1

    # Observed apnea
    if assessment.apnea_observed == "yes":
        score += 3
        factors.append("Có ngưng thở quan sát được")

    # Body type
    if assessment.body_type == "obese":
        score += 3
        factors.append("Béo phì (BMI > 30)")
    elif assessment.body_type == "overweight":
        score += 2
        factors.append("Thừa cân")

    # Symptoms
    high_risk_symptoms = {"hypertension", "morning_headache", "concentration"}
    matched = set(assessment.sleep_symptoms) & high_risk_symptoms
    score += len(matched)
    if "hypertension" in matched:
        factors.append("Cao huyết áp")

    # Risk level
    if score >= 8:
        risk = "high"
        risk_vi = "Nguy cơ CAO"
    elif score >= 4:
        risk = "moderate"
        risk_vi = "Nguy cơ TRUNG BÌNH"
    else:
        risk = "low"
        risk_vi = "Nguy cơ THẤP"

    return {"score": score, "risk": risk, "risk_vi": risk_vi, "factors": factors}


SYMPTOM_LABELS = {
    "dry_mouth": "Khô miệng khi thức dậy",
    "morning_headache": "Đau đầu buổi sáng",
    "waking_up": "Hay tỉnh giấc giữa đêm",
    "concentration": "Khó tập trung, hay quên",
    "hypertension": "Cao huyết áp",
    "nocturia": "Tiểu đêm nhiều lần",
}


def classify_and_recommend_sleep(assessment: SleepAssessment) -> dict:
    """Phân tích giấc ngủ và đưa khuyến nghị."""
    osa_risk = calculate_osa_risk(assessment)
    recommendations = []
    warnings = []
    should_see_doctor = False

    # High risk → must see doctor
    if osa_risk["risk"] == "high":
        should_see_doctor = True
        warnings.append(
            "Điểm sàng lọc cho thấy NGUY CƠ CAO mắc hội chứng ngưng thở khi ngủ (OSA). "
            "Khuyến nghị khám chuyên khoa Hô hấp / Giấc ngủ và làm đa ký giấc ngủ (polysomnography)."
        )
        recommendations.append({
            "category": "see_doctor",
            "category_label": "Khám bác sĩ chuyên khoa",
            "category_icon": "🏥",
            "items": [
                "Đặt lịch khám chuyên khoa Giấc ngủ hoặc Hô hấp",
                "Yêu cầu làm đa ký giấc ngủ (polysomnography)",
                "Mang theo kết quả phân tích AI này khi đi khám",
            ],
            "priority": 1,
        })

    # Moderate risk
    if osa_risk["risk"] == "moderate":
        warnings.append(
            "Có một số dấu hiệu cần theo dõi. Nếu triệu chứng kéo dài, nên khám chuyên khoa."
        )
        recommendations.append({
            "category": "consult_pharmacist",
            "category_label": "Tư vấn dược sĩ / bác sĩ",
            "category_icon": "👨‍⚕️",
            "items": [
                "Tham vấn dược sĩ về sản phẩm hỗ trợ giấc ngủ",
                "Theo dõi triệu chứng 2–4 tuần, nếu không cải thiện → khám bác sĩ",
            ],
            "priority": 2,
        })

    # Lifestyle recommendations (always)
    lifestyle_items = ["Duy trì giờ ngủ cố định (đi ngủ & thức dậy cùng giờ mỗi ngày)"]
    if assessment.body_type in ("overweight", "obese"):
        lifestyle_items.append("Giảm cân — giảm 10% trọng lượng có thể cải thiện đáng kể")
    lifestyle_items.extend([
        "Tránh rượu bia ít nhất 3 giờ trước khi ngủ",
        "Nằm nghiêng thay vì nằm ngửa khi ngủ",
        "Không dùng thuốc an thần nếu chưa có chỉ định",
    ])
    recommendations.append({
        "category": "lifestyle",
        "category_label": "Thay đổi lối sống",
        "category_icon": "🏃",
        "items": lifestyle_items,
        "priority": 3,
    })

    # Sleep hygiene
    recommendations.append({
        "category": "sleep_hygiene",
        "category_label": "Vệ sinh giấc ngủ",
        "category_icon": "🛏️",
        "items": [
            "Phòng ngủ tối, mát (18–22°C), yên tĩnh",
            "Tắt điện thoại/màn hình 30 phút trước khi ngủ",
            "Tránh caffeine sau 14h",
            "Tập thể dục đều đặn nhưng không tập sát giờ ngủ",
        ],
        "priority": 4,
    })

    # Support products
    if osa_risk["risk"] != "high":
        recommendations.append({
            "category": "products",
            "category_label": "Sản phẩm hỗ trợ",
            "category_icon": "💊",
            "items": [
                "Miếng dán chống ngáy / Kẹp mũi chống ngáy",
                "Gối chống ngáy (nâng đầu 15–30°)",
                "Tinh dầu bạc hà / khuynh diệp xông phòng",
                "Melatonin liều thấp (nếu khó vào giấc)",
            ],
            "priority": 5,
        })

    # Summary
    classification = {
        "snoring_freq_vi": {"rarely": "Thỉnh thoảng", "often": "Thường xuyên", "every_night": "Mỗi đêm"}[assessment.snoring_freq],
        "sleepiness_vi": {"none": "Không buồn ngủ", "mild": "Hơi buồn ngủ", "severe": "Rất buồn ngủ ban ngày"}[assessment.daytime_sleepiness],
        "body_type_vi": {"normal": "Bình thường", "overweight": "Thừa cân", "obese": "Béo phì"}[assessment.body_type],
        "apnea_observed": assessment.apnea_observed == "yes",
        "osa_risk": osa_risk,
        "symptoms_vi": [SYMPTOM_LABELS.get(s, s) for s in assessment.sleep_symptoms],
    }

    return {
        "classification": classification,
        "recommendations": recommendations,
        "warnings": warnings,
        "should_see_doctor": should_see_doctor,
    }
