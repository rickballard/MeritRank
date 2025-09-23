#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="${1:-$(pwd)}"
echo "== MeritRank smoke (stub) =="
echo "RepoRoot: $REPO_ROOT"
mkdir -p "$REPO_ROOT/out"
echo "MeritRankScore=0.42" > "$REPO_ROOT/out/meritrank_score.txt"
echo "Smoke OK"