param(
  [string]$AllowList = "components/seeder/config/allowlist.txt",
  [string]$Out = "components/seeder/out/events.ndjson"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if (-not (Test-Path $AllowList)) { throw "AllowList not found: $AllowList" }
$urls = Get-Content $AllowList | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object { $_.Trim() } | Where-Object { $_ }
New-Item -ItemType File -Path $Out -Force | Out-Null
$sha = [System.Security.Cryptography.SHA256]::Create()
Add-Type -AssemblyName System.Net.Http
$http = [System.Net.Http.HttpClient]::new()
foreach ($u in $urls) {
  try {
    $b = $http.GetByteArrayAsync($u).GetAwaiter().GetResult()
    $h = ($sha.ComputeHash($b) | ForEach-Object { $_.ToString("x2") }) -join ""
    $evt = @{ id="ext_"+[guid]::NewGuid().ToString("n"); actor_did=$null; type="external"; verb="observe"; confidence=0.3; timestamp=(Get-Date).ToUniversalTime().ToString("o"); evidence_uri=$u; content_sha256=$h }
    ($evt | ConvertTo-Json -Compress) | Add-Content $Out
  } catch {}
}
Write-Host "[DONE] Seeded -> $Out"
