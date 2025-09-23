# MeritRank
> **Your digital halo — verifiable kudos, not callouts.**
[![CI](https://github.com/rickballard/MeritRank/actions/workflows/ci.yml/badge.svg)](https://github.com/rickballard/MeritRank/actions/workflows/ci.yml) [![mapper-smoke](https://github.com/rickballard/MeritRank/actions/workflows/mapper-smoke.yml/badge.svg)](https://github.com/rickballard/MeritRank/actions/workflows/mapper-smoke.yml)

[![Mapper Smoke](https://github.com/rickballard/MeritRank/actions/workflows/mapper-smoke.yml/badge.svg?branch=main)](https://github.com/rickballard/MeritRank/actions/workflows/mapper-smoke.yml)

# MeritRank
> **Your digital halo — verifiable kudos, not callouts.**
[![CI](https://github.com/rickballard/MeritRank/actions/workflows/ci.yml/badge.svg)](https://github.com/rickballard/MeritRank/actions/workflows/ci.yml) [![mapper-smoke](https://github.com/rickballard/MeritRank/actions/workflows/mapper-smoke.yml/badge.svg)](https://github.com/rickballard/MeritRank/actions/workflows/mapper-smoke.yml)

**Goal:** Provide the **reputation, credit, and voting primitives** for CoCivium — ethically grounded, transparent, and portable across chains. Early focus: **ScripTag / RepTag / VoteRank** interop so claims are **evaluatable, reproducible, and rankable**.

## Why
DonDemogog-style actors thrive in opacity. MeritRank counters with:
- **Transparent scoring** (open metrics & weights)
- **Reputation with provenance** (who scored what, when, how)
- **Voting that resists brigading** (sybil-aware, stake + merit + diversity weighting)

## Scope (v0)
- **Data model** for MeritCredits (ethical intent), RepScores, VoteWeights
- **ScripTag** spec for method-bound claims
- **APIs** for ingesting evidence and producing auditable scores
- **Chain adapter** abstraction (start chain-agnostic; later plug EVM/Solana/etc.)

## High-Level Model
- **Subject**: person/org/proposal
- **Evidence**: signed claims with method links (ScripTag)
- **Attribution**: who submitted; reputation-weighted
- **Computation**: deterministic reducer → MeritCredit, RepScore, VoteWeight
- **Transparency**: hash of inputs + method version; reproducible

## Risks & Guardrails
- **Gaming**: publish anti-gaming playbooks; adversarial tests
- **Privacy**: minimize PII; use consented, public data
- **Capture**: open governance; method-vote with diversity constraints

See `specs/schema_meritrank_v0.1.md` for details.


## What is a digital halo?
A **digital halo** is a tamper-evident stream of kudos and impact receipts.
It favors attestations and proofs—not allegations. Records can be optionally
anchored to public chains for stronger auditability.
