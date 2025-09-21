from tools.score_demo.score import score
from datetime import datetime, timezone
def mk(sev,imp,conf=1.0): return {"severity":sev,"impact":imp,"confidence":conf,"timestamp":datetime.now(timezone.utc).isoformat()}
def test_neg_dominance():
  evts=[mk(0.2,1.0) for _ in range(10)] + [mk(0.9,-1.0)]
  r=score(evts); assert r["components"]["neg"]>r["components"]["pos"]
