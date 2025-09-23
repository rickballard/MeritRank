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
  registry_points = 0.0
  timestamp = [DateTime]::UtcNow.ToString('o')
}

# Merge registry map if produced
$regPath = Join-Path $OutDir 'map_registry.json'
if (Test-Path $regPath) {
  $reg = Get-Content -Raw -Encoding UTF8 $regPath | ConvertFrom-Json
  if ($reg.registry_points -ne $null) {
    $map.registry_points = [double]$reg.registry_points
  }
}

$mapPath = Join-Path $OutDir 'map_demo.json'
$map | ConvertTo-Json -Depth 5 | Out-File -FilePath $mapPath -Encoding UTF8 -Force
Write-Host "Mapper wrote $mapPath (len=$len, ps1=$ps1Count, md=$mdCount, registry=$($map.registry_points))" -ForegroundColor Cyan