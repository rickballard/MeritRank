#!/usr/bin/env python3
import argparse, json, hashlib, urllib.request, urllib.robotparser, time, os, sys
from datetime import datetime, timezone
from urllib.parse import urlparse

def load_policy(here):
    p = os.path.join(here, "config", "policy.json")
    try:
        return json.load(open(p, "r", encoding="utf-8"))
    except Exception:
        return {"user_agent":"CoEveSeeder/0.0.2","min_delay_ms":1500,"timeout_s":20}

def allowed(url, ua):
    rp = urllib.robotparser.RobotFileParser()
    parts = urlparse(url)
    robots = f"{parts.scheme}://{parts.netloc}/robots.txt"
    try:
      rp.set_url(robots); rp.read()
      return rp.can_fetch(ua, url)
    except Exception:
      return True  # permissive on robots errors

def load_hints(here):
    p = os.path.join(here, "config", "domain_hints.json")
    try:
        return json.load(open(p, "r", encoding="utf-8"))
    except Exception:
        return {"default":{"default_confidence":0.30,"hint_confidence":0.10,"hint_impact":0.20,"hint_severity":0.20}}

def text_sniff(b):
    try:
        t = b.decode("utf-8", errors="ignore").lower()
    except Exception:
        return False
    markers = ("did:", "-----begin pgp public key block-----", "c2pa")
    return any(m in t for m in markers)

def clamp01(x):
    try:
        return max(0.0, min(1.0, float(x)))
    except Exception:
        return 0.0

def map_basic(url, data, hints):
    host = urlparse(url).netloc.lower()
    host = host.split(":")[0]
    # strip subdomains (e.g., www.iana.org -> iana.org) for the hint key
    parts = host.split(".")
    key = ".".join(parts[-2:]) if len(parts) >= 2 else host

    default = hints.get("default", {})
    h = {**default, **hints.get(key, {})}

    confidence = float(h.get("default_confidence", 0.30))
    impact = 0.0
    severity = 0.0

    if text_sniff(data):
        confidence = clamp01(confidence + float(h.get("hint_confidence", 0.10)))
        impact = clamp01(h.get("hint_impact", 0.20))
        severity = clamp01(h.get("hint_severity", 0.20))

    return impact, severity, confidence, {"hint_domain": key}

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--allowlist", default="components/seeder/config/allowlist.txt")
    ap.add_argument("--out",       default="components/seeder/out/events.ndjson")
    ap.add_argument("--mapper",    default="none", choices=["none","basic"], help="optional event enricher")
    a=ap.parse_args()

    here = os.path.abspath(os.path.join(os.path.dirname(__file__)))
    policy = load_policy(here)
    hints  = load_hints(here)

    ua     = policy.get("user_agent","CoEveSeeder/0.0.2")
    delay  = float(policy.get("min_delay_ms",1500))/1000.0
    timeout= int(policy.get("timeout_s",20))

    urls=[l.strip() for l in open(a.allowlist,encoding="utf-8") if l.strip() and not l.startswith("#")]
    os.makedirs(os.path.dirname(a.out), exist_ok=True)

    opener = urllib.request.build_opener()
    opener.addheaders = [("User-Agent", ua)]
    urllib.request.install_opener(opener)

    with open(a.out,"w",encoding="utf-8") as out:
      for i,u in enumerate(urls):
        if not allowed(u, ua):
            continue
        try:
          with urllib.request.urlopen(urllib.request.Request(u), timeout=timeout) as r:
            data=r.read()
          h=hashlib.sha256(data).hexdigest()
          evt={"id":"ext_"+h[:16],"actor_did":None,"type":"external","verb":"observe",
               "confidence":0.30,"timestamp":datetime.now(timezone.utc).isoformat(),
               "evidence_uri":u,"content_sha256":h}

          if a.mapper == "basic":
              imp, sev, conf, meta = map_basic(u, data, hints)
              evt["impact"]=imp; evt["severity"]=sev; evt["confidence"]=conf; evt["mapper"]="basic"; evt.update(meta)

          out.write(json.dumps(evt,separators=(",",":"))+"\n")
        except Exception:
          pass
        if i < len(urls)-1:
          time.sleep(delay)

    print("[DONE]", a.out)

if __name__=="__main__":
    main()
