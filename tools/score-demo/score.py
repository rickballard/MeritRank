#!/usr/bin/env python3
import argparse, json, math
from datetime import datetime, timezone
def parse_ts(s): return datetime.fromisoformat(s.replace("Z","+00:00")).astimezone(timezone.utc)
def decay(ts,half=90.0): 
  dt=(datetime.now(timezone.utc)-ts).total_seconds()/86400.0
  return 0.5**(max(0.0,dt)/half)
def score(events):
  pos=neg=0.0
  for e in events:
    ts=parse_ts(e.get("timestamp")) if e.get("timestamp") else datetime.now(timezone.utc)
    w=decay(ts)*float(e.get("confidence",0.5))
    imp=float(e.get("impact",0.0)); sev=float(e.get("severity",0.0))
    if sev>=0.7 and imp<0: neg+=4.0*abs(imp)*w
    else: pos+=imp*w
  s=max(0.0,100.0*(1/(1+math.exp(-(pos-neg)))))
  return {"score":s,"components":{"pos":pos,"neg":neg}}
def main():
  ap=argparse.ArgumentParser(); ap.add_argument("--in",dest="inp",required=True); ap.add_argument("--out",dest="out",required=True); a=ap.parse_args()
  evts=[json.loads(l) for l in open(a.inp,encoding="utf-8") if l.strip()]
  json.dump(score(evts), open(a.out,"w",encoding="utf-8"), indent=2); print("[OK]",a.out)
if __name__=="__main__": main()
