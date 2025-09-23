param([string]$RepoRoot = (Get-Location).Path, [string]$OutDir = (Join-Path (Get-Location).Path 'out'))
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$regDir = Join-Path $RepoRoot 'registry'
$points = 0.0
if (Test-Path $regDir) {
  $files = @(Get-ChildItem -Path $regDir -File -Filter *.json)
  foreach ($f in $files) {
    try {
      $obj = Get-Content -Raw -Encoding UTF8 $f.FullName | ConvertFrom-Json
      if ($obj.points -ne $null) { $points += [double]$obj.points }
    } catch { Write-Warning "Invalid registry JSON: $($f.Name) — skipped" }
  }
}
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }
@{ registry_points = $points } | ConvertTo-Json -Depth 5 | Out-File -FilePath (Join-Path $OutDir 'map_registry.json') -Encoding UTF8 -Force
Write-Host ("Registry ingest wrote {0} (registry_points={1})" -f (Join-Path $OutDir 'map_registry.json'), $points)