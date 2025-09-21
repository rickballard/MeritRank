#!/usr/bin/env python3
import argparse, json, hashlib, urllib.request, urllib.robotparser, time, os
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
      return True  # be permissive on robots fetch errors

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--allowlist", default="components/seeder/config/allowlist.txt")
    ap.add_argument("--out",       default="components/seeder/out/events.ndjson")
    a=ap.parse_args()

    here = os.path.abspath(os.path.join(os.path.dirname(__file__)))
    policy = load_policy(os.path.join(here, "config"))
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
          evt={"id":"ext_"+h[:16],"actor_did":None,"type":"external","verb":"observe","confidence":0.3,"timestamp":datetime.now(timezone.utc).isoformat(),"evidence_uri":u,"content_sha256":h}
          out.write(json.dumps(evt,separators=(",",":"))+"\n")
        except Exception:
          pass
        if i < len(urls)-1:
          time.sleep(delay)

    print("[DONE]", a.out)

if __name__=="__main__":
    main()
