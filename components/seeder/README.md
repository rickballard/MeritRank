# Seeder Component (v0 scaffold)

Purpose: continuously enrich registry with probabilistic observations.
Out of scope: scraping behind auth; storing PII on-chain.

Interfaces:
- Writes: /api/events (external), with confidence and evidence
- Reads: /api/identities/resolve for candidate linkage

_TODO_: prototype CLI, config (allow-lists), logging & metrics.


## Mapper (basic)

The basic mapper extracts simple credibility signals (DID/PGP/C2PA hints) from allowed pages.

Local smoke (uses `file://` URI of a repo fixture):

```powershell
# seed against local fixture
python components/seeder/seeder.py --mapper basic `
  --allowlist components/seeder/config/allowlist.txt `
  --out       components/seeder/out/events.ndjson

# score
python tools/score_demo/score.py `
  --in  components/seeder/out/events.ndjson `
  --out tools/score_demo/out.json
type tools/score_demo/out.json
```

**Notes**
- `robots.txt` is respected for http(s). Local `file://` URIs skip robots.
- No PII is stored on-chain; this mapper only emits external observation events.
