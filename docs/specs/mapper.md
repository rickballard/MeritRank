## Domain hints (v0)

The seeder's **basic** mapper can optionally consult components/seeder/config/domain_hints.json
to inject low-confidence signals for specific hosts (e.g., xample.org, www.iana.org) or to
supply CSS selectors for scraping simple meta tags. Hints are strictly optional and carry small
weights to avoid false confidence.

