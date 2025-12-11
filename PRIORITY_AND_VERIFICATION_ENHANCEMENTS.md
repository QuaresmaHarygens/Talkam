# Priority Scoring and Verification Enhancements

## ✅ Completed Features

### 1. Priority Scoring System

**Service**: `app/services/priority_scoring.py`

Calculates priority score (0.0-1.0) based on:
- **Severity** (40%): Critical=1.0, High=0.75, Medium=0.5, Low=0.25
- **Attestations** (20%): Community confirmations (normalized to 5+ = 1.0)
- **AI Score** (20%): AI severity assessment if available
- **Witness Count** (10%): Number of witnesses (normalized to 10+ = 1.0)
- **Category** (10%): Critical categories (violence, security, health) = 1.0, others = 0.5

**Auto-calculation:**
- Calculated on report creation
- Recalculated when attestations are added
- Recalculated when verifications are added
- Stored in `reports.priority_score` field

### 2. Enhanced Verification System

**Multi-Verifier Consensus:**
- **NGO/Admin Verifications**: Weighted 2x (from `verifications` table)
- **Community Attestations**: Weighted 1x (from `attestations` table)
- **Combined Thresholds**:
  - Verified: 3 NGO/Admin confirms OR 2 NGO/Admin + 2 community confirms
  - Rejected: 4+ combined rejects
  - Under Review: Otherwise

**Status Determination:**
- Uses consensus from both verification sources
- More democratic - community input matters
- Faster verification with community support

## How It Works

### Priority Score Calculation

```python
# Example calculation:
# Severity: High (0.75) × 0.4 = 0.30
# Attestations: 3 confirms (0.6) × 0.2 = 0.12
# AI Score: 0.85 × 0.2 = 0.17
# Witnesses: 5 (0.5) × 0.1 = 0.05
# Category: Security (1.0) × 0.1 = 0.10
# Total: 0.74 (High Priority)
```

### Verification Consensus

**Scenario 1: NGO Verification**
- 3 NGO admins confirm → Status: Verified ✅

**Scenario 2: Community + NGO**
- 1 NGO admin confirms + 2 community members confirm → Status: Verified ✅

**Scenario 3: Community Only**
- 5 community members confirm → Status: Under Review (needs NGO/admin)

**Scenario 4: Mixed Signals**
- 2 confirms, 3 denies → Status: Under Review (needs more input)

## API Integration

### Priority Score

Priority score is automatically calculated and included in:
- Report creation response
- Report detail response
- Search results (can filter by `min_priority`)

### Verification

Enhanced verification considers:
- `/v1/reports/{id}/verify` - NGO/Admin verifications
- `/v1/attestations/reports/{id}/attest` - Community attestations

Both contribute to final verification status.

## Usage Examples

### Filter by Priority

```bash
# Get high priority reports (score >= 0.7)
curl "http://127.0.0.1:8000/v1/reports/search?min_priority=0.7&sort_by=priority_score&sort_order=desc" \
  -H "Authorization: Bearer <token>"
```

### View Priority in Report

Priority score is included in report responses:
```json
{
  "id": "...",
  "priority_score": 0.74,
  "severity": "high",
  ...
}
```

## Benefits

1. **Better Triage**: High priority reports surface first
2. **Community Input**: Community attestations influence verification
3. **Faster Verification**: Multiple paths to verification
4. **Transparent Scoring**: Clear calculation methodology
5. **Auto-Updates**: Priority recalculates as new data arrives

## Future Enhancements

1. **Dynamic Weights**: Adjust weights based on historical accuracy
2. **User Reputation**: Weight attestations by user reputation
3. **Time Decay**: Reduce priority for old reports
4. **Category-Specific Thresholds**: Different thresholds per category
5. **Priority Alerts**: Auto-alert on high-priority reports

---

**Status**: ✅ Priority scoring and enhanced verification complete!
