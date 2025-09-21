# CoEve Identities & Credibility Registry — Strategy & Implementation Proposal (v1)

**Document ID:** CoEve_Identities_Registry_Proposal_v1  
**Intended repo:** `MeritRank` (advice package)  
**Scope:** Identity + credibility registry, pseudonymous-first, ethics‑weighted behavior tracking, and MeritRank integration.  
**Authoring context:** Derived from sessions on MeritRank, ScriptTag, RepTag, and CoCivium identity needs. This is a *complete* capture; anything not included is either unsafe or deliberately deferred.

---

## 0) Executive Summary

We propose **CoEve** — the digital identity persona and governance nucleus for CoCivium’s identity-and-credibility layer — implemented as a **pseudonymous-first registry** with **ethics-forward reputation**. CoEve anchors the **MeritRank** product line: a composable credibility engine that scores identities (human, AI, bot, team) based on observed behaviors, attestations, and verifiable credentials.

Key pillars:

- **Pseudonymity by default; verification optional:** Start with low-friction **DIDs** and upgradeable proofs (e.g., WebAuthn, verifiable credentials, KYC). Users choose their verification tier per context.
- **Ethics-weighted MeritRank:** A transparent, tamper‑evident ledger of behavior events (ScriptTag / RepTag / Merit Events) with **severity‑weighted scoring, decay, and confidence intervals**.
- **Sybil‑resistant and gaming‑aware:** Guardrails against “million‑alts” and “goodwashing” (mass trivial good → one severe bad). Rate‑limits, velocity caps, stake/slash options, anomaly detection, and quarantine.
- **Crawler/daemon seeding:** A controlled **ingestion bot** continuously builds a probabilistic map of online identities and actions with **confidence metrics** and strict **privacy/compliance** fences.
- **Transparency + privacy by design:** **Append‑only transparency logs** (Merkle/KERI‑style) anchored to a public chain; PII encrypted and separable (crypto‑erasure possible). **Selective disclosure** for claims.
- **Interoperability first:** Align to **W3C DID**, **W3C Verifiable Credentials**, **OpenID Connect/OAuth2.1**, **WebAuthn/FIDO2**, **ToIP/DIF/KERI**, **C2PA** for content provenance.
- **CoEve as first‑class identity:** CoCivium’s own operational persona (CoEve) is onboarded to the registry with the **highest governance bar** and auditable constraints to protect systemic credibility.

Outcomes: a credible, inspectable reputation substrate backing ScriptTag, RepTag, and MeritRank voting, with a marketing‑solid **blockchain‑anchored** transparency story and a pragmatic path to scale.

---

## 1) Design Goals & Non‑Goals

### Goals
1. **Pseudonymous-first** identities with progressive trust: zero‑KYC entry, with optional upgrades (social proofs, org attestations, KYC, PoP).
2. **Ethical credibility** that is legible: explainable score components, event taxonomy, and severity mapping.
3. **Tamper evidence and auditability:** public transparency roots; full audit trails for admin and scoring changes.
4. **Low friction integration:** clean APIs/SDKs for ScriptTag/RepTag/MeritRank and external systems.
5. **Safety at scale:** Sybil resistance, anti‑gaming, anomaly detection, and rapid quarantine/rollback.
6. **Privacy and compliance:** data minimization, selective disclosure, rights to rectification/dispute flows.
7. **Portability:** interop with external ID networks; no platform lock‑in.

### Non‑Goals (v1)
- Global, single‑source “real identity” verification for everyone (not feasible).  
- On‑chain storage of PII (privacy/regulatory risk).  
- Fully decentralized L1/L2 at day one; we start with hybrid transparency anchored on public chains, then decentralize validators over time.

---

## 2) Identity Model

### 2.1 Identity Types
- **Human** (pseudonymous or verified), **AI agent**, **Bot**, **Team/Pair** (human+AI), **Organization**, **Non‑human** (e.g., dolphins/apes research contexts).  
- Each identity is a **DID subject** (e.g., `did:key`, `did:web`, `did:peer` initially). Upgrades possible (other DID methods).

### 2.2 Keys, Handles, and “AvatarCode”
- Each DID has a primary **public‑key** and rotation policy (KERI‑style event log recommended for rotations).  
- **Handle**: human‑friendly label (mutable; not identity).  
- **AvatarCode**: a compact, versioned code derived from the DID public key → deterministic identicon parameters (pixel grid, geometry). Changing the avatar does **not** change identity; identities are bound to keys/DIDs.  
- **Collision resistance:** AvatarCode is a visualization of the DID key; uniqueness inherits from key uniqueness.

### 2.3 Verification Tiers (Optional)
- **Tier 0:** pseudonymous (DID‑only).  
- **Tier 1:** WebAuthn device proof; light social proofs.  
- **Tier 2:** Org/Institutional verifiable credentials (employment, membership, domain control).  
- **Tier 3:** KYC/AML proofs (offered by third‑party issuers).  
- **Tier 4 (contextual):** Proof‑of‑Personhood or Sybil‑limited tokens for specific venues/events.

Tiers are **per‑context**, not global. MeritRank may weight tiers differently per product policy.

---

## 3) MeritRank Credibility Engine

### 3.1 Event Taxonomy
- **Merit Events**: on‑platform actions (contributions, helpful moderation, policy adherence).  
- **ScriptTag**: signed content/provenance attestations.  
- **RepTag**: peer endorsements/flags with scope and weight controls.  
- **External Signals**: VCs, signed statements, content provenance (C2PA), cross‑network trust links.

Each event has: `actor`, `verb`, `object`, `context`, `severity`, `impact`, `timestamp`, `confidence`, `evidence_uri`, `signature(s)`.

### 3.2 Scoring
- **Severity‑weighted**: critical negatives dominate (counter “goodwashing”).  
- **Recency decay**: exponential or half‑life by category.  
- **Wilson interval / Bayesian shrinkage**: to avoid volatility and score gaming on small samples.  
- **Contextual caps**: per‑domain ceilings (no single venue can inflate global cred).  
- **Velocity/rate limits**: per identity and per source (damp spam/farms).  
- **Network effects**: eigenvector‑like influence optional, bounded to avoid plutocracy.  
- **Confidence integration**: all inputs carry `confidence` \[0..1\]; low‑confidence data has attenuated weight.

### 3.3 Transparency
- Scores are **explainable**: show contributing events, weights, decay, and confidence.  
- **Appeals & redress**: structured dispute workflows; if overturned, the ledger records reversal links.

---

## 4) Anti‑Gaming & Abuse Resistance

Attacks considered: **Sybil swarms**, **goodwashing**, **identity churn**, **collusion rings**, **borrowed credibility**, **credential theft**, **data poisoning**, **bribery markets**, **denial‑of‑service**, **astroturfing**.

Mechanisms:

1. **Identity cost & friction**: per‑context staking (refundable), creation velocity caps, progressive unlocks.  
2. **Anomaly detection**: burst patterns, correlated timing/IP/UA fingerprints (privacy‑aware aggregates), graph motifs.  
3. **Contextualization**: caps by venue; cross‑venue diversification required for high global cred.  
4. **Negative dominance rules**: high‑severity negatives impose steep penalties regardless of mass low‑severity positives.  
5. **Quarantine lanes**: shadow‑ban/limited reach pending review; preserve appeal rights.  
6. **Issuer quality weighting**: VCs from weak issuers are discounted; issuer reputation tracked too.  
7. **Admin transparency log**: all privileged actions are signed and logged to an append‑only transparency tree.  
8. **Rotation hygiene**: KERI‑style key events with witnesses reduce account takeovers.  
9. **Economic pressure** (opt‑in domains): stake/slash for high‑impact roles (curators, moderators).

---

## 5) Data Ingestion (Crawler/Daemon) — “Seeder”

**Goal:** Continuously enrich the registry with *probabilistic* observations while respecting law, robots.txt, and platform ToS.

### 5.1 Pipeline
1. **Discovery & Fetch**: curated allow‑lists; politeness rates; snapshot hashing.  
2. **Extraction**: NER, claim/attribution parsing, signature/credential detection (C2PA, PGP, DID proofs).  
3. **Entity Resolution (ER)**: blocking keys + similarity; produce **candidate identity links** with `confidence`.  
4. **Event Generation**: map observations to event taxonomy with `confidence`; tag as **unverified external**.  
5. **Risk Fences**: sensitive data filters, PII redaction, jurisdictional route‑offs (e.g., GDPR/PIPEDA/CCPA).  
6. **Human‑in‑the‑loop** (HITL): queue uncertain merges/splits for steward review.  
7. **Owner Claim Flow**: if a subject later claims the identity, they can **accept/deny/annotate** prior observations; all changes are logged.

### 5.2 Data Quality
- Every observation carries **confidence**, provenance, and reproducible parsing steps.  
- **Contradiction handling**: fork hypotheses rather than force merges; decay low‑support hypotheses.

### 5.3 Legal/Ethical
- Strict **purpose limitation**; publish **data processing notices**; opt‑out and dispute channels.  
- **No PII on‑chain**; minimize retention; crypto‑erasure via key destruction of encrypted PII vaults.

---

## 6) Ledger & Transparency Architecture

- **Core store:** scalable DB (e.g., Postgres + JSONB / FoundationDB) for identities, events, and scores.  
- **Transparency log:** **append‑only Merkle tree** for events and admin actions (think Certificate Transparency).  
- **Anchoring:** periodic **public blockchain anchoring** (e.g., OpenTimestamps/Bitcoin or Ethereum/L2) with batched roots.  
- **KERI Event Logs:** for key management/rotations; witness network to attest event receipt.  
- **Backfill & Snapshots:** signed checkpoints for efficient audits.

Rationale: achieves tamper‑evidence and public verifiability without on‑chain PII or unbounded fees.

---

## 7) Privacy, Security, and Compliance

- **Privacy by design:** data minimization, purpose scoping, retention limits, private-by-default profiles.  
- **Selective disclosure:** verifiable credentials with ZK-friendly schemes (e.g., BBS+), **no over‑disclosure**.  
- **PII vault:** field‑level encryption; keys bound to the subject where possible.  
- **Cryptographic erasure:** encrypt‑then‑forget keys to satisfy erasure requests in practice.  
- **Security:** Zero‑Trust access, RBAC/ABAC, WebAuthn for staff, signed builds, SBOMs, secrets management, continuous SCA/DAST.  
- **Audit:** third‑party security reviews; public postmortems for Sev‑1 incidents.  
- **Jurisdictions:** align to **GDPR**, **PIPEDA**, **CCPA**; AML/KYC when Tier‑3 is used; clear ToS/DPAs.

---

## 8) Governance & CoEve’s Role

- **CoEve** is the **operational persona** of CoCivium in the registry, subject to **stricter rules** and **full transparency**.  
- **Steward Council:** multisig policy keys; quorum for policy changes; emergency powers with narrow scope and expiry.  
- **Public RFCs:** for scoring/weight updates; versioned policies with diffs.  
- **Conflicts & appeals:** timelines, independent reviewers, escalation paths.  
- **Sunlight rules:** admin actions → transparency log → public anchors.

Objective: make **abuse of power costlier than abuse of the system**.

---

## 9) Interoperability Matrix (Initial)

- **Authentication:** OpenID Connect / OAuth 2.1, **FIDO2/WebAuthn**.  
- **Identifiers:** **W3C DID** (start with `did:key`, `did:web`, `did:peer`).  
- **Credentials:** **W3C Verifiable Credentials** (subject‑controlled wallets; issuer reputation tracked).  
- **Key Events:** **KERI** for rotations, witnesses, receipts.  
- **Content Provenance:** **C2PA** (image/audio/video/doc claims).  
- **Trust Frameworks:** DIF / Trust over IP (ToIP) profiles where relevant.  
- **Group Comms (future):** MLS for secure group attestations.

---

## 10) Product Surfaces & APIs

- **Registry API (read):** resolve identities, fetch scores, event proofs, transparency proofs, explainer fragments.  
- **Registry API (write):** register identity (DID), claim/verify, submit ScriptTag/RepTag/Merit Events, attach VCs.  
- **Admin API:** stewardship actions (limited; all logged).  
- **SDKs:** TypeScript/Python; client libs for ScriptTag/RepTag.  
- **UI:** Identity portal (claim/verify/appeal), Score explainer, Transparency viewer, Steward console.

---

## 11) Marketing Framing

- “**Blockchain‑anchored transparency** for ethical reputation.”  
- “**Pseudonymous by default**, verifiable when you want it.”  
- “**Explainable scores** backed by public proofs and privacy‑preserving credentials.”  
- “**Sybil‑resistant** anti‑gaming built in.”

---

## 12) Phased Delivery Plan

### Phase 0 — Spec & Decisions (2–4 weeks)
- Finalize event taxonomy; pick DID methods for v1.  
- Select transparency log format (CT‑like) and anchoring cadence.  
- Threat‑model sign‑off; governance charter v1.

### Phase 1 — MVP (6–10 weeks)
- Registry core (IDs, events, scoring v1), transparency log + weekly anchoring.  
- Pseudonymous registration (did:key), WebAuthn sign‑in.  
- ScriptTag/RepTag minimal integration; score explainer v1.  
- Seeder v0: allow‑listed sources; confidence metrics; HITL review.  
- CoEve onboarding + steward console v0.

### Phase 2 — Interop & Scale (8–16 weeks)
- W3C VC ingestion; issuer reputation.  
- KERI for rotations; witness service.  
- Advanced anti‑gaming: anomaly detection, stake/slash lanes.  
- Public API & dev portal; transparency viewer.  
- Anchoring → daily; validator program pilot.

### Phase 3 — Decentralize & Hardening
- Community validators; parameter governance via RFCs.  
- Independent audits; bug bounty.  
- Expanded PoP options, domain‑specific policies, L2 cost controls.

---

## 13) KPIs & Guardrails

- **Precision/Recall** of abuse detection; **FPR/FNR**.  
- **MTTQ** (mean time to quarantine) for severe events.  
- **Dispute resolution time**; reversal rates.  
- **Sybil cost index** (estimated $/identity to sustain influence).  
- **Transparency lag** (time to anchor).  
- **Adoption:** claimed identities, Tier upgrades, verified issuers count.

Guardrails: publish quarterly scorecard; freeze risky parameter changes pre‑election/events; emergency rollback playbook.

---

## 14) Open Questions / Risks

- **Chain selection** and anchoring costs at scale.  
- **Erasure vs. Immutability**: practical crypto‑erasure is acceptable, but messaging must be precise.  
- **Scraping legal risk**: maintain allow‑lists; robust ToS adherence.  
- **Jurisdictional conflicts** across privacy/AML regimes; need configurable policy packs.  
- **Proof‑of‑Personhood** ethics and accessibility.  
- **Bias** in scoring inputs; continuous fairness audits.

---

## 15) Initial Data Schemas (Sketch)

### 15.1 Identity
```json
{
  "did": "did:key:z6Mki...",
  "created_at": "2025-09-21T00:00:00Z",
  "avatar_code": "ac:v1:Qm...",
  "tiers": ["T0","T1"],
  "controllers": ["did:key:..."],
  "status": "active|quarantined|retired",
  "labels": ["human|ai|team|org|nonhuman"]
}
```

### 15.2 Event
```json
{
  "id": "evt_...",
  "actor_did": "did:...",
  "type": "merit|scripttag|reptag|external",
  "verb": "contribute|endorse|flag|publish|...",
  "context": "repo:MeritRank|forum:...",
  "severity": 0.0,
  "impact": 0.0,
  "confidence": 0.67,
  "evidence_uri": "https://...",
  "signatures": ["..."],
  "timestamp": "2025-09-21T00:00:00Z"
}
```

### 15.3 Score Explainer
```json
{
  "did": "did:...",
  "score": 72.4,
  "components": [
    {"name": "merit_positive", "weight": 0.35, "value": 40.0},
    {"name": "severe_negative", "weight": -0.8, "value": -55.0}
  ],
  "decay_model": "half_life:90d",
  "confidence": 0.81,
  "as_of": "2025-09-21T00:00:00Z"
}
```

---

## 16) Policies (v1 extracts)

- **Negative dominance:** A single high‑severity event cannot be washed out by many trivial positives.  
- **Context caps:** No single venue can lift global cred beyond defined caps.  
- **Consent defaults:** private‑by‑default profiles; public exposure is explicit.  
- **Auditability:** All privileged actions are signed, logged, and anchored.  
- **Appeals:** Right to explanation and correction; reversible with full traceability.

---

## 17) Inspiration & Standards (for implementation alignment)

- **W3C**: DID Core, Verifiable Credentials.  
- **FIDO Alliance**: WebAuthn/FIDO2.  
- **DIF / ToIP** frameworks and KERI for key events.  
- **C2PA** for content provenance signals.  
- **NIST** digital identity guidance; Zero‑Trust security.  
- **Certificate Transparency** model for append‑only logs (adapted).  
- **EigenTrust / PageRank‑style** ideas for bounded network influence.  
- **OpenTimestamps** (or equivalent) for low‑cost anchoring.

---

## 18) Deliverables for MeritRank Repo (Advice Package)

- `/docs/advice-bombs/CoEve_Identities_Registry_Proposal_v1.md` (this file).  
- `/docs/specs/identity-model.md` (future).  
- `/docs/specs/scoring-model.md` (future).  
- `/docs/specs/transparency-log.md` (future).  
- `/docs/runbooks/abuse‑response.md` (future).  
- `/sdk/` stubs for TS/Python (future).

---

## 19) Next Actions (Concrete)

1. Ratify event taxonomy and negative‑dominance constants.  
2. Choose initial DID methods (`did:key` + `did:web`) and AvatarCode v1.  
3. Implement transparency log with weekly anchoring.  
4. Build MVP registry + Sign‑in (WebAuthn) + minimal ScriptTag/RepTag integration.  
5. Stand up Seeder v0 with allow‑lists and HITL review.  
6. Draft governance charter v1 and onboard CoEve under steward constraints.  
7. Publish public roadmap and security disclosure policy.

---

*End of v1.*
