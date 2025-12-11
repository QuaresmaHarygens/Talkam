# QA & Testing Plan

## Test Strategy
- **Unit Tests:** Pydantic validators, service logic (auth, report creation, verification scoring). Flutter unit tests for blocs/providers.
- **Integration Tests:** API contract tests via pytest + httpx, database migrations, offline sync flows with mocked connectivity.
- **Security Tests:** OWASP ASVS checklist, API fuzzing, dependency scanning, penetration testing on staging, SMS spoof tests.
- **Performance Tests:** k6 load tests for `/reports/create`, WebSocket feed fan-out, offline sync throughput on 3G profiles.
- **User Testing:** 15-person script (8 urban, 7 rural) covering onboarding clarity, offline queue success, trust perception.

## Sample Unit Tests
1. `test_report_requires_location()` ensures missing coordinates reject submission.
2. `test_anon_token_expiry()` verifies tokens older than 24h invalid.
3. `test_voice_mask_flag()` ensures masked audio flagged before publish.

## Sample Integration Tests
- Submit report → attach media → verify timeline updates.
- NGO dashboard CSV export matches DB row count.
- Admin flag resolution triggers audit log entry.

## Security Testing Checklist
- [ ] SQL injection & ORM bypass.
- [ ] JWT replay & kid header tampering.
- [ ] Broken access control (role escalation attempts).
- [ ] Insecure direct object references on `/reports/{id}`.
- [ ] File upload validation (MIME sniffing, size limits, antivirus scan).
- [ ] SMS gateway spoof / OTP brute force.
- [ ] Offline cache encryption and panic delete verification.

## User Testing Script (15 participants)
1. Explain purpose, consent for recording.
2. Scenario: market vendor reports road blockage with photo.
3. Ask participant to enable anonymous mode, capture photo, queue offline, reconnect to sync.
4. Scenario: anonymous witness records voice note, masks voice, reviews transcription.
5. Scenario: NGO investigator filters feed, downloads verified report.
6. Gather feedback on trust, wording, ease of use.
7. Document issues, severity, proposed fixes.
