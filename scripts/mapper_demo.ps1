param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$OutDir = (Join-Path (Get-Location).Path 'out')
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }
# Demo: derive a "map" from README length (deterministic, repo-specific signal)
$readme = Join-Path $RepoRoot 'README.md'
$len = 0
if (Test-Path $readme) { $len = (Get-Content -Raw -Encoding UTF8 $readme).Length }
$map = @{ repoReadmeLength = $len; timestamp = [DateTime]::UtcNow.ToString('o') }
$mapPath = Join-Path $OutDir 'map_demo.json'
$map | ConvertTo-Json -Depth 5 | Out-File -FilePath $mapPath -Encoding UTF8 -Force
Write-Host "Mapper wrote $mapPath (len=$len)" -ForegroundColor Cyan