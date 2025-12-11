# Security & Privacy Spec

## Threat Model
- **Actors:** malicious users (spam, disinfo), hostile state actors, compromised admins, network eavesdroppers, device theft.
- **Assets:** reporter identity, media evidence, location metadata, verification decisions, audit logs.
- **Attack Vectors:** phishing, SIM swap, credential stuffing, fake reports, tampered media, API abuse, SMS interception.

## Controls
1. **Auth & Identity**
   - JWT (RS256) with rotating keys.
   - Anonymous tokens stored with minimal metadata, encrypted using key derived from device hash + server secret.
   - Optional MFA via SMS or TOTP for power users/admins.
2. **Encryption**
   - TLS 1.3 everywhere, HSTS.
   - At rest: pgcrypto columns for PII (`phone`, `email`), S3 bucket SSE-KMS + client-side encryption for sensitive attachments.
   - End-to-end: optional double-encrypted payload for "high-risk" reports using libsodium sealed boxes.
3. **Voice & Media Safety**
   - Client-side face blurring + watermark detection.
   - Masked voice option using server-side DSP.
4. **Moderation & Escalation**
   - ML + rules detect hate speech, violent incitement, doxxing keywords.
   - Escalation path: auto-route life-threatening reports to trusted responders (NGO/government) while still awaiting human moderation for public feed.
   - Embargo flag keeps reports private for journalists until cleared.
5. **Data Retention**
   - Default retention 24 months; high-risk data auto-archived after 90 days unless legally required.
   - Right-to-be-forgotten workflow purges PII + media, keeps hashed stub for dedupe.
6. **Emergency Delete**
   - Panic gesture wipes local drafts, invalidates tokens, notifies backend to purge queued data.
7. **Audit & Logging**
   - `events_log` immutable append-only (WORM storage snapshot nightly).
   - Admin actions require reason codes; dual approval for role changes.
8. **Compliance Checklist**
   - GDPR-inspired consent & erasure, OWASP MASVS mobile controls, WCAG AA, ISO 27001 controls mapped, Liberian data protection draft bill alignment.
9. **Rate Limiting & Fraud Detection**
   - IP/device throttling, SMS OTP attempt limits, anomaly detection on report frequency.
10. **Incident Response**
   - 24/7 alerting via PagerDuty, runbooks for leak, DDoS, moderation abuse.

## Moderation Workflow
- Multi-level queue (auto, community, staff, escalations).
- Evidence integrity tool checks EXIF, hashes, duplicates across `report_media`.
- Flags categories: `policy_violation`, `spam`, `legal_hold`, `press_embargo`.

## Privacy Safeguards
- Differential privacy for aggregate analytics before sharing publicly.
- Consent management: log acceptance of privacy policy, SMS fallback T&Cs.
- Localization ensures plain-language privacy text in Liberian English.
