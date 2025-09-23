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

function Sigmoid([double]$x, [double]$k, [double]$x0) {
  return 1.0 / (1.0 + [math]::Exp(-$k * ($x - $x0)))
}
function LogNorm([double]$x, [double]$base, [double]$scale) {
  if ($x -le 0) { return 0.0 }
  return [math]::Min(1.0, ($scale * ([math]::Log($x, $base))) / 3.0)
}

$raw = @{
  readme_length   = [double]($map.repoReadmeLength ?? 0)
  ps1_count       = [double]($map.ps1Count ?? 0)
  md_count        = [double]($map.mdCount ?? 0)
  registry_points = [double]($map.registry_points ?? 0)
}

$norm = @{
  readme_length   = Sigmoid $raw.readme_length ([double]$config.transforms.readme_length.k) ([double]$config.transforms.readme_length.x0)
  ps1_count       = LogNorm $raw.ps1_count ([double]$config.transforms.ps1_count.base) ([double]$config.transforms.ps1_count.scale)
  md_count        = LogNorm $raw.md_count  ([double]$config.transforms.md_count.base)  ([double]$config.transforms.md_count.scale)
  registry_points = LogNorm $raw.registry_points ([double]$config.transforms.registry_points.base) ([double]$config.transforms.registry_points.scale)
}

$w = $config.weights
$score = [math]::Round(
  ([double]$w.readme_length   * $norm.readme_length) +
  ([double]$w.ps1_count       * $norm.ps1_count) +
  ([double]$w.md_count        * $norm.md_count) +
  ([double]$w.registry_points * $norm.registry_points), 4)

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }
$scorePath = Join-Path $OutDir 'meritrank_score.txt'
"MeritRankScore=$score" | Out-File -FilePath $scorePath -Encoding UTF8 -Force

$detailPath = Join-Path $OutDir 'meritrank_detail.json'
@{
  raw=$raw; norm=$norm; weights=$w; score=$score; timestamp=[DateTime]::UtcNow.ToString('o')
} | ConvertTo-Json -Depth 6 | Out-File -FilePath $detailPath -Encoding UTF8 -Force

Write-Host "Scorer wrote $scorePath (score=$score)" -ForegroundColor Green