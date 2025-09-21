#!/usr/bin/env python3
import argparse, json, math, os
from datetime import datetime, timezone

DEFAULTS = {"negative_dominance": 4.0, "decay_half_life_days": 90, "min_events_for_score": 1}

def load_constants():
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))  # repo root
    p = os.path.join(root, "config", "scoring", "constants.json")
    try:
        return {**DEFAULTS, **json.load(open(p, "r", encoding="utf-8"))}
    except Exception:
        return DEFAULTS

def parse_ts(s):
    return datetime.fromisoformat(s.replace("Z","+00:00")).astimezone(timezone.utc)

def decay(ts, half_days):
    dt = (datetime.now(timezone.utc)-ts).total_seconds()/86400.0
    return 0.5**(max(0.0, dt)/float(half_days))

def score(events):
    C = load_constants()
    pos = 0.0; neg = 0.0
    n   = len(events)

    for e in events:
        ts  = parse_ts(e.get("timestamp")) if e.get("timestamp") else datetime.now(timezone.utc)
        w   = decay(ts, C["decay_half_life_days"]) * float(e.get("confidence", 0.5))
        imp = float(e.get("impact", 0.0))
        sev = float(e.get("severity", 0.0))
        if sev >= 0.7 and imp < 0:
            neg += C["negative_dominance"] * abs(imp) * w
        else:
            pos += imp * w

    if n < int(C["min_events_for_score"]) or (pos == 0.0 and neg == 0.0):
        return {"score": None, "status": "insufficient_evidence", "n_events": n}

    s = max(0.0, 100.0 * (1/(1+math.exp(-(pos - neg)))))
    return {"score": s, "status": "ok", "components": {"pos": pos, "neg": neg}, "n_events": n}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in",  dest="inp",  required=True)
    ap.add_argument("--out", dest="out",  required=True)
    a = ap.parse_args()
    evts = [json.loads(l) for l in open(a.inp, encoding="utf-8") if l.strip()]
    json.dump(score(evts), open(a.out, "w", encoding="utf-8"), indent=2)
    print("[OK]", a.out)

if __name__ == "__main__":
    main()
