param(
  [string]$HistoryCsv = ".meritrank_cache/history.csv",
  [string]$SummaryPath = $env:GITHUB_STEP_SUMMARY,
  [string]$ConfigPath = "config\meritrank.config.json"
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

# Load current score
$score = (Get-Content -Raw -Encoding UTF8 'out/meritrank_score.txt').Split('=')[1] -as [double]

# Load config (guard)
$config = Get-Content -Raw -Encoding UTF8 $ConfigPath | ConvertFrom-Json

# Append to summary with ASCII sparkline from last ~12 scores
"### MeritRank: Recent Scores" | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
if (Test-Path $HistoryCsv) {
  $rows = Get-Content -Encoding UTF8 $HistoryCsv | Select-Object -Last 12
  $vals = @()
  foreach ($r in $rows) {
    if ($r -match '^[^,]+,[^,]+,[^,]+,([0-9.]+)$') {
      $vals += ([double]$Matches[1])
    }
  }
  if ($vals.Count -gt 0) {
    $min = ($vals | Measure-Object -Minimum).Minimum
    $max = ($vals | Measure-Object -Maximum).Maximum
    if ($max -eq $min) { $max = $min + 1e-6 }
    $blocks = @('▁','▂','▃','▄','▅','▆','▇','█')
    $spark = ""
    foreach ($v in $vals) {
      $t = ($v - $min) / ($max - $min)
      $i = [int][math]::Round($t * ($blocks.Count - 1))
      if ($i -lt 0) { $i = 0 } elseif ($i -ge $blocks.Count) { $i = $blocks.Count - 1 }
      $spark += $blocks[$i]
    }
    "Sparkline: $spark (min=$min, max=$max)" | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
  }
} else {
  "No history yet." | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
}

# Guardrail: fail on excessive drop vs previous value
if ($config.fail_guard.enabled -and (Test-Path $HistoryCsv)) {
  $prev = $null
  $lines = Get-Content -Encoding UTF8 $HistoryCsv
  if ($lines.Count -gt 1) {
    $last = $lines[$lines.Count-1]
    if ($last -match '^[^,]+,[^,]+,[^,]+,([0-9.]+)$') {
      $prev = ([double]$Matches[1])
    }
  }
  if ($prev -ne $null -and $prev -gt 0) {
    $dropPct = 100.0 * ($prev - $score) / $prev
    "Previous=$prev, Current=$score, DropPct=$dropPct" | Out-File -FilePath $SummaryPath -Encoding UTF8 -Append
    if ($dropPct -gt [double]$config.fail_guard.max_drop_pct) {
      Write-Error "Score dropped by $([math]::Round($dropPct,2))% which exceeds max_drop_pct=$($config.fail_guard.max_drop_pct)."
    }
  }
}