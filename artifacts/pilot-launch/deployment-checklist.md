# Production Deployment Checklist

## Pre-Deployment

### Infrastructure

- [ ] AWS/GCP/Azure account configured
- [ ] Domain names registered:
  - [ ] api.talkam.liberia.com
  - [ ] admin.talkam.liberia.com
  - [ ] app.talkam.liberia.com (if web version)
- [ ] SSL certificates obtained (Let's Encrypt or provider)
- [ ] DNS records configured

### Backend

- [ ] Database created (PostgreSQL 15)
- [ ] Redis cluster provisioned
- [ ] S3-compatible storage bucket created
- [ ] Environment variables configured:
  - [ ] Database connection string
  - [ ] Redis URL
  - [ ] S3 credentials
  - [ ] Secret keys (JWT, encryption)
  - [ ] SMS gateway credentials
  - [ ] FCM server key
  - [ ] APNs certificates (iOS)

### Mobile App

- [ ] App Store developer accounts (iOS/Android)
- [ ] App signing certificates generated
- [ ] API endpoints configured in app
- [ ] Push notification certificates (FCM/APNs)
- [ ] App icons and splash screens
- [ ] Store listings prepared

### Admin Dashboard

- [ ] API endpoint configured
- [ ] Build completed (`npm run build`)
- [ ] Hosting configured (Vercel/Netlify/S3)
- [ ] Environment variables set

## Deployment Steps

### 1. Infrastructure (Terraform)

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

- [ ] VPC created
- [ ] RDS PostgreSQL instance running
- [ ] ElastiCache Redis running
- [ ] S3 bucket accessible
- [ ] Security groups configured

### 2. Backend (Kubernetes)

```bash
# Create secrets
kubectl create secret generic talkam-secrets \
  --from-env-file=backend/.env

# Deploy
kubectl apply -f infrastructure/kubernetes/
```

- [ ] Backend pods running
- [ ] Load balancer accessible
- [ ] Health checks passing
- [ ] Database migrations applied

### 3. Monitoring

```bash
cd monitoring
docker-compose -f docker-compose.monitoring.yml up -d
```

- [ ] Prometheus scraping metrics
- [ ] Grafana dashboards configured
- [ ] Alerts configured
- [ ] Log aggregation working

### 4. Admin Dashboard

```bash
cd admin-web
npm run build
# Deploy dist/ to hosting provider
```

- [ ] Dashboard accessible
- [ ] API connection working
- [ ] Authentication functional

### 5. Mobile App

- [ ] Build production APK/IPA
- [ ] Submit to app stores
- [ ] Test on real devices
- [ ] Verify push notifications

## Post-Deployment

### Testing

- [ ] API health check: `curl https://api.talkam.liberia.com/`
- [ ] Create test report via API
- [ ] Test SMS ingestion (send to 8888)
- [ ] Test admin login
- [ ] Test mobile app login
- [ ] Test offline sync
- [ ] Test push notifications

### Performance

- [ ] Run load test: `python scripts/load-testing/load_test.py`
- [ ] Verify response times < 500ms (P95)
- [ ] Check database performance
- [ ] Monitor Redis cache hit rate
- [ ] Review error logs

### Security

- [ ] SSL/TLS certificates valid
- [ ] API rate limiting enabled
- [ ] CORS configured correctly
- [ ] Secrets not in logs
- [ ] Database backups scheduled
- [ ] Firewall rules verified

### Documentation

- [ ] Runbooks updated
- [ ] API documentation published
- [ ] User guides deployed
- [ ] Admin guides available
- [ ] Emergency contacts listed

## Launch Day

### Pre-Launch (T-1 day)

- [ ] Final system test
- [ ] Backup database
- [ ] Prepare rollback plan
- [ ] Notify stakeholders

### Launch (T-0)

- [ ] Enable SMS gateway
- [ ] Publish mobile apps
- [ ] Activate admin dashboard
- [ ] Monitor dashboards
- [ ] Ready support team

### Post-Launch (T+1 day)

- [ ] Review metrics
- [ ] Check error logs
- [ ] Gather user feedback
- [ ] Document issues
- [ ] Plan improvements

## Rollback Plan

If issues arise:

1. **Immediate Rollback**:
   ```bash
   kubectl rollout undo deployment/talkam-backend
   ```

2. **Database Rollback**:
   ```bash
   cd backend
   alembic downgrade -1
   ```

3. **Infrastructure Rollback**:
   ```bash
   terraform destroy  # Only if necessary
   ```

4. **Disable Features**:
   - Disable SMS ingestion
   - Pause new user registration
   - Close mobile app downloads

## Monitoring Post-Launch

### First 24 Hours

- Monitor error rates every hour
- Check API response times
- Review user registrations
- Track report submissions
- Watch SMS delivery

### First Week

- Daily analytics review
- User feedback collection
- Performance optimization
- Bug fixes and patches
- Capacity planning

## Success Metrics

### Technical

- Uptime: > 99.5%
- API response time: P95 < 500ms
- Error rate: < 1%
- SMS delivery: > 95%

### Business

- User registrations: Track daily
- Report submissions: Track volume
- Verification rate: Target > 60%
- User engagement: Daily active users

---

**Ready for launch? Follow this checklist step by step!**
