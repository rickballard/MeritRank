# Seeder Component (v0 scaffold)

Purpose: continuously enrich registry with probabilistic observations.
Out of scope: scraping behind auth; storing PII on-chain.

Interfaces:
- Writes: /api/events (external), with confidence and evidence
- Reads: /api/identities/resolve for candidate linkage

_TODO_: prototype CLI, config (allow-lists), logging & metrics.
