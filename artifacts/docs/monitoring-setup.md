# Monitoring & Observability Setup

## Prometheus + Grafana

### Prometheus Configuration

Create `prometheus.yml`:
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'talkam-api'
    static_configs:
      - targets: ['api:8000']
    metrics_path: '/metrics'
  
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
  
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
```

### Grafana Dashboards

Key dashboards to create:
1. **API Performance**
   - Request rate (requests/sec)
   - Response time (p50, p95, p99)
   - Error rate (4xx, 5xx)
   - Active connections

2. **Report Metrics**
   - Reports created per hour
   - Verification rate
   - Average response time
   - Reports by category/county

3. **Infrastructure**
   - CPU/Memory usage
   - Database connections
   - Redis memory usage
   - Disk I/O

4. **Business Metrics**
   - Active users
   - Offline sync success rate
   - SMS delivery rate
   - Alert delivery rate

## Sentry Error Tracking

### Backend Setup

Add to `backend/app/main.py`:
```python
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="YOUR_SENTRY_DSN",
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1,
    environment="production",
)
```

### Flutter Setup

Add to `mobile/pubspec.yaml`:
```yaml
dependencies:
  sentry_flutter: ^7.0.0
```

Initialize in `mobile/lib/main.dart`:
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.tracesSampleRate = 0.1;
    },
    appRunner: () => runApp(const TalkamApp()),
  );
}
```

## Log Aggregation

### Loki Setup (for centralized logs)

Configure Fluent Bit or Promtail to forward logs:
- Application logs → Loki
- Access logs → Loki
- Error logs → Loki with error level

### CloudWatch (AWS alternative)

If using AWS:
- Configure CloudWatch Logs agent
- Set up log groups for each service
- Create metric filters for errors
- Set up alarms for critical errors

## Alerting Rules

### Critical Alerts (PagerDuty/Slack)

- API error rate > 5% for 5 minutes
- Database connection pool exhausted
- Response time p95 > 5 seconds
- SMS gateway failure
- Storage quota > 90%

### Warning Alerts (Email/Slack)

- API error rate > 1% for 10 minutes
- Response time p95 > 2 seconds
- Queue depth > 1000
- Disk usage > 80%

## Health Checks

### API Health Endpoint

Already implemented: `GET /` returns `{"status": "ok"}`

### Database Health

Add to `backend/app/main.py`:
```python
@app.get("/health/db")
async def health_db(session: AsyncSession = Depends(get_db_session)):
    try:
        await session.execute(text("SELECT 1"))
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}, 503
```

### Redis Health

Add Redis ping check to health endpoint.

## Synthetic Monitoring

Use services like:
- **UptimeRobot** - HTTP checks every 5 minutes
- **Pingdom** - Global monitoring
- **Checkly** - API monitoring with assertions

Monitor:
- API availability
- Login endpoint
- Report creation endpoint
- Dashboard endpoints
