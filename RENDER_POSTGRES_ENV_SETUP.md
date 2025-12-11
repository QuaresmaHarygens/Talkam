# Render: Add PostgreSQL & Set Environment Variables 📋

## 🎯 Step-by-Step Guide

---

## Part 1: Add PostgreSQL Database

### Step 1: Create PostgreSQL Database

1. **In Render Dashboard:**
   - Click **"New +"** button (top right)
   - Select **"PostgreSQL"** from the dropdown

2. **Configure Database:**
   - **Name:** `talkam-db` (or any name you prefer)
   - **Database:** Leave default (or name it `talkam`)
   - **User:** Leave default (or set custom)
   - **Region:** Choose closest to you (e.g., `Oregon (US West)`)
   - **PostgreSQL Version:** Leave default (latest)
   - **Plan:** Select **"Free"** (for testing) or paid plan

3. **Click "Create Database"**

4. **Wait for provisioning** (~1-2 minutes)

### Step 2: Get Database Connection String

1. **Click on your PostgreSQL database** (in dashboard)
2. **Go to "Info" tab** (or "Connections" tab)
3. **Find "Internal Database URL"** or **"Connection String"**
4. **Copy the entire URL** - It looks like:
   ```
   postgresql://user:password@host:port/database
   ```

**Important:** Save this URL - you'll need it for the next step!

---

## Part 2: Set Environment Variables

### Step 1: Go to Your Web Service

1. **Click on your web service** (the backend service you created)
2. **Go to "Environment" tab** (in the left sidebar)

### Step 2: Add Environment Variables

**Click "Add Environment Variable"** for each one:

#### Variable 1: DATABASE_URL

1. **Key:** `DATABASE_URL`
2. **Value:** Paste the PostgreSQL connection string you copied
   - Should look like: `postgresql://user:pass@host:port/dbname`
3. **Click "Save Changes"**

**OR:** If your database and service are in the same project, Render can auto-link:
- Look for "Link Resource" option
- Select your PostgreSQL database
- Render automatically sets `DATABASE_URL`

#### Variable 2: JWT_SECRET

1. **Key:** `JWT_SECRET`
2. **Value:** Generate a secure token:
   ```bash
   python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
   ```
   Copy the output and paste as the value
3. **Click "Save Changes"**

**Example value:**
```
NaJ4Cehv5UPAJNeJut3JLXoNysFhSl8y1AspwSiVhJo
```

#### Variable 3: CORS_ORIGINS

1. **Key:** `CORS_ORIGINS`
2. **Value:** `*`
   - (For production, use specific domains like: `https://yourdomain.com,https://app.yourdomain.com`)
3. **Click "Save Changes"**

#### Variable 4: ENVIRONMENT

1. **Key:** `ENVIRONMENT`
2. **Value:** `production`
3. **Click "Save Changes"**

#### Variable 5: REDIS_URL (Optional)

**If you have Redis:**
1. **Key:** `REDIS_URL`
2. **Value:** Your Redis connection URL
3. **Click "Save Changes"**

**If you don't have Redis:**
- You can skip this for now
- Or create a Redis instance in Render (New → Redis)

---

## ✅ Complete Environment Variables List

**Required Variables:**
```
DATABASE_URL=postgresql://user:pass@host:port/dbname
JWT_SECRET=your-generated-secret-token
CORS_ORIGINS=*
ENVIRONMENT=production
```

**Optional Variables:**
```
REDIS_URL=redis://your-redis-url
S3_ENDPOINT=https://s3.amazonaws.com
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key
```

---

## 🔍 How to Link Database Automatically

**If database and service are in same project:**

1. **Go to your web service**
2. **Go to "Environment" tab**
3. **Look for "Link Resource" or "Add Resource" button**
4. **Select your PostgreSQL database**
5. **Render automatically:**
   - Sets `DATABASE_URL` environment variable
   - Links the services together

**This is easier than manual setup!**

---

## 📋 Visual Guide

### Adding PostgreSQL:
```
Render Dashboard
  └── Click "New +"
      └── Select "PostgreSQL"
          └── Configure (name, region, plan)
              └── Click "Create Database"
                  └── Copy connection string
```

### Setting Environment Variables:
```
Your Web Service
  └── "Environment" tab
      └── Click "Add Environment Variable"
          └── Enter Key and Value
              └── Click "Save Changes"
                  └── Repeat for each variable
```

---

## ✅ Checklist

**PostgreSQL:**
- [ ] Created PostgreSQL database
- [ ] Copied connection string
- [ ] Database is running (not paused)

**Environment Variables:**
- [ ] `DATABASE_URL` set (or linked automatically)
- [ ] `JWT_SECRET` set (generated secure token)
- [ ] `CORS_ORIGINS` set to `*`
- [ ] `ENVIRONMENT` set to `production`
- [ ] `REDIS_URL` set (if using Redis)

---

## 🚀 After Setting Variables

1. **Render auto-redeploys** when you save environment variables
2. **Go to "Events" tab** to watch deployment
3. **Wait for:** "Deploy successful"
4. **Test your service:**
   ```bash
   curl https://your-app.onrender.com/v1/health
   ```

---

## 🆘 Troubleshooting

### Database Connection Error

**Check:**
- `DATABASE_URL` is set correctly
- Database is in same region as service
- Database is running (not paused)
- Connection string format is correct

### Variable Not Saving

**Check:**
- Click "Save Changes" after each variable
- No spaces around `=` sign
- Values are in quotes if they contain special characters

### Service Can't Connect to Database

**Check:**
- Database and service are in same project
- `DATABASE_URL` is correct
- Database is provisioned and running
- Check service logs for connection errors

---

## 📝 Quick Reference

**Generate JWT Secret:**
```bash
python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
```

**Test Database Connection:**
- Check service logs after deployment
- Look for database connection messages
- Test health endpoint: `/v1/health/db`

---

**Follow these steps to add PostgreSQL and set environment variables in Render!** ✅

