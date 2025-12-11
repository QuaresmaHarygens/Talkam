# Redis Setup for Fly.io Deployment

## Quick Setup: Use Upstash (Free Redis)

1. **Sign up for Upstash**: https://console.upstash.com/
2. **Create Redis Database**:
   - Click "Create Database"
   - Name: `talkam-redis`
   - Type: Regional (choose same region as Fly.io app: `iad`)
   - Click "Create"
3. **Copy Redis URL**:
   - After creation, click on your database
   - Copy the "Redis URL" (format: `redis://default:password@host:port`)
4. **Set as Secret**:
   ```bash
   fly secrets set REDIS_URL="redis://default:YOUR_PASSWORD@YOUR_HOST:6379" --app talkam-backend-7653
   ```

## Alternative: Use Fly.io Redis (Requires Interactive Setup)

```bash
fly redis create --name talkam-redis-7653 --region iad
# Follow prompts, then:
fly redis attach talkam-redis-7653 --app talkam-backend-7653
```

## Temporary Workaround (For Testing Only)

If you need to test without Redis immediately, you can temporarily modify `backend/app/config.py` to make `redis_url` optional, but this is NOT recommended for production.

---

**Recommended: Use Upstash (free tier, easy setup)**
