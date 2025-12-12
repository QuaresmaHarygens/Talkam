# 🚀 Deploy to PythonAnywhere - Step by Step

## ⭐ Python-Focused Deployment Platform

**Why PythonAnywhere:**
- ✅ **Built for Python** - Optimized for FastAPI
- ✅ **Web-based IDE** - Edit code in browser
- ✅ **Free tier** available
- ✅ **Easy database setup**
- ✅ **No Docker needed**
- ✅ **Simple deployment**

---

## 📋 Step-by-Step Setup

### Step 1: Sign Up for PythonAnywhere

1. **Go to:** https://www.pythonanywhere.com
2. **Click "Pricing"** or **"Sign Up"**
3. **Choose "Beginner" plan** (Free tier)
   - Click "Create a Beginner account"
4. **Sign up with:**
   - Email address
   - Username (choose carefully - used in URL)
   - Password
5. **Verify email** (check inbox)

**⏱️ Time:** ~2 minutes

**📝 Note:** Free tier includes:
- 1 web app
- 512 MB disk space
- MySQL database
- Limited CPU time

---

### Step 2: Access Your Dashboard

1. **After signup, you'll see the dashboard**
2. **Note your username** - Your app URL will be: `https://yourusername.pythonanywhere.com`

**⏱️ Time:** ~30 seconds

---

### Step 3: Upload Your Code

**Option A: Upload via Web Interface (Easiest)**

1. **Click "Files" tab** (top navigation)
2. **Navigate to:** `/home/yourusername/`
3. **Click "Upload a file"** button
4. **Upload your backend folder:**
   - You can upload a ZIP file of your backend
   - Or upload files individually

**Option B: Clone from GitHub (Recommended)**

1. **Click "Consoles" tab**
2. **Click "Bash"** (opens terminal)
3. **Clone your repository:**
   ```bash
   cd ~
   git clone https://github.com/QuaresmaHarygens/Talkam.git
   cd Talkam/backend
   ```

**⏱️ Time:** ~2 minutes

---

### Step 4: Set Up Virtual Environment

1. **In Bash console, navigate to backend:**
   ```bash
   cd ~/Talkam/backend
   ```

2. **Create virtual environment:**
   ```bash
   python3.9 -m venv talkam_env
   ```
   (or `python3.10 -m venv talkam_env` if 3.9 not available)

3. **Activate virtual environment:**
   ```bash
   source talkam_env/bin/activate
   ```

4. **Install dependencies:**
   ```bash
   pip install --upgrade pip
   pip install -e .
   ```

**⏱️ Time:** ~3 minutes

---

### Step 5: Set Up Database

**Option A: Use External Database (Recommended - Neon/Supabase)**

1. **Go to:** https://neon.tech (or https://supabase.com)
2. **Sign up** (free)
3. **Create database**
4. **Copy connection string**
5. **Save for Step 7**

**Option B: Use PythonAnywhere MySQL (Free tier)**

1. **In PythonAnywhere dashboard, click "Databases" tab**
2. **Click "Create database"**
3. **Database name:** `talkam_db`
4. **Password:** (auto-generated, save it!)
5. **Note the connection details**

**⏱️ Time:** ~2 minutes

---

### Step 6: Set Up Redis (Upstash - Free)

1. **Go to:** https://console.upstash.com
2. **Sign up** (free, GitHub easiest)
3. **Create database:**
   - Name: `talkam-redis`
   - Type: Regional
   - Region: Choose closest
4. **Copy Redis URL:**
   - Format: `redis://default:password@host:port`
   - **Save this!**

**⏱️ Time:** ~2 minutes

---

### Step 7: Configure Web App

1. **In PythonAnywhere dashboard, click "Web" tab**
2. **Click "Add a new web app"** button
3. **Configuration:**
   - **Domain:** Leave default (`yourusername.pythonanywhere.com`)
   - **Python version:** Select 3.9 or 3.10
   - **Framework:** Select "Manual configuration"
   - Click "Next"
4. **WSGI Configuration:**
   - Click on the WSGI file link (e.g., `/var/www/yourusername_pythonanywhere_com_wsgi.py`)
   - **Replace the content with:**
   ```python
   import sys
   import os

   # Add your project directory to the path
   project_home = '/home/yourusername/Talkam/backend'
   if project_home not in sys.path:
       sys.path.insert(0, project_home)

   # Activate virtual environment
   activate_this = '/home/yourusername/Talkam/backend/talkam_env/bin/activate_this.py'
   with open(activate_this) as file_:
       exec(file_.read(), dict(__file__=activate_this))

   # Import your FastAPI app
   from app.main import app

   # Export for WSGI
   application = app
   ```
   - **Replace `yourusername` with your actual username!**
   - Click "Save"

5. **Go back to "Web" tab**

**⏱️ Time:** ~3 minutes

---

### Step 8: Set Environment Variables

1. **In "Web" tab, scroll to "Environment variables"**
2. **Add each variable:**

   **Variable 1: SECRET_KEY**
   - Key: `SECRET_KEY`
   - Value: `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
   - Click "Add"

   **Variable 2: DATABASE_URL**
   - Key: `DATABASE_URL`
   - Value: (Your Neon/Supabase connection string)
   - Or for MySQL: `mysql://yourusername:password@yourusername.mysql.pythonanywhere-services.com/yourusername$talkam_db`
   - Click "Add"

   **Variable 3: REDIS_URL**
   - Key: `REDIS_URL`
   - Value: (Your Upstash Redis URL)
   - Click "Add"

   **Variable 4: CORS_ORIGINS**
   - Key: `CORS_ORIGINS`
   - Value: `*`
   - Click "Add"

   **Variable 5: ENVIRONMENT**
   - Key: `ENVIRONMENT`
   - Value: `production`
   - Click "Add"

3. **Click "Reload" button** (top right of Web tab)

**⏱️ Time:** ~2 minutes

---

### Step 9: Configure Static Files (Optional)

1. **In "Web" tab, scroll to "Static files"**
2. **Add static file mapping:**
   - URL: `/static`
   - Directory: `/home/yourusername/Talkam/backend/static`
   - (Create directory if needed)

**⏱️ Time:** ~1 minute

---

### Step 10: Run Database Migrations

1. **In Bash console:**
   ```bash
   cd ~/Talkam/backend
   source talkam_env/bin/activate
   export PYTHONPATH="$(pwd)"
   alembic upgrade head
   ```

**⏱️ Time:** ~1 minute

---

### Step 11: Reload Web App

1. **In "Web" tab, click "Reload" button** (green button, top right)
2. **Wait for reload** (~30 seconds)
3. **Check status** - Should show "Running"

**⏱️ Time:** ~1 minute

---

### Step 12: Test Your Deployment

**Test health endpoint:**
```bash
curl https://yourusername.pythonanywhere.com/health
```

**Or test in browser:**
- Open: `https://yourusername.pythonanywhere.com/health`
- Should see: `{"status":"healthy","service":"talkam-api"}`

**View API docs:**
- Open: `https://yourusername.pythonanywhere.com/docs`
- Should see FastAPI Swagger UI

**✅ If you see the health response, deployment is successful!**

---

### Step 13: Update Mobile App

**Update base URL:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://yourusername.pythonanywhere.com
```

**Replace `yourusername.pythonanywhere.com` with your actual URL!**

**Rebuild APK:**
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🎉 You're Done!

**Your app is live at:**
`https://yourusername.pythonanywhere.com`

**Total time:** ~15 minutes

---

## 🔑 Quick Reference

**Your Secret Key:**
```
9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4
```

**PythonAnywhere URLs:**
- Dashboard: https://www.pythonanywhere.com
- Your app: `https://yourusername.pythonanywhere.com`
- Files: Dashboard → Files tab
- Console: Dashboard → Consoles tab
- Web app: Dashboard → Web tab

**Important Paths:**
- Project: `/home/yourusername/Talkam/backend`
- Virtual env: `/home/yourusername/Talkam/backend/talkam_env`
- WSGI file: `/var/www/yourusername_pythonanywhere_com_wsgi.py`

---

## 🆘 Troubleshooting

### Web App Won't Start

**Check error logs:**
1. Go to "Web" tab
2. Click "Error log" link
3. Read error messages

**Common issues:**
- WSGI file path incorrect
- Virtual environment not activated
- Missing environment variables
- Import errors

### Database Connection Fails

**Verify:**
- `DATABASE_URL` is set correctly
- Database is running
- Connection string format is correct
- For MySQL: Check username format (`yourusername$dbname`)

### Import Errors

**Check:**
- Virtual environment is activated in WSGI file
- Project path is correct in WSGI file
- All dependencies are installed

### App Returns 500 Error

**Check:**
- Error log in "Web" tab
- Environment variables are set
- Database migrations ran successfully

---

## 📊 PythonAnywhere Features

**Free Tier Includes:**
- ✅ 1 web app
- ✅ 512 MB disk space
- ✅ MySQL database
- ✅ Web-based IDE
- ✅ Bash console
- ✅ Scheduled tasks
- ✅ HTTPS included

**Limits:**
- Limited CPU time (100 seconds/day)
- 512 MB disk space
- 1 web app
- Sufficient for development/testing

**Upgrade Options:**
- Hacker plan: $5/month (more resources)
- Web Developer: $12/month (even more)

---

## 📝 Important Notes

### Free Tier Limitations

- **CPU time:** 100 seconds/day
- **Web requests:** Limited
- **Best for:** Development and testing
- **For production:** Consider upgrading

### WSGI Configuration

- Must use `application` variable (not `app`)
- Virtual environment must be activated
- Project path must be in `sys.path`

### Database Options

- **MySQL:** Included (free tier)
- **PostgreSQL:** External (Neon/Supabase recommended)
- **Redis:** External (Upstash recommended)

---

## 🎯 Summary

✅ **Python-focused platform**  
✅ **Web-based IDE**  
✅ **Free tier available**  
✅ **Easy database setup**  
✅ **No Docker needed**  
✅ **~15 minutes setup**  

**Perfect for Python/FastAPI development!** 🚀

---

## 📋 Checklist

- [ ] Signed up for PythonAnywhere
- [ ] Uploaded/cloned code
- [ ] Created virtual environment
- [ ] Installed dependencies
- [ ] Set up database (Neon/Supabase)
- [ ] Set up Redis (Upstash)
- [ ] Configured web app
- [ ] Set WSGI file
- [ ] Set environment variables
- [ ] Ran database migrations
- [ ] Reloaded web app
- [ ] Tested health endpoint
- [ ] Updated mobile app
- [ ] Rebuilt APK

---

**Ready to deploy? Start with Step 1: Sign up at https://www.pythonanywhere.com** 🚀
