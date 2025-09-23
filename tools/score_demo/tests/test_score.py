from tools.score_demo.score import score
from datetime import datetime, timezone

def mk(sev, imp, conf=1.0, ts=None):
    if ts is None:
        ts = datetime.now(timezone.utc).isoformat()
    return {"severity": sev, "impact": imp, "confidence": conf, "timestamp": ts}

def test_neg_dominance():
    # Small positive set plus one severe negative -> overall score should fall below neutral (50)
    evts = [mk(0.2, 1.0) for _ in range(2)] + [mk(0.9, -1.0, 0.8)]
    r = score(evts)
    assert r["status"] == "ok"
    assert r["score"] is not None and r["score"] < 50
