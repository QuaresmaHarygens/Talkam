# Analytics & KPI Dashboard Spec

## Core Metrics
- **Report Volume:** total reports per day/week, breakdown by category and county.
- **Verification Rate:** percentage verified vs submitted.
- **Response Time:** median time from submission to first responder action.
- **Offline Queue Success:** count of reports synced after offline capture.
- **Alert Reach:** number of devices receiving geofenced alerts.
- **NGO/Gov Engagement:** exports downloaded, follow-up requests, case status transitions.

## Event Tracking (sample names)
- `user_sign_up`
- `anonymous_session_started`
- `report_draft_saved`
- `report_submitted`
- `report_synced_offline`
- `report_verified`
- `response_assigned`
- `response_resolved`
- `alert_acknowledged`
- `ngo_export_downloaded`

## Dashboard Layout
1. **Hero Tiles:** total active reports, verification rate, average response time.
2. **Map Widget:** heatmap of incidents with filter chips (category, severity, timeframe).
3. **Trend Charts:** stacked area for category mix, bar chart for counties.
4. **Response Funnel:** submitted → triaged → verified → resolved.
5. **Offline Monitor:** gauge showing offline sync success %.
6. **Top Reporters/Partners:** leaderboard with badges.

## Data Sources
- PostgreSQL materialized views (`mv_report_counts`, `mv_response_times`).
- Analytics events in ClickHouse for streaming dashboards, aggregated hourly.
- Redis counters for near-real-time alert deliveries.

## Sharing & Privacy
- Public dashboards limited to aggregate counts >10 events (differential privacy noise ±1-3%).
- Partner dashboards require signed URLs, expire after 24h.

## Sample SQL Snippet
```sql
SELECT county, COUNT(*) AS total, SUM(CASE WHEN status='verified' THEN 1 ELSE 0 END) AS verified
FROM reports
WHERE created_at >= now() - interval '7 days'
GROUP BY county;
```
