#!/bin/bash

# Fresh Fly.io App Setup Script
# Run this to create a new Fly.io app for Talkam

set -e

echo "🚀 Creating New Fly.io App for Talkam"
echo ""

# Step 1: Check Fly CLI
echo "1️⃣ Checking Fly CLI..."
export PATH="$HOME/.fly/bin:$PATH"
if ! command -v fly &> /dev/null; then
    echo "   Installing Fly CLI..."
    curl -L https://fly.io/install.sh | sh
    export PATH="$HOME/.fly/bin:$PATH"
fi

fly version
echo "   ✅ Fly CLI ready"
echo ""

# Step 2: Check login
echo "2️⃣ Checking login..."
if ! fly auth whoami &> /dev/null; then
    echo "   Please login:"
    echo "   fly auth login"
    exit 1
fi

fly auth whoami
echo "   ✅ Logged in"
echo ""

# Step 3: Generate JWT Secret
echo "3️⃣ Generating JWT Secret..."
JWT_SECRET=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
echo "   JWT_SECRET: $JWT_SECRET"
echo ""

# Step 4: Navigate to backend
echo "4️⃣ Navigating to backend..."
cd "$(dirname "$0")/../backend"
pwd
echo ""

# Step 5: Create new app
echo "5️⃣ Creating new Fly.io app..."
echo "   Run: fly launch"
echo "   When prompted:"
echo "     • App name: talkam-backend (or press Enter)"
echo "     • Region: Choose closest (e.g., lhr, iad)"
echo "     • PostgreSQL: YES ✅"
echo "     • Redis: NO"
echo "     • Deploy now: NO"
echo ""

# Step 6: Commands to run after fly launch
echo "6️⃣ After fly launch completes, run these commands:"
echo ""
echo "   # Add PostgreSQL (if you said no)"
echo "   fly postgres create --name talkam-db --region lhr"
echo "   fly postgres attach talkam-db"
echo ""
echo "   # Set secrets"
echo "   fly secrets set JWT_SECRET=\"$JWT_SECRET\""
echo "   fly secrets set CORS_ORIGINS=\"*\""
echo "   fly secrets set ENVIRONMENT=\"production\""
echo ""
echo "   # Verify secrets"
echo "   fly secrets list"
echo ""
echo "   # Deploy"
echo "   fly deploy"
echo ""

echo "✅ Setup script complete!"
echo ""
echo "📄 Full guide: FLYIO_FRESH_SETUP.md"
echo ""
echo "🔑 Your JWT Secret: $JWT_SECRET"
