# Talkam Liberia - Comprehensive Upgrade Plan

## Executive Summary

This document compares the current Talkam Liberia implementation with the new production-ready requirements and provides a detailed upgrade strategy.

## Current System Analysis

### ✅ What's Already Built

#### Backend (FastAPI + PostgreSQL)
- **Status**: Production-ready ✅
- **Tech Stack**: FastAPI, PostgreSQL, Redis, S3-compatible storage
- **Features Implemented**:
  - JWT authentication + anonymous tokens
  - Report CRUD with media uploads
  - Location tracking (GPS, county, district)
  - Community verification system
  - Admin dashboard API
  - NGO/Government dashboards
  - Alert broadcasting (SMS/Push stubs)
  - Offline sync endpoints
  - Analytics dashboard API
  - Rate limiting & security middleware
  - Health checks & monitoring
  - Database migrations (Alembic)
  - Test coverage

#### Mobile App (Flutter)
- **Status**: Scaffolded, partially implemented ✅
- **Features Implemented**:
  - API client integration
  - Offline storage (Hive + Drift)
  - Login/Registration screens
  - Report creation flow
  - Location services
  - Media capture/upload
  - Basic UI/UX implementation

#### Admin Dashboard (React + TypeScript)
- **Status**: Functional ✅
- **Features Implemented**:
  - Analytics dashboard
  - Report management
  - Alert broadcasting
  - User management
  - Report filtering & export (CSV)

### ❌ What's Missing (New Requirements)

#### Critical Gaps
1. **Web Application**: No Next.js web app (only mobile + admin dashboard)
2. **Firebase Backend**: Currently using FastAPI + PostgreSQL (different stack)
3. **AI Features**: No automated categorization, priority scoring, fake detection
4. **Advanced Security**: No zero-knowledge encryption, field-level encryption
5. **Blockchain Anchoring**: Not implemented
6. **Voice Reporting**: Not implemented
7. **Pidgin Language Support**: Not implemented
8. **Dead-Man's Switch**: Not implemented
9. **Evidence Chain-of-Custody**: Basic implementation, needs enhancement
10. **Public Transparency Dashboard**: Not implemented
11. **Institutional Integrations**: Not implemented
12. **Tor-Friendly Submission**: Not implemented

## Upgrade Strategy: Hybrid Approach

### Option A: Full Migration to Firebase (Recommended for New Requirements)
**Pros**: Matches new spec exactly, Firebase scalability, real-time features
**Cons**: Complete rewrite, data migration needed, learning curve

### Option B: Enhance Current Stack (Recommended for Incremental Upgrade)
**Pros**: Leverage existing code, faster implementation, proven stack
**Cons**: Doesn't match new spec exactly, need to add Firebase as optional layer

### Option C: Hybrid Architecture (Best of Both Worlds) ⭐ RECOMMENDED
**Pros**: 
- Keep existing FastAPI backend (proven, production-ready)
- Add Next.js web app for public-facing features
- Add Firebase for real-time features and optional cloud functions
- Incremental migration path
- Support both stacks during transition

**Implementation Plan**:
1. **Phase 1**: Add Next.js web app, enhance current backend
2. **Phase 2**: Add Firebase as optional layer, implement AI features
3. **Phase 3**: Advanced features (blockchain, zero-knowledge encryption)

## Detailed Upgrade Plan

### Phase 1: Foundation (Weeks 1-4) - MVP Enhancement

#### 1.1 Next.js Web Application
**Priority**: HIGH
**Status**: Not Started

**Tasks**:
- [ ] Scaffold Next.js 14 app with App Router
- [ ] Set up Tailwind CSS
- [ ] Implement responsive, mobile-first design
- [ ] Create landing page
- [ ] Build report submission flow (anonymous & identified)
- [ ] Implement tracking page with unique report IDs
- [ ] Add Pidgin language support (i18n)
- [ ] Integrate with existing FastAPI backend

**Files to Create**:
```
web-app/
├── app/
│   ├── (public)/
│   │   ├── page.tsx              # Landing page
│   │   ├── submit/
│   │   │   └── page.tsx          # Report submission
│   │   └── track/
│   │       └── [reportId]/
│   │           └── page.tsx      # Tracking page
│   ├── (admin)/
│   │   └── dashboard/
│   │       └── page.tsx          # Admin dashboard
│   └── api/                       # API routes (proxy to FastAPI)
├── components/
│   ├── ReportForm.tsx
│   ├── EvidenceUpload.tsx
│   └── TrackingStatus.tsx
├── lib/
│   ├── api.ts                    # API client
│   ├── i18n.ts                   # Internationalization
│   └── encryption.ts             # Client-side encryption helpers
└── public/
```

#### 1.2 Enhance Backend API
**Priority**: HIGH
**Status**: Partially Complete

**Tasks**:
- [x] Unique report IDs (RPT-YYYY-XXXXXX format)
- [ ] Evidence hash computation (SHA256)
- [ ] EXIF metadata stripping/preservation
- [ ] Tamper-evidence hash storage
- [ ] Enhanced audit logging
- [ ] Export functionality (CSV/PDF with signatures)
- [ ] Public tracking endpoint (no auth required)

**Files to Modify**:
- `backend/app/api/reports.py` - Add hash computation, export
- `backend/app/models/core.py` - Add hash fields
- `backend/app/services/storage.py` - Add EXIF handling
- `backend/app/services/audit.py` - New audit service

#### 1.3 Offline & Low-Bandwidth Support
**Priority**: MEDIUM
**Status**: Partially Complete (mobile only)

**Tasks**:
- [ ] Web: IndexedDB for draft storage
- [ ] Resumable uploads (tus protocol or chunked)
- [ ] Image compression on client
- [ ] SMS fallback integration (Twilio)
- [ ] Offline queue management

**Files to Create**:
- `web-app/lib/offline.ts` - Offline storage utilities
- `web-app/lib/upload.ts` - Resumable upload client
- `backend/app/api/sms.py` - Enhance SMS ingestion

### Phase 2: AI & Automation (Weeks 5-10)

#### 2.1 AI Categorization & Priority Scoring
**Priority**: HIGH
**Status**: Not Started

**Tasks**:
- [ ] OpenAI integration for categorization
- [ ] Priority scoring algorithm (0-1 scale)
- [ ] Recommended agency matching
- [ ] Fake/spam detection classifier
- [ ] Legal guidance generation (with disclaimers)

**Files to Create**:
```
backend/app/services/
├── ai/
│   ├── categorization.py         # Category + priority scoring
│   ├── spam_detection.py         # Fake/spam detection
│   └── legal_guidance.py         # Legal advice generation
└── prompts/
    ├── categorization.txt
    ├── spam_detection.txt
    └── legal_guidance.txt
```

**Implementation**:
```python
# backend/app/services/ai/categorization.py
import openai
from app.config import Settings

async def categorize_report(
    text: str,
    location: dict,
    settings: Settings
) -> dict:
    """Categorize report and assign priority score."""
    prompt = f"""
    User report: {text}
    Location: {location.get('county', 'Unknown')}
    
    Identify:
    1. Category from [Corruption, GBV, Public Service, Human Rights, Other]
    2. Priority score (0-1, where 1 is most urgent)
    3. Recommended agency
    4. One-sentence reason
    
    Respond in JSON format.
    """
    
    response = await openai.ChatCompletion.acreate(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3
    )
    
    return parse_ai_response(response)
```

#### 2.2 Voice Reporting
**Priority**: MEDIUM
**Status**: Not Started

**Tasks**:
- [ ] Web Speech API integration
- [ ] Audio recording component
- [ ] Transcription service (Whisper API or local)
- [ ] Human review queue for voice reports

**Files to Create**:
- `web-app/components/VoiceRecorder.tsx`
- `web-app/lib/transcription.ts`
- `backend/app/services/transcription.py`

### Phase 3: Advanced Security & Features (Weeks 11-18)

#### 3.1 Zero-Knowledge Encryption
**Priority**: HIGH (for sensitive reports)
**Status**: Not Started

**Tasks**:
- [ ] Client-side encryption for reporter identity
- [ ] Field-level encryption helpers
- [ ] KMS integration (AWS/GCP) for key management
- [ ] Multi-party decryption (M-of-N) for admins
- [ ] Protected mode toggle

**Files to Create**:
```
backend/app/services/
├── encryption/
│   ├── field_encryption.py       # Field-level encryption
│   ├── kms_client.py             # KMS integration
│   └── key_management.py         # Key rotation, M-of-N
web-app/lib/
└── encryption.ts                 # Client-side encryption
```

#### 3.2 Blockchain Anchoring
**Priority**: LOW (optional)
**Status**: Not Started

**Tasks**:
- [ ] IPFS integration for evidence storage
- [ ] Ethereum/Solana proof-of-existence
- [ ] Hash anchoring service
- [ ] Verification endpoint

**Files to Create**:
- `backend/app/services/blockchain/anchor.py`
- `backend/app/api/blockchain.py`

#### 3.3 Community Verification Enhancement
**Priority**: MEDIUM
**Status**: Basic implementation exists

**Tasks**:
- [ ] Reputation system for verifiers
- [ ] Weighted verification scoring
- [ ] Proximity-based verification
- [ ] Witness upload functionality

**Files to Modify**:
- `backend/app/api/verifications.py` - Enhance existing
- `backend/app/models/core.py` - Add reputation fields

#### 3.4 Dead-Man's Switch
**Priority**: MEDIUM
**Status**: Not Started

**Tasks**:
- [ ] Time-based trigger configuration
- [ ] Event-based trigger (status change)
- [ ] NGO selection for recipients
- [ ] Encrypted package generation
- [ ] Automated delivery system

**Files to Create**:
- `backend/app/services/deadmans_switch.py`
- `backend/app/api/deadmans_switch.py`

### Phase 4: Integrations & Transparency (Weeks 19-24)

#### 4.1 Public Transparency Dashboard
**Priority**: MEDIUM
**Status**: Not Started

**Tasks**:
- [ ] Public metrics aggregation (anonymized)
- [ ] Heatmap by county/municipality
- [ ] Charts: category distribution, resolution rates
- [ ] Public API for data export

**Files to Create**:
```
web-app/app/
└── (public)/
    └── transparency/
        ├── page.tsx              # Public dashboard
        └── api/
            └── metrics.ts        # Public metrics API
```

#### 4.2 Institutional Integrations
**Priority**: MEDIUM
**Status**: Not Started

**Tasks**:
- [ ] Pre-built connectors (LACC, Ministry of Justice, Police)
- [ ] Webhook system for status updates
- [ ] RSS feed generation
- [ ] Organization verification flow
- [ ] API keys for partner access

**Files to Create**:
- `backend/app/services/integrations/`
- `backend/app/api/integrations.py`

#### 4.3 Evidence Chain-of-Custody
**Priority**: HIGH
**Status**: Basic implementation exists

**Tasks**:
- [ ] Enhanced metadata capture
- [ ] Signed audit logs
- [ ] Evidence package generation (ZIP + manifest)
- [ ] Court-ready export format
- [ ] Integrity verification

**Files to Modify**:
- `backend/app/services/evidence.py` - Enhance existing
- `backend/app/api/export.py` - Add evidence packages

## Migration Strategy: Current → New

### Database Schema Updates

**New Fields Needed**:
```sql
-- Reports table additions
ALTER TABLE reports ADD COLUMN report_id VARCHAR(20) UNIQUE;
ALTER TABLE reports ADD COLUMN priority_score DECIMAL(3,2);
ALTER TABLE reports ADD COLUMN ai_category VARCHAR(50);
ALTER TABLE reports ADD COLUMN recommended_agency VARCHAR(100);
ALTER TABLE reports ADD COLUMN hash_anchored_on_chain TEXT;
ALTER TABLE reports ADD COLUMN legal_advice_snapshot TEXT;
ALTER TABLE reports ADD COLUMN is_likely_fake BOOLEAN DEFAULT FALSE;
ALTER TABLE reports ADD COLUMN fake_confidence DECIMAL(3,2);

-- Evidence hash table
CREATE TABLE report_hashes (
    id UUID PRIMARY KEY,
    report_id UUID REFERENCES reports(id),
    evidence_id UUID REFERENCES report_media(id),
    hash_sha256 VARCHAR(64) NOT NULL,
    anchored_on_chain BOOLEAN DEFAULT FALSE,
    chain_tx_hash TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Audit logs (immutable)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY,
    actor_id UUID REFERENCES users(id),
    actor_type VARCHAR(20), -- 'admin', 'system', 'user'
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50), -- 'report', 'user', 'evidence'
    resource_id UUID,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL
) PARTITION BY RANGE (created_at);

-- Dead-man's switch
CREATE TABLE deadmans_switches (
    id UUID PRIMARY KEY,
    report_id UUID REFERENCES reports(id),
    reporter_id UUID REFERENCES users(id),
    ngo_id UUID REFERENCES ngos(id),
    trigger_type VARCHAR(20), -- 'time', 'event', 'manual'
    trigger_config JSONB,
    status VARCHAR(20) DEFAULT 'active',
    triggered_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### API Endpoint Additions

**New Endpoints Needed**:
```python
# backend/app/api/reports.py additions
POST /v1/reports/{report_id}/hash/anchor  # Anchor hash on blockchain
GET /v1/reports/track/{report_id}         # Public tracking (no auth)
POST /v1/reports/{report_id}/export        # Generate evidence package

# backend/app/api/ai.py (new file)
POST /v1/ai/categorize                     # AI categorization
POST /v1/ai/detect-spam                   # Spam detection

# backend/app/api/blockchain.py (new file)
POST /v1/blockchain/anchor                 # Anchor report hash
GET /v1/blockchain/verify/{tx_hash}        # Verify anchor

# backend/app/api/deadmans_switch.py (new file)
POST /v1/deadmans-switch/create
POST /v1/deadmans-switch/trigger/{id}
GET /v1/deadmans-switch/{id}

# backend/app/api/transparency.py (new file)
GET /v1/transparency/metrics              # Public metrics
GET /v1/transparency/heatmap               # Heatmap data
GET /v1/transparency/export                # Anonymized dataset
```

## Technology Stack Comparison

### Current vs Required

| Component | Current | Required | Action |
|-----------|---------|----------|--------|
| **Web Frontend** | React (Vite) | Next.js 14 | ✅ Create new |
| **Mobile App** | Flutter | Flutter (keep) | ✅ Keep & enhance |
| **Backend API** | FastAPI + PostgreSQL | Firebase OR Node.js/Express | ⚠️ Add optional Firebase layer |
| **Database** | PostgreSQL | Firestore OR PostgreSQL | ✅ Keep PostgreSQL, add Firestore sync |
| **Storage** | S3-compatible | Firebase Storage OR S3 | ✅ Keep S3, add Firebase option |
| **Auth** | JWT | Firebase Auth | ⚠️ Add Firebase Auth as option |
| **Real-time** | None | Firebase Realtime | ✅ Add Firebase |
| **AI/ML** | None | OpenAI + embeddings | ✅ Add new |
| **Blockchain** | None | IPFS + Ethereum/Solana | ✅ Add optional |
| **Encryption** | Basic | Zero-knowledge + KMS | ✅ Enhance |

### Recommended Hybrid Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Client Layer                          │
├─────────────────────────────────────────────────────────┤
│  Next.js Web App  │  Flutter Mobile  │  Admin Dashboard │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    API Gateway Layer                     │
│  (FastAPI - Primary)  │  (Firebase Functions - Optional)│
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ PostgreSQL   │  │  Firestore   │  │  Redis Cache │
│ (Primary DB) │  │  (Sync/Real- │  │  (Sessions)  │
│              │  │   time Data)  │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
        │                 │
        ▼                 ▼
┌──────────────┐  ┌──────────────┐
│   S3 Storage │  │ Firebase     │
│   (Evidence) │  │ Storage      │
│              │  │ (Backup)     │
└──────────────┘  └──────────────┘
```

## Implementation Priority Matrix

### Must Have (Phase 1)
1. ✅ Next.js web application
2. ✅ Enhanced report IDs (RPT-YYYY-XXXXXX)
3. ✅ Evidence hash computation
4. ✅ Public tracking page
5. ✅ Export functionality (CSV/PDF)
6. ✅ Offline draft storage (web)
7. ✅ SMS fallback

### Should Have (Phase 2)
1. ✅ AI categorization & priority scoring
2. ✅ Voice reporting
3. ✅ Pidgin language support
4. ✅ Enhanced community verification
5. ✅ Public transparency dashboard

### Nice to Have (Phase 3)
1. ✅ Zero-knowledge encryption
2. ✅ Blockchain anchoring
3. ✅ Dead-Man's Switch
4. ✅ Institutional integrations
5. ✅ Tor-friendly submission

## Acceptance Criteria

### Phase 1 Acceptance
- [ ] User can submit report via web app (anonymous & identified)
- [ ] User receives unique report ID (RPT-YYYY-XXXXXX)
- [ ] User can track report status publicly
- [ ] Evidence files have SHA256 hashes stored
- [ ] Admin can export reports (CSV/PDF)
- [ ] Offline drafts save and restore
- [ ] SMS submission works

### Phase 2 Acceptance
- [ ] AI categorization accuracy >80%
- [ ] Priority scores assigned automatically
- [ ] Voice reports transcribed and categorized
- [ ] Pidgin language UI available
- [ ] Community verification with reputation
- [ ] Public dashboard shows anonymized metrics

### Phase 3 Acceptance
- [ ] Zero-knowledge encryption for sensitive fields
- [ ] Report hashes anchored on blockchain
- [ ] Dead-Man's Switch triggers correctly
- [ ] Evidence packages verified and signed
- [ ] Institutional webhooks deliver updates

## Next Steps

1. **Review & Approve Plan**: Stakeholder review of upgrade strategy
2. **Set Up Development Environment**: 
   - Initialize Next.js project
   - Set up Firebase project (optional)
   - Configure OpenAI API keys
3. **Begin Phase 1 Implementation**: Start with Next.js web app
4. **Parallel Development**: 
   - Web app team: Next.js frontend
   - Backend team: API enhancements
   - Mobile team: Feature parity
5. **Testing & QA**: Continuous testing as features are added
6. **Deployment**: Gradual rollout with feature flags

## Risk Mitigation

1. **Data Migration**: Plan for zero-downtime migration if moving to Firebase
2. **Performance**: Monitor API performance as features are added
3. **Security**: Security audit before enabling zero-knowledge encryption
4. **Cost**: Monitor Firebase/OpenAI costs, set up billing alerts
5. **Compatibility**: Ensure mobile app works with new API endpoints

## Conclusion

The current Talkam Liberia system has a solid foundation with FastAPI backend, Flutter mobile app, and React admin dashboard. The upgrade plan focuses on:

1. **Adding Next.js web app** for public-facing features
2. **Enhancing existing backend** with AI, security, and advanced features
3. **Optional Firebase layer** for real-time features
4. **Incremental migration** to minimize risk

This hybrid approach allows us to leverage existing code while meeting new requirements, with a clear path to full migration if needed.














