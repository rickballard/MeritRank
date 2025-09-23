param([string]$ConfigPath = "config\meritrank.config.json", [string]$OutDir = ".")
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

if (-not (Test-Path $ConfigPath)) { throw "Config not found: $ConfigPath" }
$config = Get-Content -Raw -Encoding UTF8 $ConfigPath | ConvertFrom-Json

# Apply override if present (this mirrors scorer behavior)
$overridePath = "config\weights.override.json"
$source = "config"
if (Test-Path $overridePath) {
  try {
    $ov = Get-Content -Raw -Encoding UTF8 $overridePath | ConvertFrom-Json
    if ($ov.weights) { $config.weights = $ov.weights; $source = "override" }
  } catch {}
}

$cacheDir = ".meritrank_cache"
if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null }
$baselinePath = Join-Path $cacheDir "weights_baseline.json"
$histPath = Join-Path $cacheDir "weights.history.jsonl"

$now = [DateTime]::UtcNow.ToString('o')
$actor = $env:GITHUB_ACTOR
if (-not $actor) { $actor = $env:USERNAME }
if (-not $actor) { $actor = "unknown" }

$newWeights = $config.weights | ConvertTo-Json -Depth 8 -Compress
$changed = $true
$old = $null
if (Test-Path $baselinePath) {
  $oldJson = Get-Content -Raw -Encoding UTF8 $baselinePath
  $changed = ($oldJson -ne $newWeights)
  $old = $oldJson
}
if ($changed) {
  $entry = @{
    ts=$now; actor=$actor; source=$source;
    branch=$env:GITHUB_REF; sha=$env:GITHUB_SHA;
    old=$old; new=$newWeights
  }
  ($entry | ConvertTo-Json -Depth 8 -Compress) | Out-File -FilePath $histPath -Append -Encoding UTF8
  $newWeights | Out-File -FilePath $baselinePath -Encoding UTF8
  $msg = "Weights changed (source=$source)"
} else { $msg = "Weights unchanged" }

$summary = Join-Path $OutDir "weights_change.txt"
$msg | Out-File -FilePath $summary -Encoding UTF8 -Force
Write-Host $msg