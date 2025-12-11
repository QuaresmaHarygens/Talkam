# Deployment Guide

## Environment Setup

### Staging Environment

1. **Provision Infrastructure**
   ```bash
   # Using Terraform (example)
   cd infrastructure/terraform
   terraform init
   terraform plan -var-file=staging.tfvars
   terraform apply
   ```

2. **Configure Environment Variables**
   - Copy `.env.example` to `.env.staging`
   - Update all values with staging credentials
   - Store secrets in Vault or AWS Secrets Manager

3. **Deploy Backend**
   ```bash
   ./scripts/deploy.sh staging
   ```

4. **Run Migrations**
   ```bash
   cd backend
   export PYTHONPATH=$(pwd)
   alembic upgrade head
   ```

5. **Deploy Mobile App**
   ```bash
   cd mobile
   flutter build apk --release --flavor staging
   # Upload to Firebase App Distribution or TestFlight
   ```

### Production Environment

1. **Pre-Deployment Checklist**
   - [ ] All tests passing
   - [ ] Security audit completed
   - [ ] Load testing completed
   - [ ] Backup procedures tested
   - [ ] Rollback plan documented

2. **Deploy Backend**
   ```bash
   # Blue-green deployment
   ./scripts/deploy.sh production
   
   # Or using Kubernetes
   kubectl apply -f k8s/production/
   kubectl rollout status deployment/talkam-api
   ```

3. **Verify Deployment**
   ```bash
   curl https://api.talkamliberia.org/health
   curl https://api.talkamliberia.org/v1/docs
   ```

4. **Monitor**
   - Check Grafana dashboards
   - Review Sentry for errors
   - Monitor API latency
   - Check SMS gateway status

## Kubernetes Deployment (Optional)

### Deployment YAML

Create `k8s/deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: talkam-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: talkam-api
  template:
    metadata:
      labels:
        app: talkam-api
    spec:
      containers:
      - name: api
        image: talkam-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: POSTGRES_DSN
          valueFrom:
            secretKeyRef:
              name: talkam-secrets
              key: postgres-dsn
        livenessProbe:
          httpGet:
            path: /
            port: 8000
          initialDelaySeconds: 30
        readinessProbe:
          httpGet:
            path: /
            port: 8000
          initialDelaySeconds: 5
```

### Service YAML

```yaml
apiVersion: v1
kind: Service
metadata:
  name: talkam-api-service
spec:
  selector:
    app: talkam-api
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
```

## Database Migrations

### Staging
```bash
export POSTGRES_DSN="postgresql+asyncpg://user:pass@staging-db:5432/talkam"
alembic upgrade head
```

### Production
```bash
# Always backup first!
pg_dump -h production-db -U talkam talkam > backup_$(date +%Y%m%d).sql

export POSTGRES_DSN="postgresql+asyncpg://user:pass@production-db:5432/talkam"
alembic upgrade head

# Verify migration
alembic current
```

## Rollback Procedure

1. **Identify Issue**
   - Check error logs
   - Review monitoring dashboards
   - Identify affected users

2. **Quick Rollback**
   ```bash
   # Kubernetes
   kubectl rollout undo deployment/talkam-api
   
   # Docker Compose
   docker-compose down
   git checkout previous-stable-tag
   docker-compose up -d
   ```

3. **Database Rollback** (if needed)
   ```bash
   alembic downgrade -1
   # Or restore from backup
   psql -h db -U talkam talkam < backup_YYYYMMDD.sql
   ```

4. **Notify Users**
   - Send SMS notification if critical
   - Update status page
   - Post on social media if needed

## Scaling

### Horizontal Scaling

Increase API replicas:
```bash
kubectl scale deployment talkam-api --replicas=5
```

### Database Scaling

- Add read replicas for analytics queries
- Use connection pooling (PgBouncer)
- Consider sharding by county if needed

### Caching

- Increase Redis memory
- Add Redis cluster for high availability
- Cache frequently accessed reports

## Maintenance Windows

1. **Schedule** maintenance during low-traffic hours
2. **Notify** users 24 hours in advance via SMS/push
3. **Enable** maintenance mode (503 responses with message)
4. **Perform** updates
5. **Verify** functionality
6. **Disable** maintenance mode
7. **Monitor** for issues
