#!/usr/bin/env python3
import argparse, json, hashlib, urllib.request
from datetime import datetime, timezone
ap=argparse.ArgumentParser(); ap.add_argument("--allowlist",default="components/seeder/config/allowlist.txt"); ap.add_argument("--out",default="components/seeder/out/events.ndjson"); a=ap.parse_args()
urls=[l.strip() for l in open(a.allowlist,encoding="utf-8") if l.strip() and not l.startswith("#")]
with open(a.out,"w",encoding="utf-8") as out:
  for u in urls:
    try:
      data=urllib.request.urlopen(urllib.request.Request(u,headers={"User-Agent":"CoEveSeeder/0.0.1"}),timeout=20).read()
      h=hashlib.sha256(data).hexdigest()
      evt={"id":"ext_"+h[:16],"actor_did":None,"type":"external","verb":"observe","confidence":0.3,"timestamp":datetime.now(timezone.utc).isoformat(),"evidence_uri":u,"content_sha256":h}
      out.write(json.dumps(evt,separators=(",",":"))+"\n")
    except Exception:
      pass
print("[DONE]",a.out)
