# Seeder Pipeline (design notes, v0)

- Fetch: allow-listed sources, robots.txt respect, politeness rate
- Extract: NER, signature/credential detection (C2PA/PGP/DID)
- ER: candidate merges with confidence; avoid forced merges
- Event mapping: tag as external, include provenance + confidence
- HITL: review queue for low confidence; owner claim flow override

_TODO_: confidence schema, contradiction handling, opt-out mechanics.
