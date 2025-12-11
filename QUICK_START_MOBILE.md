# Quick Start: View Mobile App in Full Display

## 🎯 Fastest Way (3 Commands)

### Terminal 1: Start Backend
```bash
cd backend && source .venv/bin/activate && uvicorn app.main:app --reload
```

### Terminal 2: Open Simulator & Run App
```bash
# Open iOS Simulator (macOS)
open -a Simulator

# Wait 5 seconds, then run app
cd mobile && flutter run
```

### View Full Display:
- **iOS Simulator**: Press `Cmd+1` or Window → Physical Size
- **Android**: Resize window or set scale in AVD settings

## 🚀 One-Command Launch

```bash
./scripts/launch_mobile_app.sh
```

This does everything automatically!

## 📱 What You'll See

1. **Welcome Screen** - Tap "Get started"
2. **Login Screen** - Use test credentials or sign up
3. **Home Screen** - Reports feed with navigation
4. **Create Report** - Category grid, media upload
5. **Report Details** - Map view, tabs
6. **Settings** - All options

## 🎨 Full Display Tips

### iOS Simulator:
- `Cmd+1` = Physical Size (actual device size)
- `Cmd+2` = Pixel Perfect (1:1 pixels)
- `Cmd+3` = 75% scale
- Drag window = Custom size

### Android Emulator:
- Drag corners to resize
- Extended Controls → Settings → Scale
- Or: Edit AVD → Advanced Settings → Scale

## 🧪 Test It:

1. Login: `231770000001` / `AdminPass123!`
2. Create a report
3. Add photo/video
4. View report details
5. Check settings

---

**That's it! Your app is now running in full display! 🎉**
