"""Sleep assessment API route."""

from fastapi import APIRouter
from pydantic import BaseModel

from sleep_recommendation import SleepAssessment, classify_and_recommend_sleep

router = APIRouter()


class SleepAssessmentInput(BaseModel):
    snoring_freq: str = "often"
    daytime_sleepiness: str = "mild"
    apnea_observed: str = "no"
    body_type: str = "normal"
    sleep_symptoms: list[str] = []


@router.post("/api/sleep-assessment")
def sleep_assessment(input: SleepAssessmentInput):
    assessment = SleepAssessment(
        snoring_freq=input.snoring_freq,
        daytime_sleepiness=input.daytime_sleepiness,
        apnea_observed=input.apnea_observed,
        body_type=input.body_type,
        sleep_symptoms=input.sleep_symptoms,
    )
    result = classify_and_recommend_sleep(assessment)
    return {
        "classification": result["classification"],
        "risk_score": result["classification"]["osa_risk"]["score"],
        "recommendations": result["recommendations"],
        "warnings": result["warnings"],
        "should_see_doctor": result["should_see_doctor"],
    }
