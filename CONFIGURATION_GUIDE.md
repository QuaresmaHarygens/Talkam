# Configuration Guide

## Environment Variables Setup

### Required Variables

These must be set for the application to run:

```bash
# Application
SECRET_KEY=your-secret-key-here  # Generate with: openssl rand -hex 32
POSTGRES_DSN=postgresql://user:password@host:5432/dbname
REDIS_URL=redis://localhost:6379/0
```

### Optional Variables

These are optional but enable additional features:

#### Push Notifications

**Firebase Cloud Messaging (FCM) - For Android/Web:**
```bash
# Option 1: Server Key (Simpler)
FCM_SERVER_KEY=your-fcm-server-key
FCM_PROJECT_ID=your-firebase-project-id

# Option 2: Service Account (More secure)
FCM_CREDENTIALS_PATH=/path/to/serviceAccountKey.json
```

**Apple Push Notification Service (APNs) - For iOS:**
```bash
APNS_KEY_PATH=/path/to/AuthKey_XXXXX.p8
APNS_KEY_ID=your-apns-key-id
APNS_TEAM_ID=your-apple-team-id
APNS_BUNDLE_ID=com.talkam.liberia
APNS_USE_SANDBOX=true  # Set to false for production
```

#### SMS Gateway (For Password Reset)

```bash
SMS_GATEWAY_URL=https://api.sms-gateway.com/send
SMS_GATEWAY_TOKEN=your-sms-gateway-token
```

#### Storage

```bash
S3_ENDPOINT=http://localhost:9000  # Or AWS S3 endpoint
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key
BUCKET_REPORTS=talkam-media
```

#### Error Tracking

```bash
SENTRY_DSN=https://your-dsn@sentry.io/project-id
SENTRY_ENVIRONMENT=production
ENABLE_SENTRY=true
```

#### CORS

```bash
# Development
CORS_ORIGINS=*

# Production (comma-separated)
CORS_ORIGINS=https://admin.talkamliberia.org,https://app.talkamliberia.org
```

## Setup Instructions

### 1. Copy Example File

```bash
cd backend
cp .env.example .env
```

### 2. Generate Secret Key

```bash
openssl rand -hex 32
# Copy output to SECRET_KEY in .env
```

### 3. Configure Database

Update `POSTGRES_DSN` with your database connection string:
```bash
POSTGRES_DSN=postgresql://username:password@host:5432/database
```

### 4. Configure Redis

Update `REDIS_URL`:
```bash
REDIS_URL=redis://localhost:6379/0
# Or for remote: redis://user:password@host:6379/0
```

### 5. Optional: Set Up Push Notifications

#### Firebase (FCM)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing
3. Go to Project Settings → Cloud Messaging
4. Copy Server Key → Set as `FCM_SERVER_KEY`
5. Copy Project ID → Set as `FCM_PROJECT_ID`

**OR** use service account:
1. Go to Project Settings → Service Accounts
2. Generate new private key
3. Download JSON file
4. Set `FCM_CREDENTIALS_PATH=/path/to/file.json`

#### Apple (APNs)

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Create APNs Auth Key
3. Download .p8 file
4. Note Key ID and Team ID
5. Set all APNs variables in `.env`

### 6. Optional: Set Up SMS Gateway

Choose a provider (Twilio, Orange, etc.) and configure:
```bash
SMS_GATEWAY_URL=https://api.provider.com/send
SMS_GATEWAY_TOKEN=your-api-token
```

## Verification

### Check Configuration

```bash
cd backend
source .venv/bin/activate
python -c "from app.config import get_settings; s = get_settings(); print('✅ Config loaded')"
```

### Test Database Connection

```bash
python -c "from app.database import get_session; import asyncio; asyncio.run(get_session().__anext__()); print('✅ Database connected')"
```

### Test Redis Connection

```bash
python -c "import redis; r = redis.from_url('$REDIS_URL'); r.ping(); print('✅ Redis connected')"
```

## Production Configuration

### Security Checklist

- [ ] Generate new `SECRET_KEY` (never use example)
- [ ] Use strong database passwords
- [ ] Restrict CORS origins
- [ ] Enable Sentry for error tracking
- [ ] Use production APNs (set `APNS_USE_SANDBOX=false`)
- [ ] Store secrets in secure vault (AWS Secrets Manager, etc.)
- [ ] Never commit `.env` file to git

### Recommended Production Setup

1. **Use Secrets Management**
   - AWS Secrets Manager
   - HashiCorp Vault
   - Kubernetes Secrets

2. **Environment-Specific Files**
   - `.env.development`
   - `.env.staging`
   - `.env.production`

3. **Validation**
   - Validate all required variables on startup
   - Fail fast if critical config missing

## Troubleshooting

### Push Notifications Not Working

1. Check FCM/APNs credentials are correct
2. Verify tokens are registered in database
3. Check logs for error messages
4. Test with stub mode first (no credentials = stub mode)

### SMS Not Sending

1. Verify SMS gateway URL and token
2. Check gateway API documentation
3. Test with curl first
4. Check application logs

### Database Connection Issues

1. Verify `POSTGRES_DSN` format
2. Check database is running
3. Verify credentials
4. Check network connectivity

---

**Status**: Configuration guide ready. Update `.env` file with your values.
