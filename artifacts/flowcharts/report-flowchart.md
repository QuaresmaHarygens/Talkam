# Talkam Liberia Report Lifecycle Flow

1. **Report Intake**
   - Entry points: mobile app (online/offline), SMS gateway, web form, NGO bulk upload.
   - Data captured: category, severity, media, location, anonymity flag, witness count.
2. **Local Safeguards**
   - Client-side encryption of sensitive fields.
   - Offline queue retains up to 50 reports; auto purge after successful sync or emergency delete.
3. **API Validation**
   - JWT/anonymous token check.
   - Schema validation, dedupe check via Elasticsearch fuzzy matching.
4. **Storage & Encryption**
   - PII encrypted with per-user keys.
   - Media stored via signed URL; metadata logged to `report_media`.
5. **AI & Rules Triage**
   - Severity classifier, violence keyword detection, deepfake/tamper scoring.
   - Auto-tagging for categories, recommended responders.
6. **Moderation Queue**
   - Flags for hate speech, doxxing, sensitive political content.
   - Community witness confirmations aggregated.
7. **Verification Outcomes**
   - Status transitions: `submitted` → `triaged` → `verified`/`needs-info`/`rejected`.
   - NGO/gov dashboards receive tasks; journalists can request embargoed access.
8. **Responder Actions**
   - Assign case owner, update response timeline, upload official docs, push public statements.
9. **Feedback & Analytics**
   - Reporter notified (if opted-in) of status.
   - Data feeds analytics dashboards, exports, and alerts.
10. **Retention & Closure**
   - Auto archive after retention period unless evidence locked for legal hold.
   - `events_log` captures final actions for audit.
