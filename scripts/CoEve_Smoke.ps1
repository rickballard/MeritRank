param(
  [string]$RepoRoot = (Get-Location).Path
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

Write-Host "== MeritRank CoEve Smoke (stub) ==" -ForegroundColor Cyan
Write-Host "RepoRoot: $RepoRoot"

# Optional: basic sanity checks
$readme = Join-Path $RepoRoot 'README.md'
if (-not (Test-Path $readme)) {
  Write-Warning "README.md not found at $readme (not fatal)."
}

# TODO: wire to real mapper/demo once available.
# For now, produce a deterministic 'score' file.
$outDir = Join-Path $RepoRoot 'out'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
$scorePath = Join-Path $outDir 'meritrank_score.txt'
$score = 0.42
"MeritRankScore=$score" | Out-File -FilePath $scorePath -Encoding UTF8 -Force
Write-Host "Wrote $scorePath"

# Exit 0 to indicate success
Write-Host "Smoke OK" -ForegroundColor Green