# Fly.io Current Step Guide 🚀

## 🎯 What Step Are You On?

**Check your current status and proceed:**

---

## ✅ Step 1: Fly CLI Installed?

**Check:**
```bash
export PATH="$HOME/.fly/bin:$PATH"
fly version
```

**If not installed:**
```bash
curl -L https://fly.io/install.sh | sh
export PATH="$HOME/.fly/bin:$PATH"
```

**If command not found:**
```bash
echo 'export PATH="$HOME/.fly/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
fly version
```

---

## ✅ Step 2: Logged In?

**Check:**
```bash
fly auth whoami
```

**If not logged in:**
```bash
fly auth login
```

**Opens browser for authentication**

---

## ✅ Step 3: App Initialized?

**Check:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
ls fly.toml
```

**If fly.toml doesn't exist:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly launch
```

**Follow prompts:**
- App name: `talkam-backend` (or auto-generated)
- Region: Choose closest
- PostgreSQL: **Say "yes"** ✅
- Redis: Say "no"
- Deploy now: Say "no" (set secrets first)

---

## ✅ Step 4: PostgreSQL Added?

**Check:**
```bash
fly postgres list
fly secrets list | grep DATABASE_URL
```

**If not added:**
```bash
fly postgres create --name talkam-db --region iad
fly postgres attach talkam-db
```

---

## ✅ Step 5: Secrets Set?

**Check:**
```bash
fly secrets list
```

**Should see:**
- `DATABASE_URL` (auto-set)
- `JWT_SECRET`
- `CORS_ORIGINS`
- `ENVIRONMENT`

**If not set:**
```bash
fly secrets set JWT_SECRET="8kes0ZPi4IbjVE7B_LXWma8Pj0m1Xk3Uc-5KuokGVnU"
fly secrets set CORS_ORIGINS="*"
fly secrets set ENVIRONMENT="production"
```

---

## ✅ Step 6: Ready to Deploy?

**Once all above are done:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly deploy
```

**Watch deployment logs**

---

## 🎯 Quick Status Check

**Run these to see where you are:**

```bash
# Check CLI
export PATH="$HOME/.fly/bin:$PATH"
fly version

# Check login
fly auth whoami

# Check app
cd "/Users/visionalventure/Watch Liberia/backend"
ls fly.toml

# Check secrets
fly secrets list
```

---

## 📋 Next Action Based on Status

**If CLI not installed:**
→ Install Fly CLI

**If not logged in:**
→ Run `fly auth login`

**If no fly.toml:**
→ Run `fly launch` in backend folder

**If no PostgreSQL:**
→ Run `fly postgres create` and `fly postgres attach`

**If secrets not set:**
→ Run `fly secrets set` commands

**If everything ready:**
→ Run `fly deploy`

---

**Check your status and proceed to the next step!** 🚀

