# Talkam Liberia Handoff Package

## Repo Structure
- `artifacts/architecture` – diagrams + spec.
- `artifacts/wireframes` – low-fi/hi-fi PNGs + prototype JSON.
- `artifacts/branding` – brand guide, logos, app icons (SVG/PNG).
- `artifacts/flowcharts` – lifecycle visuals + markdown.
- `artifacts/specs` – technical spec + OpenAPI contract.
- `artifacts/data` – PostgreSQL schema + seed data.
- `artifacts/docs` – roadmap, monetization, security, QA, devops, moderation, user stories, handoff.
- `artifacts/ux` – component & accessibility guidelines.
- `artifacts/analytics` – KPI spec + dashboard mock.
- `artifacts/copy` – promotional content.

## Developer Notes
- Use Flutter 3 stable; target Android SDK 24+, iOS 13+. Web build behind feature flag until hardened.
- Configure `.env` for API base, CDN, map tiles, SMS gateway credentials.
- Run `postgres` locally with `schema.sql`, seed using `psql -f` or `docker compose up db`.
- Start FastAPI via `uvicorn app.main:app --reload`, ensure Redis & MinIO containers running for signed uploads.
- Link mobile offline store to backend by testing airplane mode scenario; run integration tests with `pytest -m offline`.
- Use `openapi.yaml` to generate API clients (e.g., `openapi-generator-cli generate -g dart-dio` for Flutter, `typescript-fetch` for web dashboards).

## Asset Summary
- Architecture diagrams: SVG + PNG.
- Wireframes: `talkam-lowfi.png`, `talkam-hifi.png`.
- Logos & icons: 2 logos + 3 icon variants (SVG/PNG).
- Flowchart: SVG + markdown narrative.
- Analytics mockup: PNG.
- Copy & plans: markdown docs enumerated above.

## Next Steps for Engineering
1. Stand up infrastructure via Terraform modules (network, RDS, Redis, S3, EKS).
2. Scaffold FastAPI services aligning with OpenAPI schemas; add Alembic migrations for `schema.sql`.
3. Implement Flutter feature modules per UX guide; integrate offline queue & SMS fallback.
4. Wire up analytics pipeline (ClickHouse + events ingestion) and dashboards.
5. Conduct security review vs `security-privacy.md` + `moderation-escalation.md` before pilot.

## Required Pilots & Testing
- Run 2 closed betas: one urban (Monrovia) focusing on feed performance, one rural (Lofa) focusing on offline + SMS.
- Validate SMS gateway throughput with Orange & Lonestar test numbers.
- Complete user testing script (see `qa-testing.md`).

## Contact & Governance
- Establish civil society advisory board (3 NGOs, 1 journalist, 1 gov rep).
- Document data access policies and sign NDAs with partners before sharing exports.
