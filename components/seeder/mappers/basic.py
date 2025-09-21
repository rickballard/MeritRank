#!/usr/bin/env python3
import json, urllib.request, os
from urllib.parse import urlparse

def load_domain_hints(repo_root):
    p = os.path.join(repo_root, "config", "scoring", "domain_hints.json")
    try:
        return json.load(open(p, "r", encoding="utf-8"))
    except Exception:
        return {}

def map_event(evt, domain_hints=None, ua="CoEveSeeder/0.0.2"):
    out = dict(evt)
    u = evt.get("evidence_uri")
    if not u:
        return out

    # Domain hint override (idempotent, low-risk)
    try:
        host = urlparse(u).netloc.lower()
        if domain_hints and host in domain_hints:
            hint = domain_hints[host]
            out["impact"] = float(hint.get("impact", out.get("impact", 0.0)))
            out["severity"] = float(hint.get("severity", out.get("severity", 0.0)))
            out["confidence"] = max(float(out.get("confidence", 0.3)), float(hint.get("confidence", 0.5)))
            out["hint_applied"] = host
            return out
    except Exception:
        pass

    # Light heuristic fetch (bounded read, tolerant)
    try:
        req = urllib.request.Request(u, headers={"User-Agent": ua})
        with urllib.request.urlopen(req, timeout=10) as r:
            body = r.read(40000).decode("utf-8", "ignore")  # first 40KB only
        sig_like = ("did:" in body) or ("-----BEGIN PGP" in body) or ("c2pa" in body.lower())
        if sig_like:
            out["impact"] = max(float(out.get("impact", 0.0)), 0.2)
            out["severity"] = max(float(out.get("severity", 0.0)), 0.2)
            out["confidence"] = max(float(out.get("confidence", 0.3)), 0.6)
    except Exception:
        # Heuristic fetch is best-effort; ignore failures
        pass

    return out
