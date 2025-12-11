# Talkam Liberia Delivery Package

This repository contains the design + planning artifacts for the Talkam Liberia social reporting system. All deliverables requested by the brief are inside the `artifacts/` directory alongside supporting assets.

## Contents
- Architecture diagrams & spec (`artifacts/architecture`)
- Wireframes & clickable prototype JSON (`artifacts/wireframes`)
- Branding package & app icons (`artifacts/branding`)
- Flowchart visuals (`artifacts/flowcharts`)
- Technical specs + OpenAPI (`artifacts/specs`, backend scaffold in `backend/`)
- Database schema & seed data (`artifacts/data`)
- Product docs (roadmap, monetization, security, QA, devops, moderation, user stories, handoff) under `artifacts/docs`
- UX guidelines (`artifacts/ux`)
- Analytics spec + mockup (`artifacts/analytics`)
- Promotional copy (`artifacts/copy`)

## Getting Started (Developers)
1. **Clone & install prerequisites**
   - Python 3.10+, Poetry or pipenv for backend.
   - Flutter 3.x + fvm recommended.
   - Docker Desktop (for Postgres, Redis, MinIO, RabbitMQ).
2. **Spin up local stack** (implements Next Step #2)
   - **Option A – Containers:**  
     ```sh
     docker compose up postgres redis minio rabbitmq adminer mailhog
     # schema auto-applied from artifacts/data/schema.sql on first boot
     ```
     Re-apply SAMPLE data later with `./scripts/init_db.sh`.
   - **Option B – Dockerless:** follow `artifacts/docs/dockerless-stack.md` for managed or native services (Neon + Upstash, or Homebrew services). Update `.env` with the new connection strings before running the API.
3. **Generate API clients** using `artifacts/specs/openapi.yaml` with `openapi-generator-cli`.
4. **Review/import assets** (Next Step #1)
   - Load `artifacts/wireframes/*.png` and `artifacts/branding/logo/*.svg` into Figma/widgetbook.
   - Apply tokens from `artifacts/branding/brand-guide.md`.
5. **Scaffold & run backend services** (Next Step #2 continuation)
   ```sh
   cd backend
   python -m venv .venv && source .venv/bin/activate
   pip install --upgrade pip
   pip install .
   cp .env.example .env  # edit secrets & DSNs
   uvicorn app.main:app --reload
   ```
   Key modules live under `backend/app/*` (auth, reports, media, NGO/admin routes).
6. **Prepare QA & security dry run** (Next Step #3)
   - Follow `artifacts/docs/qa-testing.md` and `artifacts/docs/security-privacy.md`.
   - Capture findings before inviting pilot partners.

## Pilot Launch Checklist
- Select target county (e.g., Montserrado) and partner NGO/government agency.
- Pre-load county boundaries + offline basemaps for pilot area.
- Train moderators + responders on verification, embargo, and panic delete procedures.
- Configure SMS gateway short codes with local telcos.
- Run tabletop exercise simulating life-threatening escalation.
- Collect feedback via user testing script (see `artifacts/docs/qa-testing.md`).

## Next Steps
- Convert specs into implementation tasks (Jira/Linear) per roadmap phases.
- Stand up monitoring dashboards (Prometheus/Grafana + Sentry) ahead of MVP.
- Formalize data-sharing agreements and privacy disclosures before public launch.

All sample data, names, and locations are fictional and labeled as SAMPLE/SEED.
