"""Rule engine — evaluates user profile + context data against configurable rules."""

import json
from pathlib import Path

_RULES_PATH = Path(__file__).parent.parent / "config" / "rules.json"
_config: dict | None = None


def _load_config() -> dict:
    global _config
    if _config is None:
        _config = json.loads(_RULES_PATH.read_text(encoding="utf-8"))
    return _config


OPERATORS = {
    "gt": lambda a, b: a > b,
    "lt": lambda a, b: a < b,
    "gte": lambda a, b: a >= b,
    "lte": lambda a, b: a <= b,
    "eq": lambda a, b: a == b,
    "contains": lambda a, b: b in a if isinstance(a, (list, str)) else False,
}


def _check_condition(condition: dict, user_profile: dict, context_data: dict) -> bool:
    field = condition["field"]
    operator = condition["operator"]
    value = condition["value"]
    # Resolve field value from user_profile first, then context_data
    actual = user_profile.get(field, context_data.get(field))
    if actual is None:
        return False
    return OPERATORS[operator](actual, value)


def evaluate_rules(user_profile: dict, context_data: dict) -> list[dict]:
    """Evaluate all rules against user profile + context. Returns triggered alerts."""
    config = _load_config()
    templates = config["alert_templates"]
    triggered = []

    for rule in config["rules"]:
        if all(_check_condition(c, user_profile, context_data) for c in rule["conditions"]):
            tmpl = templates[rule["template_id"]]
            triggered.append({
                "rule_id": rule["id"],
                "template_id": rule["template_id"],
                "title": tmpl["title"],
                "body": tmpl["body"],
                "deeplink": tmpl["deeplink"],
                "priority": rule["priority"],
            })

    return sorted(triggered, key=lambda x: x["priority"])
