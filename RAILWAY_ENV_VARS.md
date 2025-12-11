# Railway Environment Variables Setup 🔧

## ✅ Automatic Variables (Set by Railway)

Railway automatically sets these when you add services:

- **`DATABASE_URL`** - PostgreSQL connection string (auto-set when you add PostgreSQL)
- **`PORT`** - Port for the service (auto-set by Railway)

## 📋 Required Variables (Set Manually)

**Go to:** Service → "Variables" tab in Railway dashboard

### 1. JWT_SECRET
**Generate secure token:**
```bash
python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
```

**Or use online generator:**
- Generate 32+ character random string
- Add to Railway as: `JWT_SECRET`

### 2. CORS_ORIGINS
**For development/testing:**
```
CORS_ORIGINS=*
```

**For production (specific domains):**
```
CORS_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
```

### 3. ENVIRONMENT
```
ENVIRONMENT=production
```

## 🔧 Optional Variables

### Redis (if using)
```
REDIS_URL=redis://your-redis-url
```

### S3 Storage (if using)
```
S3_ENDPOINT=https://s3.amazonaws.com
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key
BUCKET_REPORTS=talkam-media
```

### SMS Gateway (if using)
```
SMS_GATEWAY_URL=https://your-sms-gateway.com
SMS_GATEWAY_TOKEN=your-token
```

### Sentry (if using)
```
SENTRY_DSN=your-sentry-dsn
SENTRY_ENVIRONMENT=production
ENABLE_SENTRY=true
```

## 📝 Complete Variable List

**Minimum Required:**
```
DATABASE_URL=<auto-set by Railway>
PORT=<auto-set by Railway>
JWT_SECRET=<generate secure token>
CORS_ORIGINS=*
ENVIRONMENT=production
```

**With Redis:**
```
REDIS_URL=redis://...
```

**With S3:**
```
S3_ENDPOINT=...
S3_ACCESS_KEY=...
S3_SECRET_KEY=...
BUCKET_REPORTS=talkam-media
```

## ✅ How to Set in Railway

1. **Go to your service** in Railway dashboard
2. **Click "Variables" tab**
3. **Click "New Variable"**
4. **Enter name and value**
5. **Click "Add"**
6. **Redeploy** (Railway auto-redeploys on variable changes)

## 🔍 Verify Variables

**Check in Railway dashboard:**
- Service → Variables tab
- All variables should be listed

**Or check in logs:**
- Service → Deployments → Latest → Logs
- Look for environment variable errors

## ⚠️ Important Notes

1. **`DATABASE_URL` is auto-set** - Don't set manually when using Railway PostgreSQL
2. **`JWT_SECRET` must be secure** - Use long random string
3. **`CORS_ORIGINS=*`** - Allows all origins (use specific domains in production)
4. **Variables are encrypted** - Railway encrypts all environment variables

---

**Set these variables in Railway dashboard before deploying!** 🚀



