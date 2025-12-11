# Moderation & Escalation Blueprint

## Automatic Triage Rules
- Keyword sets: `life-threatening`, `GBV`, `hate speech`, `infrastructure`, `health`. Weighted scoring + AI classifier.
- Duplicate detection via 60% text similarity + 2km geo proximity.
- Tamper detection: EXIF mismatch, checksum change, video frame anomalies.

## Queues
1. **Auto-triage:** machine-labeled priority, not visible publicly.
2. **Community witness:** open for verified witnesses; requires 3 confirmations or 2 conflicting votes to escalate.
3. **Staff moderation:** admin panel displays flags, AI rationale, recommended action.
4. **Sensitive (political/ethnic):** requires dual review, optional legal counsel.

## Escalation Pipeline
- `critical` severity -> immediate SMS/push to designated gov/NGO contacts with sanitized summary.
- `life-threatening` -> auto-open case in government dashboard, send callout to nearest partner via Redis Geo query.
- Journalists can set "press embargo"; system hides report from public map until embargo lifted.
- Reports flagged as hate speech/doxxing require manual approval before any external sharing.

## Moderator Tools
- Evidence integrity checker (hash + metadata timeline).
- Redaction UI for faces, license plates, names.
- Request-more-info button pings reporter anonymously.
- Blacklist management (devices, IPs, malicious keywords) with expiry.

## Rate Limits & Fraud
- Per-device: 5 high-severity reports / hour.
- SMS gateway: OTP throttle 3 attempts / 10 min.
- Automated heuristics: block repeated identical media, escalate suspicious clusters.

## Audit & Transparency
- All moderator decisions logged with reason, timestamp, reviewer ID.
- Quarterly transparency report summary auto-generated from `events_log` & `flags` tables.
