# Init-MeritRank.ps1
param(
  [string]$Owner = (git config user.name),
  [string]$RepoName = 'MeritRank'
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI 'gh' not found. Install from https://cli.github.com"
}

$full = "$Owner/$RepoName"
$exists = gh repo view $full 2>$null
if (-not $exists) {
  gh repo create $full --public --source "." --push
} else {
  git init
  git add .
  git commit -m "seed: initial content" -q
  git branch -M main
  git remote add origin "https://github.com/$full.git" 2>$null
  git push -u origin main
}

# Relaxed gating
gh api -X PATCH "repos/$full" -f allow_squash_merge=true -f allow_merge_commit=false -f allow_rebase_merge=false
try { gh api -X DELETE "repos/$full/branches/main/protection" | Out-Null } catch {}

Write-Host "Repo ready: https://github.com/$full"
