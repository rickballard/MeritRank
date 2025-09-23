param([string]$RepoRoot = (Get-Location).Path, [string]$OutDir = (Join-Path (Get-Location).Path 'out'))
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }

$readme = Join-Path $RepoRoot 'README.md'
$len = 0
if (Test-Path $readme) { $len = (Get-Content -Raw -Encoding UTF8 $readme).Length }

$ps1Count = (Get-ChildItem -Path $RepoRoot -Recurse -File -Include *.ps1 | Measure-Object).Count
$mdCount  = (Get-ChildItem -Path $RepoRoot -Recurse -File -Include *.md  | Measure-Object).Count

# TODO/FIXME scan (exclude common dirs)
$excludes = @('\.git\\','\\out\\','\\node_modules\\','\\bin\\','\\obj\\','\\_patch_','\\_CoPayload')
$files = Get-ChildItem -Path $RepoRoot -Recurse -File -Include *.ps1,*.psm1,*.psd1,*.psd,*.md,*.txt,*.json,*.yml,*.yaml
$files = $files | Where-Object { $f=$_; -not ($excludes | Where-Object { $f.FullName -match $_ }) }
$todo = 0
foreach ($f in $files) {
  try {
    $m = Select-String -Path $f.FullName -Pattern '(?i)\b(TODO|FIXME)\b' -AllMatches
    if ($m) { $todo += ($m.Matches.Count) }
  } catch {}
}

$map = @{
  repoReadmeLength = $len
  ps1Count = $ps1Count
  mdCount = $mdCount
  registry_points = 0.0
  todo_count = $todo
  timestamp = [DateTime]::UtcNow.ToString('o')
}

$regPath = Join-Path $OutDir 'map_registry.json'
if (Test-Path $regPath) {
  $reg = Get-Content -Raw -Encoding UTF8 $regPath | ConvertFrom-Json
  if ($reg.registry_points -ne $null) { $map.registry_points = [double]$reg.registry_points }
}

$map | ConvertTo-Json -Depth 5 | Out-File -FilePath (Join-Path $OutDir 'map_demo.json') -Encoding UTF8 -Force
Write-Host ("Mapper wrote {0} (len={1}, ps1={2}, md={3}, registry={4}, todo={5})" -f (Join-Path $OutDir 'map_demo.json'), $len, $ps1Count, $mdCount, $map.registry_points, $todo)