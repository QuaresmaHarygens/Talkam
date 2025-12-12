# PythonAnywhere WSGI Configuration

## 📝 WSGI File Template

**Location:** `/var/www/quaresmaharijgens_pythonanywhere_com_wsgi.py`

**Replace `yourusername` with your actual PythonAnywhere username!**

---

## ✅ Complete WSGI File

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

# Export for WSGI (PythonAnywhere requires 'application')
application = app
```

---

## 🔧 Customization

**If your paths are different, update:**

1. **Project path:**
   ```python
   project_home = '/home/yourusername/Talkam/backend'
   ```
   Change to your actual project path

2. **Virtual environment path:**
   ```python
   activate_this = '/home/yourusername/Talkam/backend/talkam_env/bin/activate_this.py'
   ```
   Change to your actual venv path

3. **Import path:**
   ```python
   from app.main import app
   ```
   This should match your FastAPI app location

---

## ⚠️ Important Notes

1. **Variable name:** Must be `application` (not `app`)
2. **Virtual environment:** Must be activated
3. **Project path:** Must be in `sys.path`
4. **Replace `yourusername`:** With your actual username everywhere!

---

## 🆘 Troubleshooting

### Import Error

**Check:**
- Project path is correct
- Virtual environment is activated
- Dependencies are installed

### Module Not Found

**Check:**
- `sys.path` includes project directory
- Virtual environment has all packages
- Import path is correct

### Application Not Found

**Check:**
- Variable is named `application` (not `app`)
- FastAPI app is imported correctly
- WSGI file is saved

---

**Copy this template and customize for your setup!** ✅
