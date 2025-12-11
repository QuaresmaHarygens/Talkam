#!/bin/bash

# Android Emulator Setup Script

echo "🤖 Android Emulator Setup for Talkam Liberia"
echo "============================================"
echo ""

# Check if Android Studio is installed
echo "1️⃣  Checking Android Studio installation..."
if [ -d "/Applications/Android Studio.app" ]; then
  echo "✅ Android Studio found"
  ANDROID_STUDIO_INSTALLED=true
else
  echo "❌ Android Studio not found"
  ANDROID_STUDIO_INSTALLED=false
fi

# Check ANDROID_HOME
echo ""
echo "2️⃣  Checking Android SDK..."
if [ -n "$ANDROID_HOME" ]; then
  echo "✅ ANDROID_HOME is set: $ANDROID_HOME"
else
  echo "⚠️  ANDROID_HOME not set"
  if [ -d "$HOME/Library/Android/sdk" ]; then
    echo "   Found SDK at: $HOME/Library/Android/sdk"
    echo "   Setting ANDROID_HOME..."
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
    export PATH=$PATH:$ANDROID_HOME/tools
    export PATH=$PATH:$ANDROID_HOME/tools/bin
    
    # Add to shell config
    if [ -f "$HOME/.zshrc" ]; then
      if ! grep -q "ANDROID_HOME" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Android SDK" >> "$HOME/.zshrc"
        echo "export ANDROID_HOME=\$HOME/Library/Android/sdk" >> "$HOME/.zshrc"
        echo "export PATH=\$PATH:\$ANDROID_HOME/emulator" >> "$HOME/.zshrc"
        echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools" >> "$HOME/.zshrc"
        echo "export PATH=\$PATH:\$ANDROID_HOME/tools" >> "$HOME/.zshrc"
        echo "export PATH=\$PATH:\$ANDROID_HOME/tools/bin" >> "$HOME/.zshrc"
        echo "✅ Added to ~/.zshrc"
      fi
    fi
  else
    echo "   SDK not found. Please install Android Studio first."
  fi
fi

# Check Flutter doctor
echo ""
echo "3️⃣  Checking Flutter Android setup..."
flutter doctor | grep -A 5 "Android toolchain"

# Check for emulators
echo ""
echo "4️⃣  Checking for Android emulators..."
if command -v emulator &> /dev/null; then
  AVD_LIST=$(emulator -list-avds 2>/dev/null)
  if [ -n "$AVD_LIST" ]; then
    echo "✅ Found emulators:"
    echo "$AVD_LIST"
  else
    echo "⚠️  No emulators found"
    echo ""
    echo "To create an emulator:"
    echo "1. Open Android Studio"
    echo "2. Tools → Device Manager"
    echo "3. Create Device"
    echo ""
    echo "Or use Flutter:"
    echo "  flutter emulators"
  fi
else
  echo "⚠️  Emulator command not found"
  echo "   Make sure Android SDK is installed and in PATH"
fi

# Check licenses
echo ""
echo "5️⃣  Checking Android licenses..."
if flutter doctor --android-licenses 2>&1 | grep -q "All SDK package licenses accepted"; then
  echo "✅ Android licenses accepted"
else
  echo "⚠️  Need to accept licenses"
  echo "   Run: flutter doctor --android-licenses"
fi

echo ""
echo "============================================"
echo "📋 Next Steps:"
echo ""
if [ "$ANDROID_STUDIO_INSTALLED" = false ]; then
  echo "1. Install Android Studio:"
  echo "   brew install --cask android-studio"
  echo "   Or download from: https://developer.android.com/studio"
  echo ""
fi

echo "2. Accept Android licenses:"
echo "   flutter doctor --android-licenses"
echo ""

echo "3. Create an Android Virtual Device (AVD):"
echo "   - Open Android Studio"
echo "   - Tools → Device Manager → Create Device"
echo "   - Or use: flutter emulators"
echo ""

echo "4. Launch emulator:"
echo "   flutter emulators --launch <emulator_id>"
echo ""

echo "5. Run your app:"
echo "   cd mobile && flutter run -d android"
echo ""

echo "📚 Full guide: See ANDROID_EMULATOR_SETUP.md"
