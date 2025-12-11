# Talkam Liberia - Phase 1 Implementation Guide

## Quick Start: Next.js Web Application

### Step 1: Initialize Next.js Project

```bash
cd /Users/visionalventure/Watch\ Liberia
npx create-next-app@latest web-app --typescript --tailwind --app --no-src-dir --import-alias "@/*"
cd web-app
npm install
```

### Step 2: Install Required Dependencies

```bash
# Core dependencies
npm install @tanstack/react-query axios zod
npm install react-hook-form @hookform/resolvers
npm install next-intl  # For i18n (Pidgin support)
npm install date-fns

# UI components
npm install @headlessui/react @heroicons/react
npm install react-dropzone  # For file uploads

# Encryption (for zero-knowledge features)
npm install crypto-js @noble/ciphers

# Offline support
npm install idb  # IndexedDB wrapper

# Development
npm install -D @types/node @types/react @types/react-dom
```

### Step 3: Project Structure

```
web-app/
├── app/
│   ├── layout.tsx                 # Root layout
│   ├── page.tsx                   # Landing page
│   ├── (public)/
│   │   ├── submit/
│   │   │   └── page.tsx          # Report submission
│   │   ├── track/
│   │   │   └── [reportId]/
│   │   │       └── page.tsx      # Public tracking
│   │   └── transparency/
│   │       └── page.tsx           # Public dashboard
│   ├── (auth)/
│   │   ├── login/
│   │   │   └── page.tsx
│   │   └── register/
│   │       └── page.tsx
│   └── api/
│       └── proxy/
│           └── route.ts           # Proxy to FastAPI
├── components/
│   ├── ui/
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Select.tsx
│   │   └── Card.tsx
│   ├── ReportForm.tsx
│   ├── EvidenceUpload.tsx
│   ├── VoiceRecorder.tsx
│   └── TrackingStatus.tsx
├── lib/
│   ├── api/
│   │   ├── client.ts              # API client
│   │   └── endpoints.ts          # API endpoints
│   ├── encryption/
│   │   └── field-encryption.ts   # Client-side encryption
│   ├── offline/
│   │   └── storage.ts            # IndexedDB utilities
│   ├── upload/
│   │   └── resumable.ts          # Resumable uploads
│   └── i18n/
│       └── messages.ts           # Translations
├── hooks/
│   ├── useOffline.ts
│   ├── useReportForm.ts
│   └── useVoiceRecording.ts
├── types/
│   └── index.ts                   # TypeScript types
└── public/
    └── locales/
        ├── en.json
        └── pidgin.json            # Pidgin translations
```

## Backend Enhancements

### Step 1: Add Report ID Generation

```python
# backend/app/services/report_id.py
import datetime
from sqlalchemy import text
from app.database import SessionLocal

async def generate_report_id() -> str:
    """Generate unique report ID: RPT-YYYY-XXXXXX"""
    year = datetime.datetime.now().year
    
    async with SessionLocal() as session:
        # Get count of reports this year
        result = await session.execute(
            text("SELECT COUNT(*) FROM reports WHERE EXTRACT(YEAR FROM created_at) = :year"),
            {"year": year}
        )
        count = result.scalar() or 0
        
        # Format: RPT-2025-000123
        report_id = f"RPT-{year}-{str(count + 1).zfill(6)}"
        return report_id
```

### Step 2: Add Evidence Hash Computation

```python
# backend/app/services/evidence.py
import hashlib
from typing import BinaryIO

def compute_file_hash(file: BinaryIO) -> str:
    """Compute SHA256 hash of file."""
    sha256 = hashlib.sha256()
    file.seek(0)
    while chunk := file.read(8192):
        sha256.update(chunk)
    file.seek(0)
    return sha256.hexdigest()
```

### Step 3: Add Public Tracking Endpoint

```python
# backend/app/api/reports.py addition
@router.get("/track/{report_id}", response_model=ReportTracking)
async def track_report(
    report_id: str,
    session: AsyncSession = Depends(get_db_session),
):
    """Public endpoint to track report status (no auth required)."""
    result = await session.execute(
        select(Report).where(Report.report_id == report_id)
    )
    report = result.scalar_one_or_none()
    
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    return ReportTracking(
        report_id=report.report_id,
        status=report.status,
        created_at=report.created_at,
        updated_at=report.updated_at,
        # Don't expose sensitive data
    )
```

## Database Migrations

### Migration: Add Report ID and Hash Fields

```python
# backend/alembic/versions/XXXX_add_report_ids_and_hashes.py
"""Add report IDs and evidence hashes

Revision ID: xxxx
"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    # Add report_id column
    op.add_column('reports', sa.Column('report_id', sa.String(20), unique=True))
    
    # Create report_hashes table
    op.create_table(
        'report_hashes',
        sa.Column('id', sa.UUID(), primary_key=True),
        sa.Column('report_id', sa.UUID(), sa.ForeignKey('reports.id')),
        sa.Column('evidence_id', sa.UUID(), sa.ForeignKey('report_media.id')),
        sa.Column('hash_sha256', sa.String(64), nullable=False),
        sa.Column('anchored_on_chain', sa.Boolean(), default=False),
        sa.Column('chain_tx_hash', sa.Text()),
        sa.Column('created_at', sa.DateTime(), default=sa.func.now()),
    )
    
    # Add priority score and AI fields
    op.add_column('reports', sa.Column('priority_score', sa.Numeric(3, 2)))
    op.add_column('reports', sa.Column('ai_category', sa.String(50)))
    op.add_column('reports', sa.Column('recommended_agency', sa.String(100)))
    op.add_column('reports', sa.Column('is_likely_fake', sa.Boolean(), default=False))
    op.add_column('reports', sa.Column('fake_confidence', sa.Numeric(3, 2)))
```

## Testing Strategy

### Unit Tests

```python
# backend/tests/test_report_ids.py
import pytest
from app.services.report_id import generate_report_id

@pytest.mark.asyncio
async def test_generate_report_id():
    report_id = await generate_report_id()
    assert report_id.startswith("RPT-")
    assert len(report_id) == 16  # RPT-YYYY-XXXXXX
    assert report_id[4:8].isdigit()  # Year
    assert report_id[9:].isdigit()   # Sequence
```

### Integration Tests

```python
# backend/tests/test_tracking.py
@pytest.mark.asyncio
async def test_public_tracking(client):
    # Create report
    response = await client.post("/v1/reports/create", json={...})
    report_id = response.json()["report_id"]
    
    # Track without auth
    track_response = await client.get(f"/v1/reports/track/{report_id}")
    assert track_response.status_code == 200
    assert "status" in track_response.json()
    assert "reporter" not in track_response.json()  # Sensitive data hidden
```

## Deployment Checklist

- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] API endpoints tested
- [ ] Next.js app built and deployed
- [ ] CDN configured for static assets
- [ ] Monitoring set up (Sentry, etc.)
- [ ] Rate limiting configured
- [ ] SSL certificates valid
- [ ] Backup strategy in place

## Next Steps

1. Initialize Next.js project
2. Set up API client to connect to FastAPI backend
3. Implement report submission form
4. Add tracking page
5. Enhance backend with report IDs and hashes
6. Test end-to-end flow
7. Deploy to staging environment














