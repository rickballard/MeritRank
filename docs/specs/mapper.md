# Mapper Spec (v0)

**Scope (v0):**
- Parse allowed pages for light-weight markers:
  - `<meta name="coeve:did" content="...">`
  - `<meta name="coeve:pgp" content="...">`
  - `<meta name="coeve:c2pa" content="present">`
- Emit external observation events with provenance and confidence.
- Apply optional domain hints (`components/seeder/config/domain_hints.json`) to weight trust.
- No forced entity merges; only candidate evidence.

**Out of scope (v0):**
- Full ER (entity resolution), cryptographic verification, or KERI rotations.
- Any scraping behind auth or ignoring robots.
