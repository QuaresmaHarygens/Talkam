#!/bin/bash

# Install Android SDK Command Line Tools

echo "🔧 Installing Android SDK Command Line Tools"
echo "==========================================="
echo ""

export ANDROID_HOME=$HOME/Library/Android/sdk

# Check if SDK directory exists
if [ ! -d "$ANDROID_HOME" ]; then
  echo "❌ Android SDK not found at $ANDROID_HOME"
  echo "   Please install Android Studio first"
  exit 1
fi

echo "✅ Android SDK found at: $ANDROID_HOME"
echo ""

# Check if cmdline-tools already exists
if [ -d "$ANDROID_HOME/cmdline-tools" ]; then
  echo "⚠️  cmdline-tools directory exists"
  echo "   Checking for latest version..."
fi

# Method 1: Use Android Studio SDK Manager (Recommended)
echo "📋 Installation Methods:"
echo ""
echo "Method 1: Using Android Studio (Easiest)"
echo "  1. Open Android Studio"
echo "  2. Tools → SDK Manager"
echo "  3. SDK Tools tab"
echo "  4. Check 'Android SDK Command-line Tools (latest)'"
echo "  5. Click Apply → OK"
echo ""

# Method 2: Download manually
echo "Method 2: Download Manually"
echo ""

CMD_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip"
CMD_TOOLS_DIR="$ANDROID_HOME/cmdline-tools"
LATEST_DIR="$CMD_TOOLS_DIR/latest"

echo "Downloading command line tools..."
cd /tmp

if [ ! -f "cmdline-tools.zip" ]; then
  echo "Downloading from Google..."
  curl -L -o cmdline-tools.zip "$CMD_TOOLS_URL"
else
  echo "Using existing download..."
fi

if [ ! -f "cmdline-tools.zip" ]; then
  echo "❌ Download failed"
  echo "   Please download manually from:"
  echo "   https://developer.android.com/studio#command-line-tools-only"
  exit 1
fi

echo "Extracting..."
unzip -q -o cmdline-tools.zip -d "$ANDROID_HOME" 2>/dev/null || {
  echo "Extraction failed, trying alternative method..."
  mkdir -p "$LATEST_DIR"
  unzip -q -o cmdline-tools.zip -d "$ANDROID_HOME/cmdline-tools-temp"
  mv "$ANDROID_HOME/cmdline-tools-temp/cmdline-tools"/* "$LATEST_DIR" 2>/dev/null
  rm -rf "$ANDROID_HOME/cmdline-tools-temp"
}

# Verify installation
if [ -d "$LATEST_DIR/bin" ]; then
  echo "✅ Command line tools installed at: $LATEST_DIR"
  echo ""
  echo "Setting up PATH..."
  export PATH=$PATH:$LATEST_DIR/bin
  
  # Add to shell config
  if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "cmdline-tools" "$HOME/.zshrc"; then
      echo "" >> "$HOME/.zshrc"
      echo "# Android SDK Command Line Tools" >> "$HOME/.zshrc"
      echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin" >> "$HOME/.zshrc"
      echo "✅ Added to ~/.zshrc"
    fi
  fi
  
  echo ""
  echo "✅ Installation complete!"
  echo ""
  echo "Next steps:"
  echo "1. Reload shell: source ~/.zshrc"
  echo "2. Accept licenses: flutter doctor --android-licenses"
  echo "3. Verify: sdkmanager --version"
else
  echo "❌ Installation failed"
  echo "   Please use Android Studio method instead"
  exit 1
fi

rm -f /tmp/cmdline-tools.zip
