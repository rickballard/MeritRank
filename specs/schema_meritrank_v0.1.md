# MeritRank Schema v0.1

## Entities
- Subject(id, type)
- Claim(id, subject_id, method_id, data_ref, submitted_by, timestamp, signature)
- Method(id, version, code_ref, weights, audit_log)
- Score(subject_id, kind, value, conf, method_id, hash_inputs)

## Score Kinds
- MeritCredit
- RepScore
- VoteWeight

## ScripTag
- `scripttag://<method-id>@<version>#<param-hash>` → canonical ref to method + params

## Transparency
- Deterministic reducer: sort inputs → compute → emit hash of inputs + method version.
- All steps reproducible from public artifacts.

## API Sketch
- POST /claims
- GET /scores?subject=
- GET /methods/{id}@{ver}
