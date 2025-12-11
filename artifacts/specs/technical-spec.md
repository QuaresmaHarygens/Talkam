# Talkam Liberia Technical Specification

## Platforms
- **Client:** Flutter 3 (mobile/web) using Riverpod + Freezed models, modular feature packages (auth, reports, verification, dashboards, analytics).
- **Offline Store:** encrypted Hive boxes for drafts/media references, Sqlite via Drift for cached feed + lookup tables. Background isolate handles sync using exponential backoff.
- **Web Dashboard:** Flutter Web for NGOs/government/admin, responsive layout, supports keyboard shortcuts and screen reader semantics.

## Backend Stack
- **Framework:** FastAPI + Pydantic models. Async workers via Celery (Redis backend) for media processing, AI triage, notifications.
- **Auth:** JWT (RS256) with refresh tokens. Anonymous mode issues expiring token referencing row in `anonymous_tokens`. Device attestation (SafetyNet/Apple App Attest) recorded in `events_log`.
- **Transport Security:** TLS 1.3 enforced, mTLS optional for partner webhooks.
- **Storage:** PostgreSQL with cryptographic columns (pgcrypto) for PII. S3 buckets per environment with default SSE-KMS. Redis for caching feed queries, offline sync leases, rate limiting.
- **Search & Geo:** Elasticsearch for text + geo distance queries, powering heatmaps and duplicate detection.
- **Messaging:** Redis Streams for lightweight fan-out; RabbitMQ for CPU/GPU heavy tasks (e.g., Whisper transcription, video anonymization).
- **Notifications:** Firebase Cloud Messaging + APNs, Twilio/Orange SMPP for SMS fallback. Geofence computations via PostGIS + Redis Geo.

## Feature Modules
1. **Onboarding & Permissions**
   - Localized copy (Liberian English). Privacy sheet explains encryption, optional contact fields, emergency delete workflow.
2. **Report Capture**
   - Category taxonomy stored in `events_log` for analytics; dynamic chips delivered via `/config`. Severity dial slider modifies default escalation.
   - Media pipeline compresses photos (<250KB), blurs faces client-side using MLKit, applies hashed filename before upload.
3. **Audio-only Mode**
   - Offline recorder with noise reduction, voice scramble filter (pitch shift + low-pass). Whisper model transcription executed server-side; client allows edits before submission.
4. **Feed & Map**
   - Combined timeline with urgency scoring. Map overlay uses vector tiles from Mapbox/MapLibre with offline basemap fallback. Heatmap uses aggregated Elasticsearch tiles.
5. **Verification Flow**
   - Community witnesses submit confirmations; once threshold met + AI score high, status auto-updates pending moderator review. Media authenticity checks run asynchronously.
6. **Dashboards**
   - NGO/Journo: filterable tables, follow-up requests, PDF exports, saved searches.
   - Government: case assignments, timeline updates, official document uploads.
   - Admin: flags queue, RBAC, audit viewer, evidence integrity tool (hash comparison).
7. **Alerts & Broadcasts**
   - Crisis modules push to radius-based segments. SMS fallback triggered when device did not acknowledge push.
8. **Analytics**
   - Events forwarded to ClickHouse via Kafka/Redpanda for near-real-time dashboards; aggregated metrics cached for mobile-friendly cards.

## Offline & Low-Bandwidth Strategies
- Delta sync endpoints (`/reports/sync?since=`). Batches limited to 200 KB per response.
- Progressive media loading: thumbnails first (WebP), high-res on demand.
- SMS fallback messages compressed using key-value codes (e.g., `CAT=roadblock;LOC=bensonville`).

## Safety & Compliance
- Automatic redaction for phone numbers detected in text fields.
- Right-to-be-forgotten queue ensures media deletion + DB tombstones.
- RBAC roles: citizen, reporter, NGO, journalist, government, admin, superadmin.
- Audit log events signed with HMAC for tamper detection.

## Sample cURL Commands
```sh
curl -X POST https://api.talkamliberia.org/v1/auth/anonymous-start \
  -H 'Content-Type: application/json' \
  -d '{"device_hash":"abc123","county":"Montserrado"}'

curl -X POST https://api.talkamliberia.org/v1/reports/create \
  -H 'Authorization: Bearer <token>' \
  -H 'Content-Type: application/json' \
  -d '{"category":"infrastructure","summary":"SAMPLE: road blocked","location":{"latitude":6.29,"longitude":-10.76,"county":"Montserrado"}}'
```

## Component Library Snapshot
- Buttons: primary (Sunrise Amber), secondary (Mano River Blue), tertiary (outline). States: default, loading (spinner), disabled (40% opacity).
- Cards: standard (elevation 1), alert (Clay Terracotta border), verification (Kpelle Green badge).
- Lists: feed card, map pin tooltip, dashboard table row with urgency pill.
- Modals: 320px mobile sheet, 520px desktop dialog; traps focus, includes "quick hide" panic button.

## Accessibility
- WCAG AA color contrast validated.
- Voice prompts for key flows, text scaling up to 200%.
- Screen reader labels added to severity dial, witness slider, toggle switches.

## Localization Hooks
- JSON locale bundles (`en-LR`, `kpe-LR`, `bas-LR`).
- All copy references translation keys (e.g., `onboarding.trust_header`).
- Date/time formatted using `intl` package with 12/24h toggle.
