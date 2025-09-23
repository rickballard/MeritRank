param(
  [string]$MapPath = (Join-Path (Get-Location).Path 'out\map_demo.json'),
  [string]$OutDir = (Join-Path (Get-Location).Path 'out')
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
if (-not (Test-Path $MapPath)) { throw "Map file not found: $MapPath" }
$map = Get-Content -Raw -Encoding UTF8 $MapPath | ConvertFrom-Json
$len = [double]($map.repoReadmeLength ?? 0)
# Demo score: bounded sigmoid-ish transform to 0..1
$score = [math]::Round(1.0 / (1.0 + [math]::Exp(-(($len/1000.0)-1.0))), 4)
$scorePath = Join-Path $OutDir 'meritrank_score.txt'
"MeritRankScore=$score" | Out-File -FilePath $scorePath -Encoding UTF8 -Force
Write-Host "Scorer wrote $scorePath (score=$score)" -ForegroundColor Green