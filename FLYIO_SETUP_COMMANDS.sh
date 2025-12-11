#!/bin/bash

# Fly.io Setup Commands - Run these in order

set -e

echo "🚀 Fly.io Setup Commands"
echo ""

# Step 1: Install Fly CLI
echo "1️⃣ Installing Fly CLI..."
curl -L https://fly.io/install.sh | sh

# Add to PATH
export PATH="$HOME/.fly/bin:$PATH"
echo 'export PATH="$HOME/.fly/bin:$PATH"' >> ~/.zshrc

# Step 2: Verify installation
echo ""
echo "2️⃣ Verifying installation..."
fly version

# Step 3: Login
echo ""
echo "3️⃣ Login to Fly.io..."
echo "   (This will open browser)"
fly auth login

# Step 4: Generate JWT Secret
echo ""
echo "4️⃣ Generating JWT Secret..."
JWT_SECRET=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
echo "   JWT_SECRET: $JWT_SECRET"
echo "   (Save this for Step 6)"

# Step 5: Initialize app
echo ""
echo "5️⃣ Initializing app..."
echo "   Navigate to backend and run: fly launch"
echo "   cd backend"
echo "   fly launch"

# Step 6: Commands to run after fly launch
echo ""
echo "6️⃣ After fly launch, run these commands:"
echo ""
echo "   # Add PostgreSQL (if not added during launch)"
echo "   fly postgres create --name talkam-db"
echo "   fly postgres attach talkam-db"
echo ""
echo "   # Set secrets"
echo "   fly secrets set JWT_SECRET=\"$JWT_SECRET\""
echo "   fly secrets set CORS_ORIGINS=\"*\""
echo "   fly secrets set ENVIRONMENT=\"production\""
echo ""
echo "   # Deploy"
echo "   fly deploy"
echo ""

echo "✅ Setup script complete!"
echo ""
echo "📄 Full guide: FLYIO_NEXT_STEPS.md"

