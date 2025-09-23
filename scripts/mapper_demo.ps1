param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$OutDir = (Join-Path (Get-Location).Path 'out')
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }

$readme = Join-Path $RepoRoot 'README.md'
$len = 0
if (Test-Path $readme) { $len = (Get-Content -Raw -Encoding UTF8 $readme).Length }

$ps1Count = (Get-ChildItem -Path $RepoRoot -Recurse -File -Include *.ps1 | Measure-Object).Count
$mdCount  = (Get-ChildItem -Path $RepoRoot -Recurse -File -Include *.md  | Measure-Object).Count

$map = @{
  repoReadmeLength = $len
  ps1Count = $ps1Count
  mdCount = $mdCount
  timestamp = [DateTime]::UtcNow.ToString('o')
}

$mapPath = Join-Path $OutDir 'map_demo.json'
$map | ConvertTo-Json -Depth 5 | Out-File -FilePath $mapPath -Encoding UTF8 -Force
Write-Host "Mapper wrote $mapPath (len=$len, ps1=$ps1Count, md=$mdCount)" -ForegroundColor Cyan