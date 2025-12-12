# 🔧 How to Turn OFF Build Command Override in Koyeb

## 📋 Step-by-Step Instructions

### Step 1: Go to Your Service

1. **In Koyeb dashboard, click on your service** "talkam"
2. **You should see the service overview page**

---

### Step 2: Go to Settings

1. **Click "Settings" tab** (top navigation, next to "Overview", "Metrics", "Console")
2. **You'll see the Settings page**

---

### Step 3: Find Build Section

1. **Scroll down** to find the **"Build"** section
2. **Look for "Configure Buildpack"** or **"Build"** section
3. **You should see:**
   - **Build command:** `pip install -e .` (or similar)
   - **Run command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Work directory:** `backend`

---

### Step 4: Turn OFF Build Command Override

**Look for the "Build command" field:**

1. **Find the toggle/switch** next to "Build command"
   - It might say "Override" or have a toggle switch
   - It's probably **ON** (enabled/checked)

2. **Turn it OFF:**
   - **Click the toggle** to turn it OFF
   - Or **uncheck the checkbox**
   - The build command field should become **grayed out** or **disabled**

3. **Verify:**
   - Build command field should be disabled/grayed out
   - This means buildpack will handle it automatically

---

### Step 5: Keep Run Command

**Make sure "Run command" is still set:**

- **Run command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- **Override toggle should be ON** for Run command (this is correct)

---

### Step 6: Save Changes

1. **Click "Save"** button (usually at bottom of page)
2. **Or if there's no Save button, changes might auto-save**

---

### Step 7: Redeploy

1. **Go back to Overview tab**
2. **Click "Redeploy"** button (top right)
3. **Watch the build** - should succeed now! ✅

---

## 🎯 Visual Guide

**What you're looking for:**

```
Settings Page
├── Source
│   └── Repository, Branch, Work directory
├── Build  ← YOU ARE HERE
│   ├── Builder: Buildpack
│   ├── Build command: [pip install -e .] [Override: ON] ← TURN THIS OFF
│   ├── Run command: [uvicorn app.main:app...] [Override: ON] ← KEEP ON
│   └── Work directory: backend
└── Environment Variables
```

**After turning OFF Build command override:**

```
Build Section
├── Builder: Buildpack
├── Build command: [grayed out/disabled] [Override: OFF] ← NOW OFF
├── Run command: [uvicorn app.main:app...] [Override: ON] ← STILL ON
└── Work directory: backend
```

---

## 🔍 Alternative: If You Don't See Toggle

**If there's no toggle, try:**

1. **Clear the Build command field:**
   - Delete the text: `pip install -e .`
   - Leave it **empty**
   - Save

2. **Or set it to empty command:**
   - Set to: `:` (just a colon)
   - Save

---

## 📋 Quick Checklist

- [ ] Go to Settings tab
- [ ] Find Build section
- [ ] Find "Build command" field
- [ ] Turn OFF "Override" toggle (or clear the field)
- [ ] Keep "Run command" with Override ON
- [ ] Save changes
- [ ] Redeploy

---

## 🆘 If You Can't Find It

**Try these locations:**

1. **Settings → Build → Build Command**
2. **Settings → Configure Buildpack → Build Command**
3. **Settings → Advanced → Build Command**

**Or look for:**
- A toggle switch next to "Build command"
- A checkbox labeled "Override"
- An "Edit" button that opens build settings

---

## 🎯 What It Should Look Like

**Before (Current - Causing Error):**
- Build command: `pip install -e .` [Override: ✅ ON]

**After (Fixed):**
- Build command: [disabled/grayed out] [Override: ❌ OFF]

**Run command (Keep this):**
- Run command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT` [Override: ✅ ON]

---

**Go to Settings → Build and turn OFF the Build command override!** 🔧
