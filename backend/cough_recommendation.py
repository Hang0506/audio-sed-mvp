"""Cough classification and product/health recommendation engine.

Logic:
- Audio analysis detects cough presence, frequency, intensity
- User provides additional context (cough type, duration, age group, symptoms)
- Engine combines both to classify and recommend appropriate actions/products
"""

from dataclasses import dataclass, field

# --- Cough Types ---
COUGH_TYPES = {
    "dry": "Ho khan",
    "phlegm": "Ho có đờm",
    "whooping": "Ho gà",
    "irritant": "Ho kích ứng",
    "allergic": "Ho dị ứng",
}

# --- Duration Categories ---
DURATION_CATEGORIES = {
    "acute": {"label": "Cấp tính", "desc": "< 3 tuần"},
    "subacute": {"label": "Bán cấp", "desc": "3–8 tuần"},
    "chronic": {"label": "Mạn tính", "desc": "> 8 tuần"},
}

# --- Subject Groups ---
SUBJECT_GROUPS = {
    "infant": "Trẻ < 2 tuổi",
    "child": "Trẻ em (2–12 tuổi)",
    "pregnant": "Phụ nữ mang thai",
    "elderly": "Người cao tuổi",
    "chronic_disease": "Người có bệnh nền",
    "adult": "Người lớn",
}

# --- Red Flags (always recommend doctor) ---
RED_FLAGS = [
    "bloody_cough",       # Ho ra máu
    "difficulty_breathing",  # Khó thở
    "prolonged_fever",    # Sốt cao kéo dài
    "chest_pain",         # Đau ngực
    "cyanosis",           # Tím tái
    "weight_loss",        # Sụt cân
    "prolonged_cough",    # Ho kéo dài > 3 tuần
]

RED_FLAG_LABELS = {
    "bloody_cough": "Ho ra máu",
    "difficulty_breathing": "Khó thở",
    "prolonged_fever": "Sốt cao kéo dài",
    "chest_pain": "Đau ngực",
    "cyanosis": "Tím tái",
    "weight_loss": "Sụt cân",
    "prolonged_cough": "Ho kéo dài nhiều tuần",
}

# --- Recommendation Categories ---
RECOMMENDATION_CATEGORIES = {
    "home_care": {
        "label": "Chăm sóc tại nhà",
        "icon": "🏠",
        "desc": "Uống đủ nước, nghỉ ngơi, giữ ấm, vệ sinh mũi họng",
    },
    "food_support": {
        "label": "Thực phẩm hỗ trợ",
        "icon": "🍯",
        "desc": "Mật ong, chanh, gừng, thực phẩm mềm, dễ tiêu",
    },
    "supplement": {
        "label": "Thực phẩm bảo vệ sức khỏe (TPCN)",
        "icon": "💊",
        "desc": "Sản phẩm hỗ trợ hô hấp, tăng đề kháng",
    },
    "otc": {
        "label": "Thuốc không kê đơn (OTC)",
        "icon": "💉",
        "desc": "Phù hợp với triệu chứng và độ tuổi",
    },
    "consult_pharmacist": {
        "label": "Khuyến nghị gặp dược sĩ",
        "icon": "👨‍⚕️",
        "desc": "Cần được đánh giá thêm trước khi dùng thuốc",
    },
    "see_doctor": {
        "label": "Khuyến nghị khám bác sĩ",
        "icon": "🏥",
        "desc": "Có dấu hiệu cảnh báo hoặc kéo dài",
    },
}


# --- Product Recommendations by Cough Type ---
RECOMMENDATIONS_BY_TYPE = {
    "dry": {
        "otc": ["Viên ngậm họng", "Xịt họng", "Thuốc giảm ho (dextromethorphan)"],
        "food_support": ["Trà gừng mật ong", "Nước ấm chanh mật ong"],
        "supplement": ["Viên ngậm thảo dược", "TPCN hỗ trợ hô hấp"],
        "home_care": ["Uống nhiều nước ấm", "Giữ ẩm không khí", "Tránh khói bụi"],
        "device": ["Máy tạo độ ẩm"],
    },
    "phlegm": {
        "otc": ["Thuốc long đờm (acetylcysteine, bromhexine)", "Thuốc tiêu đờm"],
        "food_support": ["Nước ấm", "Thực phẩm loãng dễ tiêu", "Súp gà"],
        "supplement": ["TPCN hỗ trợ hô hấp", "Tinh dầu bạc hà xông"],
        "home_care": ["Uống nhiều nước", "Xông hơi", "Nằm cao đầu khi ngủ"],
    },
    "allergic": {
        "otc": ["Thuốc chống dị ứng (loratadine, cetirizine)"],
        "supplement": ["Vitamin C", "TPCN tăng đề kháng"],
        "food_support": ["Thực phẩm giàu vitamin C", "Mật ong địa phương"],
        "home_care": ["Tránh tác nhân gây dị ứng", "Vệ sinh nhà cửa"],
        "device": ["Máy lọc không khí"],
    },
    "irritant": {
        "otc": ["Viên ngậm họng", "Nước súc họng", "Xịt họng"],
        "food_support": ["Trà thảo mộc", "Mật ong ấm"],
        "home_care": ["Tránh khói bụi", "Giữ ẩm không khí", "Nghỉ giọng"],
        "device": ["Máy tạo độ ẩm"],
    },
    "whooping": {
        "see_doctor": True,
        "home_care": ["Nghỉ ngơi", "Uống nhiều nước", "Ăn ít một"],
    },
}

# --- Night cough additions ---
NIGHT_COUGH_ADDITIONS = {
    "otc": ["Thuốc giảm ho ban đêm"],
    "food_support": ["Trà thảo mộc trước ngủ", "Mật ong ấm"],
    "home_care": ["Nằm cao đầu", "Giữ ẩm phòng ngủ"],
    "device": ["Máy tạo độ ẩm"],
}

# --- Post-flu cough additions ---
POST_FLU_ADDITIONS = {
    "supplement": ["Vitamin C", "Kẽm", "TPCN phục hồi hô hấp"],
    "food_support": ["Bữa ăn giàu protein", "Súp gà", "Cháo dinh dưỡng"],
    "home_care": ["Nghỉ ngơi đủ", "Tập thở nhẹ nhàng"],
}


@dataclass
class CoughAssessment:
    """User-provided context for cough classification."""
    cough_type: str = "dry"           # dry, phlegm, allergic, irritant, whooping
    duration: str = "acute"           # acute, subacute, chronic
    subject: str = "adult"            # infant, child, pregnant, elderly, chronic_disease, adult
    red_flags: list[str] = field(default_factory=list)
    night_cough: bool = False
    post_flu: bool = False
    cough_frequency: str = "moderate"  # mild, moderate, severe


@dataclass
class Recommendation:
    """A single recommendation item."""
    category: str       # key from RECOMMENDATION_CATEGORIES
    items: list[str]
    priority: int       # 1=highest


def classify_and_recommend(
    assessment: CoughAssessment,
    audio_has_cough: bool = True,
    audio_cough_count: int = 1,
    audio_confidence: float = 0.5,
) -> dict:
    """
    Classify cough and generate recommendations.
    
    Returns dict with:
    - classification: cough type, duration, severity info
    - recommendations: ordered list of recommendation groups
    - warnings: any red flags or urgent notices
    - should_see_doctor: bool
    """
    recommendations: list[Recommendation] = []
    warnings: list[str] = []
    should_see_doctor = False

    # --- Check Red Flags FIRST ---
    if assessment.red_flags:
        should_see_doctor = True
        flag_labels = [RED_FLAG_LABELS.get(f, f) for f in assessment.red_flags]
        warnings.append(f"Phát hiện dấu hiệu cảnh báo: {', '.join(flag_labels)}")
        recommendations.append(Recommendation(
            category="see_doctor",
            items=["Khuyến nghị khám bác sĩ ngay — không tự ý dùng thuốc"],
            priority=1,
        ))

    # --- Check high-risk subjects ---
    if assessment.subject in ("infant", "pregnant"):
        should_see_doctor = True
        label = SUBJECT_GROUPS[assessment.subject]
        warnings.append(f"Đối tượng đặc biệt ({label}) — cần tư vấn chuyên môn")
        recommendations.append(Recommendation(
            category="consult_pharmacist",
            items=[f"Gặp dược sĩ/bác sĩ trước khi dùng bất kỳ thuốc nào cho {label}"],
            priority=1,
        ))

    # --- Check chronic duration ---
    if assessment.duration == "chronic":
        should_see_doctor = True
        warnings.append("Ho mạn tính (> 8 tuần) — cần khám để loại trừ nguyên nhân nghiêm trọng")
        recommendations.append(Recommendation(
            category="see_doctor",
            items=["Khám bác sĩ để xác định nguyên nhân ho kéo dài"],
            priority=1,
        ))

    # --- If should see doctor, still add supportive care ---
    if should_see_doctor:
        recommendations.append(Recommendation(
            category="home_care",
            items=["Uống đủ nước ấm", "Nghỉ ngơi", "Theo dõi triệu chứng"],
            priority=3,
        ))
    else:
        # --- Normal recommendation flow by cough type ---
        type_recs = RECOMMENDATIONS_BY_TYPE.get(assessment.cough_type, RECOMMENDATIONS_BY_TYPE["dry"])

        if type_recs.get("see_doctor"):
            should_see_doctor = True
            recommendations.append(Recommendation(
                category="see_doctor",
                items=["Ho gà cần được bác sĩ đánh giá và điều trị"],
                priority=1,
            ))

        # Home care (always)
        home_items = type_recs.get("home_care", [])
        recommendations.append(Recommendation(category="home_care", items=home_items, priority=2))

        # Food support
        food_items = type_recs.get("food_support", [])
        recommendations.append(Recommendation(category="food_support", items=food_items, priority=3))

        # Supplements (for subacute or recurring)
        if assessment.duration in ("subacute", "chronic") or assessment.cough_frequency == "severe":
            supp_items = type_recs.get("supplement", [])
            if supp_items:
                recommendations.append(Recommendation(category="supplement", items=supp_items, priority=4))

        # OTC (only for adults, not pregnant, acute/moderate+)
        if assessment.subject in ("adult", "elderly") and assessment.cough_frequency in ("moderate", "severe"):
            otc_items = type_recs.get("otc", [])
            if otc_items:
                recommendations.append(Recommendation(category="otc", items=otc_items, priority=5))
            # Devices
            device_items = type_recs.get("device", [])
            if device_items:
                recommendations.append(Recommendation(category="otc", items=device_items, priority=6))

        # Night cough additions
        if assessment.night_cough:
            nc = NIGHT_COUGH_ADDITIONS
            recommendations.append(Recommendation(category="otc", items=nc.get("otc", []), priority=5))
            recommendations.append(Recommendation(category="home_care", items=nc.get("home_care", []), priority=2))

        # Post-flu additions
        if assessment.post_flu:
            pf = POST_FLU_ADDITIONS
            recommendations.append(Recommendation(category="supplement", items=pf.get("supplement", []), priority=4))
            recommendations.append(Recommendation(category="food_support", items=pf.get("food_support", []), priority=3))

        # Pharmacist consult for child/elderly
        if assessment.subject in ("child", "elderly", "chronic_disease"):
            recommendations.append(Recommendation(
                category="consult_pharmacist",
                items=[f"Tư vấn dược sĩ về liều lượng phù hợp cho {SUBJECT_GROUPS[assessment.subject]}"],
                priority=4,
            ))

    # --- Build classification summary ---
    severity = "nhẹ"
    if audio_cough_count >= 5 or assessment.cough_frequency == "severe":
        severity = "nặng"
    elif audio_cough_count >= 2 or assessment.cough_frequency == "moderate":
        severity = "trung bình"

    classification = {
        "cough_type": assessment.cough_type,
        "cough_type_vi": COUGH_TYPES.get(assessment.cough_type, assessment.cough_type),
        "duration": assessment.duration,
        "duration_vi": DURATION_CATEGORIES.get(assessment.duration, {}).get("label", assessment.duration),
        "duration_desc": DURATION_CATEGORIES.get(assessment.duration, {}).get("desc", ""),
        "subject": assessment.subject,
        "subject_vi": SUBJECT_GROUPS.get(assessment.subject, assessment.subject),
        "severity": severity,
        "audio_cough_count": audio_cough_count,
        "audio_confidence": round(audio_confidence, 2),
    }

    # --- Deduplicate and sort recommendations ---
    merged = _merge_recommendations(recommendations)

    return {
        "classification": classification,
        "recommendations": [
            {
                "category": r.category,
                "category_label": RECOMMENDATION_CATEGORIES.get(r.category, {}).get("label", r.category),
                "category_icon": RECOMMENDATION_CATEGORIES.get(r.category, {}).get("icon", ""),
                "items": r.items,
                "priority": r.priority,
            }
            for r in merged
        ],
        "warnings": warnings,
        "should_see_doctor": should_see_doctor,
    }


def _merge_recommendations(recs: list[Recommendation]) -> list[Recommendation]:
    """Merge recommendations of same category, deduplicate items."""
    by_cat: dict[str, Recommendation] = {}
    for r in recs:
        if not r.items:
            continue
        if r.category in by_cat:
            existing = by_cat[r.category]
            for item in r.items:
                if item not in existing.items:
                    existing.items.append(item)
            existing.priority = min(existing.priority, r.priority)
        else:
            by_cat[r.category] = Recommendation(
                category=r.category, items=list(r.items), priority=r.priority
            )
    return sorted(by_cat.values(), key=lambda x: x.priority)
