param([string]$ConfigPath = "config\meritrank.config.json")
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

if (-not (Test-Path $ConfigPath)) { throw "Config not found: $ConfigPath" }
$json = Get-Content -Raw -Encoding UTF8 $ConfigPath | ConvertFrom-Json

# basic checks
if (-not $json.version) { throw "Config missing: version" }
if (-not $json.weights) { throw "Config missing: weights" }
if (-not $json.transforms) { throw "Config missing: transforms" }

$sum = 0.0
foreach ($k in $json.weights.PSObject.Properties.Name) {
  $w = [double]$json.weights.$k
  if ($w -lt 0 -or $w -gt 1) { throw "Weight out of range for '$k': $w" }
  $sum += $w
}
# Accept near-1.0
if ([math]::Abs($sum - 1.0) -gt 0.05) { throw "Weights must sum to ~1.0; got $sum" }

Write-Host "Config OK (sum(weights)=$sum)"