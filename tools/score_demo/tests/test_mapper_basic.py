import json, os, subprocess, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parents[3]  # repo root
SEEDER = ROOT / 'components' / 'seeder' / 'seeder.py'
SCORER = ROOT / 'tools' / 'score_demo' / 'score.py'
ALLOW  = ROOT / 'components' / 'seeder' / 'config' / 'allowlist.txt'
OUT    = ROOT / 'components' / 'seeder' / 'out' / 'events.ndjson'
SCORE  = ROOT / 'tools' / 'score_demo' / 'out.json'
FIX    = ROOT / 'components' / 'seeder' / 'fixtures' / 'sample_cred.html'

ALLOW.parent.mkdir(parents=True, exist_ok=True)
OUT.parent.mkdir(parents=True, exist_ok=True)

uri = FIX.resolve().as_uri()
existing = ALLOW.read_text(encoding='utf-8').splitlines() if ALLOW.exists() else []
if uri not in existing:
    with open(ALLOW, 'a', encoding='utf-8') as f:
        f.write(uri + '\n')

subprocess.run([sys.executable, str(SEEDER), '--mapper', 'basic',
                '--allowlist', str(ALLOW), '--out', str(OUT)],
               check=True)
subprocess.run([sys.executable, str(SCORER), '--in', str(OUT), '--out', str(SCORE)], check=True)

res = json.load(open(SCORE, 'r', encoding='utf-8'))
assert res['status'] == 'ok', res
assert float(res.get('score') or 0) >= 50.0, res
