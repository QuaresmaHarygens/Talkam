# Deployment & DevOps Plan

## CI/CD
- GitHub Actions pipeline stages:
  1. **lint-test:** run `flutter analyze`, `pytest`, security linters (bandit), schema lint (`sqlfluff`).
  2. **build:** build Flutter APK/AAB/IPA + web bundle, Docker images for API/workers.
  3. **scan:** Snyk/Trivy scans, OWASP ZAP baseline.
  4. **deploy:** push to container registry, trigger Argo CD sync to staging/prod with blue/green strategy.
- Feature branches deploy to ephemeral preview environments (Kubernetes namespace + temporary DB schema) for stakeholder reviews.

## Hosting
- Primary cloud: AWS (EKS, RDS, S3, ElastiCache, OpenSearch). Abstraction via Terraform modules allows migration to GCP/Azure or on-prem (Kubernetes + MinIO + Postgres clusters).
- CDN/WAF: CloudFront + AWS WAF or Cloudflare for DDoS mitigation and caching static assets.

## Backup & DR
- PostgreSQL: PITR via WAL-G to S3, daily logical dumps stored 30 days.
- Redis: snapshot every 15 minutes, replicated across AZs.
- S3 media: versioning + lifecycle to Glacier after 180 days.
- Disaster runbook: restore infrastructure via Terraform, redeploy containers, replay WALs, validate health checks.

## Monitoring & Logging
- Prometheus scraping app + infra metrics; Grafana dashboards for ingestion latency, queue depth, push success rates.
- Sentry for client/server error tracking with PII scrubbing.
- Loki or CloudWatch for centralized logs; log retention 30 days hot, 1 year cold storage.
- Synthetic monitoring (Checkly/UptimeRobot) from Monrovia, Accra, Lisbon to simulate low bandwidth.

## Operations
- Infrastructure-as-code enforcement (terraform plan in PRs).
- Secrets via HashiCorp Vault; short-lived tokens injected to pods with Vault Agent.
- Blue/green + canary rollouts for mobile API change compatibility.
- Maintenance windows coordinated with civil society partners; SMS notifications for planned downtime.
