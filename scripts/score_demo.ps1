param(
  [string]$MapPath = (Join-Path (Get-Location).Path 'out\map_demo.json'),
  [string]$OutDir = (Join-Path (Get-Location).Path 'out'),
  [string]$ConfigPath = "config\meritrank.config.json"
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

if (-not (Test-Path $MapPath)) { throw "Map file not found: $MapPath" }
$map = Get-Content -Raw -Encoding UTF8 $MapPath | ConvertFrom-Json
if (-not (Test-Path $ConfigPath)) { throw "Config not found: $ConfigPath" }
$config = Get-Content -Raw -Encoding UTF8 $ConfigPath | ConvertFrom-Json

# Optional weights override
$overridePath = "config\weights.override.json"
if (Test-Path $overridePath) {
  try {
    $ov = Get-Content -Raw -Encoding UTF8 $overridePath | ConvertFrom-Json
    if ($ov.weights) { $config.weights = $ov.weights }
    Write-Host "Applied weights.override.json" -ForegroundColor Yellow
  } catch { Write-Warning "weights.override.json invalid; ignored" }
}

function Sigmoid([double]$x, [double]$k, [double]$x0) { 1.0 / (1.0 + [math]::Exp(-$k * ($x - $x0))) }
function LogNorm([double]$x, [double]$base, [double]$scale) {
  if ($x -le 0) { return 0.0 }
  [math]::Min(1.0, ($scale * ([math]::Log($x, $base))) / 3.0)
}

$raw = @{
  readme_length   = [double]($map.repoReadmeLength ?? 0)
  ps1_count       = [double]($map.ps1Count ?? 0)
  md_count        = [double]($map.mdCount ?? 0)
  registry_points = [double]($map.registry_points ?? 0)
  todo_count      = [double]($map.todo_count ?? 0)
}

$norm = [ordered]@{
  readme_length   = Sigmoid $raw.readme_length ([double]$config.transforms.readme_length.k) ([double]$config.transforms.readme_length.x0)
  ps1_count       = LogNorm $raw.ps1_count ([double]$config.transforms.ps1_count.base) ([double]$config.transforms.ps1_count.scale)
  md_count        = LogNorm $raw.md_count  ([double]$config.transforms.md_count.base)  ([double]$config.transforms.md_count.scale)
  registry_points = LogNorm $raw.registry_points ([double]$config.transforms.registry_points.base) ([double]$config.transforms.registry_points.scale)
  # todo_health: inverse of warnings
  todo_health     = 1.0 - (LogNorm $raw.todo_count ([double]$config.transforms.todo_health.base) ([double]$config.transforms.todo_health.scale))
}

# Caps
if ($config.caps) {
  foreach ($k in $config.caps.PSObject.Properties.Name) {
    $mx = [double]$config.caps.$k
    if ($norm.Contains($k) -and $mx -gt 0) { $norm[$k] = [math]::Min([double]$norm[$k], $mx) }
  }
}

$w = $config.weights
$components = [ordered]@{
  readme_length   = [double]$w.readme_length   * [double]$norm['readme_length']
  ps1_count       = [double]$w.ps1_count       * [double]$norm['ps1_count']
  md_count        = [double]$w.md_count        * [double]$norm['md_count']
  registry_points = [double]$w.registry_points * [double]$norm['registry_points']
  todo_health     = [double]$w.todo_health     * [double]$norm['todo_health']
}
$score = [math]::Round(($components.Values | Measure-Object -Sum).Sum, 4)

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }
$scorePath  = Join-Path $OutDir 'meritrank_score.txt'
$detailPath = Join-Path $OutDir 'meritrank_detail.json'
$badgePath  = Join-Path $OutDir 'badge.json'
$expPath    = Join-Path $OutDir 'explanations.txt'

"MeritRankScore=$score" | Out-File -FilePath $scorePath -Encoding UTF8 -Force
@{ raw=$raw; norm=$norm; weights=$w; components=$components; score=$score; timestamp=[DateTime]::UtcNow.ToString('o') } |
  ConvertTo-Json -Depth 8 | Out-File -FilePath $detailPath -Encoding UTF8 -Force

# Badge
$badgeColor = 'red'
if ($config.badge) {
  if ($score -ge [double]$config.badge.good_threshold) { $badgeColor = 'brightgreen' }
  elseif ($score -ge [double]$config.badge.warn_threshold) { $badgeColor = 'orange' }
}
$badge = @{ label='MeritRank'; message="$score"; color=$badgeColor }
$badge | ConvertTo-Json -Depth 4 | Out-File -FilePath $badgePath -Encoding UTF8 -Force

# Explanations
$exp = @()
foreach ($k in $components.Keys) {
  $exp += ("{0}: +{1:N4} (norm {2:N3} × w {3:N2})" -f $k,
    [double]$components[$k],
    [double]$norm[$k],
    [double]$w.$k)
}
$exp | Out-File -FilePath $expPath -Encoding UTF8 -Force

Write-Host "Scorer wrote $scorePath and $badgePath (score=$score)" -ForegroundColor Green