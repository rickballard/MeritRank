from tools.score_demo.score import score, load_constants
from datetime import datetime, timezone

def mk(sev, imp, conf=1.0, ts=None):
    if ts is None:
        ts = datetime.now(timezone.utc).isoformat()
    return {"severity": sev, "impact": imp, "confidence": conf, "timestamp": ts}

def test_insufficient_when_no_signal():
    assert score([])["status"] == "insufficient_evidence"

def test_negative_dominance_affects_score():
    # A severe negative should pull the logistic score under 50 even with a few positives.
    evts = [mk(0.2, 1.0, 1.0) for _ in range(3)] + [mk(0.9, -1.0, 0.8)]
    r = score(evts)
    assert r["status"] == "ok" and r["score"] < 50

def test_constants_load():
    C = load_constants()
    assert "negative_dominance" in C and "decay_half_life_days" in C
