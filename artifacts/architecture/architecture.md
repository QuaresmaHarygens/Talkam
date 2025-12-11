# Talkam Liberia Architecture Spec

## Overview
Talkam Liberia is a privacy-first incident reporting platform optimized for Liberia's mixed connectivity environments. It delivers mobile (Flutter) and web experiences backed by a FastAPI service mesh, PostgreSQL data plane, and asynchronous workers for media processing, AI triage, and notifications.

## Principles
- **Safety-first:** anonymous tokens, encrypted payloads, RBAC admin controls.
- **Offline-first:** local queue, delta sync, SMS gateway fallback.
- **Modular:** clear service boundaries for auth, reporting, verification, and analytics.
- **Observable:** centralized logging, metrics, and audit trails.

## Logical Components
1. **Client Layer**
   - Flutter mobile apps (Android/iOS) with offline store (Sqlite + encrypted Hive boxes).
   - Responsive web dashboards (Flutter Web) for NGOs, government, admins.
   - SMS/USSD ingestion gateway for feature phone submissions.
2. **Edge & API Gateway**
   - CDN + WAF (CloudFront/Akamai) with rate limiting and bot mitigation.
   - API Gateway terminating TLS, routing to FastAPI pods, issuing signed upload URLs.
3. **Core Services (FastAPI)**
   - **Auth Service:** JWT issuance, anonymous token minting, MFA, device attestation.
   - **Reporting Service:** CRUD for reports, media orchestration, offline sync endpoints, search proxies to Elasticsearch.
   - **Verification Service:** handles witness confirmations, NGO/gov workflows, AI scoring.
   - **Notification Service:** push/SMS/email dispatch, geofence logic using Redis Geo.
   - **Admin Service:** moderation queues, role management, audit logging.
4. **Data & Storage**
   - PostgreSQL 14 (primary), read replicas for analytics.
   - Redis Cluster for caching, offline sync status, job queues (RQ/Celery).
   - RabbitMQ (optional) for long-running media/AI tasks.
   - S3-compatible object storage (MinIO or AWS S3) with envelope encryption.
   - Elasticsearch/OpenSearch for full-text, geo heatmaps, duplicate detection.
5. **AI/ML Layer**
   - Hosted Whisper/DeepSpeech for transcription with offline fallback.
   - Image authenticity/Tamper detection (e.g., AWS Rekognition custom labels) invoked asynchronously.
   - NLP triage for severity classification.
6. **Observability & Security**
   - Prometheus + Grafana dashboards, Loki/Sentry for logs, Trivy in CI for container scanning.
   - Vault/KMS for key management, per-tenant encryption keys.

## Data Flow (Narrative)
1. User composes a report while offline → queued locally → upon connectivity, client requests `/auth/anonymous-start` or refreshes JWT → uploads media via pre-signed URLs → submits metadata via `/reports/create`.
2. API persists report, stores encrypted PII, pushes job onto Redis Queue for AI triage and verification hints.
3. Workers enrich report, update status, trigger notifications (FCM/SMS) for subscribed NGOs/gov agencies using geofence filters.
4. Moderators use admin dashboard to review flags, escalate, or publish. Actions are logged to `events_log` and analytics events forwarded to ClickHouse/BigQuery sink for dashboards.

## Deployment Topology
- Kubernetes cluster (EKS/GKE) with separate namespaces: `edge`, `api`, `workers`, `analytics`.
- Blue/green deployments via GitHub Actions → container registry → Argo CD.
- Multi-AZ PostgreSQL with streaming replication; Redis + RabbitMQ in HA mode.
- Media storage in S3 with lifecycle rules (cold storage after 180 days unless flagged).
- Disaster recovery via daily snapshots, cross-region replication, IaC (Terraform) for reproducibility.

## Interfaces
- REST + WebSocket for realtime feed updates and verification prompts.
- gRPC internal calls between services (optional) for high throughput tasks.
- Webhooks for partner NGOs/gov CRMs and SMS aggregator callbacks.

## Scaling Considerations
- Shard report ingestion by county to reduce contention.
- Use Redis GeoHash and Elasticsearch per-county indexes for heatmaps.
- GPU-enabled worker pool for AI inference bursts.
- Feature flags service (e.g., Unleash) for phased launches.

## Compliance & Governance
- Data residency configurable (AWS AFR IC West or Gov Cloud if required).
- Audit-ready logs for transparency; chain-of-custody metadata on evidence files.
- GDPR-like controls: right to erasure, consent tracking, retention windows.

## External Integrations
- SMS Gateway (e.g., Orange Liberia, Lonestar MTN) via SMPP.
- Payment/Subscription for NGOs through regional payment processors (Flutterwave/MFS Africa).
- Media verification API hooks (e.g., Truepic) for advanced authenticity checks.
