# Troubleshooting Guide

Common issues and solutions for the Talkam Liberia system.

## Backend API Issues

### Problem: API won't start

**Symptoms:**
- `uvicorn` command fails
- Port already in use error
- Import errors

**Solutions:**

1. **Port Already in Use**
   ```bash
   # Find process on port 8000
   lsof -ti:8000 | xargs kill -9
   # Or use different port
   uvicorn app.main:app --reload --port 8001
   ```

2. **Import Errors**
   ```bash
   # Ensure you're in virtual environment
   source .venv/bin/activate
   # Reinstall dependencies
   pip install -e .[dev]
   ```

3. **Missing Dependencies**
   ```bash
   pip install --upgrade pip
   pip install -e .[dev]
   ```

### Problem: Database Connection Error

**Symptoms:**
```
sqlalchemy.exc.OperationalError: could not connect to server
```

**Solutions:**

1. **Check PostgreSQL is Running**
   ```bash
   # Docker
   docker ps | grep postgres
   # Local
   pg_isready -h localhost -p 5432
   ```

2. **Verify Connection String**
   ```bash
   # Check .env file
   cat backend/.env | grep POSTGRES_DSN
   # Should be: postgresql+asyncpg://user:pass@host:port/dbname
   ```

3. **Test Connection**
   ```bash
   psql "postgresql://user:pass@localhost:5432/talkam"
   ```

4. **Reset Database**
   ```bash
   docker compose down -v
   docker compose up -d postgres
   sleep 5
   alembic upgrade head
   ```

### Problem: Redis Connection Error

**Symptoms:**
```
redis.exceptions.ConnectionError
```

**Solutions:**

1. **Check Redis is Running**
   ```bash
   docker ps | grep redis
   redis-cli ping  # Should return PONG
   ```

2. **Verify Redis URL**
   ```bash
   # Check .env
   echo $REDIS_URL
   # Should be: redis://localhost:6379/0
   ```

3. **Test Connection**
   ```bash
   redis-cli -u "redis://localhost:6379/0" ping
   ```

### Problem: Migration Errors

**Symptoms:**
```
alembic.util.exc.CommandError: Target database is not up to date
```

**Solutions:**

1. **Check Current Version**
   ```bash
   alembic current
   ```

2. **View Migration History**
   ```bash
   alembic history
   ```

3. **Force Upgrade**
   ```bash
   alembic upgrade head
   ```

4. **Reset Migrations (WARNING: Deletes Data)**
   ```bash
   # Drop all tables
   docker compose down -v
   docker compose up -d postgres
   alembic upgrade head
   ```

5. **Manual Fix**
   ```bash
   # Mark as current version
   alembic stamp head
   ```

### Problem: S3/Storage Errors

**Symptoms:**
```
botocore.exceptions.ClientError: Access Denied
```

**Solutions:**

1. **Check MinIO/S3 is Running**
   ```bash
   docker ps | grep minio
   # Access MinIO console: http://localhost:9001
   # Default: minioadmin/minioadmin
   ```

2. **Verify Credentials**
   ```bash
   # Check .env
   echo $S3_ACCESS_KEY
   echo $S3_SECRET_KEY
   ```

3. **Create Bucket**
   ```bash
   # Using AWS CLI or MinIO client
   aws --endpoint-url http://localhost:9000 s3 mb s3://talkam-media
   ```

### Problem: Authentication Issues

**Symptoms:**
- JWT token invalid
- 401 Unauthorized errors

**Solutions:**

1. **Check Secret Key**
   ```bash
   # Generate new secret key
   openssl rand -hex 32
   # Update SECRET_KEY in .env
   ```

2. **Verify Token Format**
   ```bash
   # Token should be: Bearer <token>
   curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8000/v1/reports/search
   ```

3. **Check Token Expiration**
   - Default: 60 minutes
   - Update ACCESS_TOKEN_EXPIRE_MINUTES in .env

### Problem: Rate Limiting Issues

**Symptoms:**
- 429 Too Many Requests
- Rate limit headers not showing

**Solutions:**

1. **Check Redis is Configured**
   ```bash
   # Rate limiting requires Redis
   echo $REDIS_URL
   ```

2. **Adjust Rate Limits**
   ```python
   # In backend/app/main.py
   app.add_middleware(
       RateLimitMiddleware,
       default_limit=200,  # Increase limit
       window=60,
   )
   ```

3. **Disable Rate Limiting** (Not Recommended)
   ```python
   # Comment out rate limiting middleware
   # app.add_middleware(RateLimitMiddleware, ...)
   ```

## Mobile App Issues

### Problem: Flutter App Won't Build

**Symptoms:**
- `flutter pub get` fails
- Build errors

**Solutions:**

1. **Check Flutter Installation**
   ```bash
   flutter doctor
   ```

2. **Clean Build**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Update Dependencies**
   ```bash
   flutter pub upgrade
   ```

### Problem: API Connection Failed

**Symptoms:**
- Network error
- Cannot connect to API

**Solutions:**

1. **Check API Endpoint**
   ```dart
   // In mobile/lib/providers.dart
   final apiBaseUrl = 'http://127.0.0.1:8000/v1';  // Local
   // For Android emulator: use 10.0.2.2 instead of 127.0.0.1
   // For iOS simulator: use localhost
   ```

2. **Verify API is Running**
   ```bash
   curl http://127.0.0.1:8000/health
   ```

3. **Check Network Permissions**
   ```xml
   <!-- Android: android/app/src/main/AndroidManifest.xml -->
   <uses-permission android:name="android.permission.INTERNET" />
   ```

### Problem: Offline Sync Not Working

**Symptoms:**
- Reports not syncing
- Queue stuck

**Solutions:**

1. **Check Hive Initialization**
   ```dart
   // Ensure Hive is initialized in main.dart
   await Hive.initFlutter();
   ```

2. **Clear Offline Queue**
   ```dart
   // In Settings screen
   await offlineStorage.clearQueue();
   ```

3. **Manual Sync**
   ```dart
   await syncService.syncOfflineReports();
   ```

## Admin Dashboard Issues

### Problem: Dashboard Won't Load

**Symptoms:**
- Blank page
- CORS errors

**Solutions:**

1. **Check API URL**
   ```bash
   # In admin-web/.env
   VITE_API_URL=http://127.0.0.1:8000/v1
   ```

2. **Rebuild Dashboard**
   ```bash
   cd admin-web
   npm run build
   npm run dev
   ```

3. **Check CORS Configuration**
   ```python
   # In backend/app/main.py
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["http://localhost:3000"],  # Add your origin
   )
   ```

### Problem: Login Fails

**Symptoms:**
- 401 Unauthorized
- Token not saved

**Solutions:**

1. **Check API Endpoint**
   - Verify VITE_API_URL is correct
   - Test endpoint: `curl http://127.0.0.1:8000/v1/auth/login`

2. **Check Browser Console**
   - Open DevTools (F12)
   - Check Network tab for errors

3. **Clear Browser Storage**
   ```javascript
   // In browser console
   localStorage.clear();
   ```

## Infrastructure Issues

### Problem: Docker Containers Won't Start

**Symptoms:**
- `docker compose up` fails
- Port conflicts

**Solutions:**

1. **Check Port Availability**
   ```bash
   # Check if ports are in use
   lsof -i :5432  # PostgreSQL
   lsof -i :6379  # Redis
   lsof -i :9000  # MinIO
   ```

2. **Stop Existing Containers**
   ```bash
   docker compose down
   docker ps -a | grep talkam
   ```

3. **Remove Volumes** (WARNING: Deletes Data)
   ```bash
   docker compose down -v
   docker compose up -d
   ```

### Problem: Terraform Deployment Fails

**Symptoms:**
- `terraform apply` errors
- Resource conflicts

**Solutions:**

1. **Check AWS Credentials**
   ```bash
   aws configure list
   aws sts get-caller-identity
   ```

2. **Verify Terraform State**
   ```bash
   terraform state list
   ```

3. **Import Existing Resources**
   ```bash
   terraform import aws_instance.example i-1234567890abcdef0
   ```

## Performance Issues

### Problem: Slow API Response Times

**Symptoms:**
- Response times > 1s
- Timeout errors

**Solutions:**

1. **Check Database Performance**
   ```sql
   -- Check slow queries
   SELECT * FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 10;
   ```

2. **Enable Query Logging**
   ```python
   # In backend/app/database.py
   engine = create_async_engine(dsn, echo=True)  # Enable logging
   ```

3. **Check Redis Cache**
   ```bash
   redis-cli info stats
   ```

4. **Database Connection Pool**
   ```python
   # Increase pool size in database.py
   engine = create_async_engine(
       dsn,
       pool_size=20,
       max_overflow=10,
   )
   ```

### Problem: High Memory Usage

**Symptoms:**
- Out of memory errors
- Slow performance

**Solutions:**

1. **Check Resource Usage**
   ```bash
   docker stats
   # Or
   htop
   ```

2. **Limit Container Resources**
   ```yaml
   # In docker-compose.yml
   services:
     api:
       mem_limit: 512m
       cpus: 0.5
   ```

## Getting More Help

1. **Check Logs**
   ```bash
   # Docker logs
   docker compose logs -f api
   
   # Application logs
   tail -f logs/app.log
   ```

2. **Enable Debug Mode**
   ```python
   # In backend/app/main.py
   import logging
   logging.basicConfig(level=logging.DEBUG)
   ```

3. **Check System Resources**
   ```bash
   # Disk space
   df -h
   
   # Memory
   free -h
   
   # CPU
   top
   ```

4. **Review Documentation**
   - `README.md` - Main documentation
   - `QUICK_START_GUIDE.md` - Setup guide
   - `artifacts/docs/` - Detailed guides

---

**Still having issues? Check the logs and review the relevant documentation.**
