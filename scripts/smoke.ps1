param(
  [string]$Allow = "components\seeder\config\allowlist.txt",
  [string]$Out   = "components\seeder\out\events.ndjson",
  [string]$Score = "tools\score_demo\out.json"
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'

if (-not (Test-Path $Allow)) {
  New-Item -ItemType Directory -Force -Path (Split-Path $Allow) | Out-Null
  "https://example.org/" | Set-Content -Encoding UTF8 $Allow
}

python .\components\seeder\seeder.py --mapper basic --allowlist "$Allow" --out "$Out"
python .\tools\score_demo\score.py --in "$Out" --out "$Score"
Get-Content "$Score"
