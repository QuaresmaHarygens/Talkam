#!/bin/bash

# Script to prepare backend for Railway deployment
# Creates a clean package ready for upload

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
DEPLOY_DIR="$PROJECT_ROOT/railway-deploy"

echo "📦 Preparing backend for Railway deployment..."
echo ""

# Create deployment directory
echo "1️⃣ Creating deployment package..."
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"

# Copy backend files (excluding unnecessary files)
echo "2️⃣ Copying backend files..."
cd "$BACKEND_DIR"

# Copy all files except those in .railwayignore
rsync -av \
  --exclude='.venv' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.env' \
  --exclude='.env.*' \
  --exclude='!.env.example' \
  --exclude='*.log' \
  --exclude='*.backup' \
  --exclude='.pytest_cache' \
  --exclude='.coverage' \
  --exclude='htmlcov' \
  --exclude='.DS_Store' \
  --exclude='test_connection.sh' \
  --exclude='update_neon_connection.sh' \
  . "$DEPLOY_DIR/"

echo ""
echo "3️⃣ Verifying required files..."
REQUIRED_FILES=(
  "railway.json"
  "Procfile"
  "pyproject.toml"
  "app/main.py"
  "alembic.ini"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$DEPLOY_DIR/$file" ]; then
    echo "   ✅ $file"
  else
    echo "   ❌ Missing: $file"
    exit 1
  fi
done

echo ""
echo "4️⃣ Creating deployment archive..."
cd "$PROJECT_ROOT"
tar -czf railway-deploy.tar.gz -C railway-deploy .

echo ""
echo "✅ Deployment package ready!"
echo ""
echo "📦 Package location:"
echo "   $PROJECT_ROOT/railway-deploy.tar.gz"
echo ""
echo "📁 Unpacked directory:"
echo "   $DEPLOY_DIR"
echo ""
echo "🚀 Next steps:"
echo "   1. Go to Railway dashboard"
echo "   2. Create Empty Service"
echo "   3. Upload railway-deploy.tar.gz OR"
echo "   4. Connect GitHub repo (recommended)"
echo ""
echo "💡 Tip: Using GitHub is easier - just push your code!"



