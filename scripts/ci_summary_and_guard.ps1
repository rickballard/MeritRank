param(
  [string]$HistoryCsv = ".meritrank_cache/history.csv",
  [string]$SummaryPath = $env:GITHUB_STEP_SUMMARY,
  [string]$ConfigPath = "config\meritrank.config.json",
  [string]$EventName = $env:GITHUB_EVENT_NAME,
  [string]$BaseRef = $env:GITHUB_BASE_REF
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

$score = (Get-Content -Raw -Encoding UTF8 'out/meritrank_score.txt').Split('=')[1] -as [double]
$config = Get-Content -Raw -Encoding UTF8 $ConfigPath | ConvertFrom-Json

"### MeritRank: Summary" | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
"Score: $score"         | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append

# Explanations
if (Test-Path 'out/explanations.txt') {
  "#### Components" | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
  Get-Content 'out/explanations.txt' | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
}

# Δ score vs previous
$prev = $null
if (Test-Path $HistoryCsv) {
  $lines = Get-Content -Encoding UTF8 $HistoryCsv
  if ($lines.Count -gt 1) {
    $last = $lines[$lines.Count-1]
    if ($last -match '^[^,]+,[^,]+,[^,]+,([0-9.]+)$') { $prev = ([double]$Matches[1]) }
  }
}
if ($prev -ne $null) {
  $delta = [math]::Round($score - $prev, 4)
  "Δscore vs prev: $delta (prev=$prev)" | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
}

# Sparkline from history
if (Test-Path $HistoryCsv) {
  $rows = Get-Content -Encoding UTF8 $HistoryCsv | Select-Object -Last 12
  $vals = @()
  foreach ($r in $rows) { if ($r -match '^[^,]+,[^,]+,[^,]+,([0-9.]+)$') { $vals += ([double]$Matches[1]) } }
  if ($vals.Count -gt 0) {
    $min = ($vals | Measure-Object -Minimum).Minimum
    $max = ($vals | Measure-Object -Maximum).Maximum
    if ($max -eq $min) { $max = $min + 1e-6 }
    $blocks = @('▁','▂','▃','▄','▅','▆','▇','█')
    $spark = ""
    foreach ($v in $vals) { $t = ($v - $min)/($max-$min); $i=[int][math]::Round($t*($blocks.Count-1)); if($i -lt 0){$i=0}elseif($i -ge $blocks.Count){$i=$blocks.Count-1}; $spark += $blocks[$i] }
    "Sparkline: $spark (min=$min, max=$max)" | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
  }
} else { "No history yet." | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append }

# PR-only guard
$shouldGuard = $false
if ($config.fail_guard.enabled) {
  if ($config.fail_guard.pr_only) {
    if ($EventName -eq 'pull_request' -and $BaseRef -eq $config.fail_guard.target_branch) { $shouldGuard = $true }
  } else { $shouldGuard = $true }
}

if ($shouldGuard -and (Test-Path $HistoryCsv)) {
  $prev2 = $null
  $lines = Get-Content -Encoding UTF8 $HistoryCsv
  if ($lines.Count -gt 1) {
    $last = $lines[$lines.Count-1]
    if ($last -match '^[^,]+,[^,]+,[^,]+,([0-9.]+)$') { $prev2 = ([double]$Matches[1]) }
  }
  if ($prev2 -ne $null -and $prev2 -gt 0) {
    $dropPct = 100.0 * ($prev2 - $score) / $prev2
    "Prev=$prev2, Curr=$score, DropPct=$dropPct (guard applies=$shouldGuard)" | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
    if ($dropPct -gt [double]$config.fail_guard.max_drop_pct) {
      Write-Error "Score dropped by $([math]::Round($dropPct,2))% which exceeds max_drop_pct=$($config.fail_guard.max_drop_pct) (PR-only guard)."
    }
  }
}