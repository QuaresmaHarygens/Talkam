# Setting Up Neon PostgreSQL (Option B)

## Step-by-Step Guide

### Step 1: Create Neon Account

1. Go to https://neon.tech
2. Click "Sign Up" (can use GitHub, Google, or email)
3. Complete the registration

### Step 2: Create a Project

1. After logging in, click "Create Project"
2. Choose a project name (e.g., "Talkam Liberia")
3. Select region (choose closest to you)
4. Select PostgreSQL version 15 or 16
5. Click "Create Project"

### Step 3: Get Connection String

1. In your Neon dashboard, find your project
2. Click on your project
3. Look for "Connection Details" or "Connection String"
4. Copy the connection string - it will look like:
   ```
   postgresql://user:password@host.neon.tech/neondb?sslmode=require
   ```

### Step 4: Convert to asyncpg Format

Neon provides a standard PostgreSQL connection string. We need to convert it to asyncpg format:

**Original Neon string:**
```
postgresql://user:password@host.neon.tech/neondb?sslmode=require
```

**Converted for asyncpg:**
```
postgresql+asyncpg://user:password@host.neon.tech/neondb?sslmode=require
```

**Key changes:**
- Change `postgresql://` to `postgresql+asyncpg://`
- Keep the rest the same (including SSL mode)

### Step 5: Update .env File

Once you have your connection string, I'll help you update the `.env` file.

---

## Alternative: Supabase

If you prefer Supabase:

1. Go to https://supabase.com
2. Click "Start your project"
3. Create a new project
4. Go to Settings > Database
5. Find "Connection string" under "Connection parameters"
6. Use "URI" format
7. Convert `postgresql://` to `postgresql+asyncpg://`

---

## Next Steps

After you have your connection string:
1. We'll update `backend/.env` with your connection string
2. Test the connection
3. Run database migrations
4. Start the API server

**Ready? Share your Neon connection string and I'll help you configure it!**
