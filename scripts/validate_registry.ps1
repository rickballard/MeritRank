param([string]$RepoRoot = (Get-Location).Path)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

$regDir = Join-Path $RepoRoot 'registry'
if (-not (Test-Path $regDir)) {
  Write-Host "No registry dir; nothing to validate."
  exit 0
}

$errors = @()
$files  = @(Get-ChildItem -Path $regDir -File -Filter *.json)  # ensure array

$validCats = @('docs','code','ops','policy')

foreach ($f in $files) {
  try {
    $obj = Get-Content -Raw -Encoding UTF8 $f.FullName | ConvertFrom-Json
  } catch {
    $errors += "Invalid JSON in $($f.Name)"
    continue
  }
  if (-not $obj.id)   { $errors += "Missing id in $($f.Name)"; continue }
  if (-not $obj.name) { $errors += "Missing name in $($f.Name)"; continue }
  try {
    $pts = [double]$obj.points
    if ($pts -lt 0) { $errors += "points < 0 in $($f.Name)" }
  } catch { $errors += "Missing/invalid points in $($f.Name)" }
  if ($obj.PSObject.Properties.Name -contains 'category') {
    if ($obj.category -and -not ($validCats -contains ($obj.category.ToString().ToLower()))) {
      $errors += "Invalid category '$($obj.category)' in $($f.Name)"
    }
  }
}

if ($errors.Count -gt 0) {
  $errors | ForEach-Object { Write-Error $_ }
} else {
  Write-Host "Registry validation OK ($($files.Count) files)"
}