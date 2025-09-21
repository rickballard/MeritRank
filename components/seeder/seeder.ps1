param(
  [string]$AllowList = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\config\allowlist.txt",
  [string]$Out       = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\out\events.ndjson"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProgressPreference = 'SilentlyContinue'
$here   = Split-Path -Parent $MyInvocation.MyCommand.Path
function Resolve-Abs([string]$p, [string]$base) {
  if ([System.IO.Path]::IsPathRooted($p)) { return $p }
  return (Join-Path $base $p)
}
$AllowList = Resolve-Abs $AllowList $here
$Out       = Resolve-Abs $Out       $here

if (-not (Test-Path $AllowList)) { throw "AllowList not found: $AllowList" }
$OutDir = Split-Path -Parent $Out
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
New-Item -ItemType File -Path $Out -Force | Out-Null

$sha = [System.Security.Cryptography.SHA256]::Create()
Add-Type -AssemblyName System.Net.Http
$http = [System.Net.Http.HttpClient]::new()

$urls = Get-Content $AllowList | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object { $_.Trim() } | Where-Object { $_ }
foreach ($u in $urls) {
  try {
    $b = $http.GetByteArrayAsync($u).GetAwaiter().GetResult()
    $h = ($sha.ComputeHash($b) | ForEach-Object { $_.ToString("x2") }) -join ""
    $evt = @{
      id="ext_"+[guid]::NewGuid().ToString("n"); actor_did=$null; type="external"; verb="observe"
      confidence=0.3; timestamp=(Get-Date).ToUniversalTime().ToString("o")
      evidence_uri=$u; content_sha256=$h
    }
    ($evt | ConvertTo-Json -Compress) | Add-Content $Out
  } catch { }
}
Write-Host "[DONE] Seeded -> $Out"
