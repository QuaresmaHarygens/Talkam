#!/bin/bash

# Fly.io Setup - Run These Commands Now
# Copy and paste each section into your terminal

set -e

echo "🚀 Fly.io Setup - Run These Commands"
echo ""
echo "Make sure to add Fly to PATH first:"
echo "export PATH=\"\$HOME/.fly/bin:\$PATH\""
echo ""

# Step 1: Login
echo "════════════════════════════════════════"
echo "Step 1: Login to Fly.io"
echo "════════════════════════════════════════"
echo "Run: fly auth login"
echo "(Opens browser for authentication)"
echo ""

# Step 2: Initialize
echo "════════════════════════════════════════"
echo "Step 2: Initialize App"
echo "════════════════════════════════════════"
echo "Run:"
echo "  cd backend"
echo "  fly launch"
echo ""
echo "When prompted:"
echo "  • App name: talkam-backend (or press Enter)"
echo "  • Region: Choose closest (e.g., iad)"
echo "  • PostgreSQL: YES ✅"
echo "  • Redis: NO"
echo "  • Deploy now: NO (set secrets first)"
echo ""

# Step 3: Set Secrets
echo "════════════════════════════════════════"
echo "Step 3: Set Secrets"
echo "════════════════════════════════════════"
echo "Run:"
echo "  fly secrets set JWT_SECRET=\"8kes0ZPi4IbjVE7B_LXWma8Pj0m1Xk3Uc-5KuokGVnU\""
echo "  fly secrets set CORS_ORIGINS=\"*\""
echo "  fly secrets set ENVIRONMENT=\"production\""
echo ""
echo "Verify:"
echo "  fly secrets list"
echo ""

# Step 4: Deploy
echo "════════════════════════════════════════"
echo "Step 4: Deploy"
echo "════════════════════════════════════════"
echo "Run:"
echo "  fly deploy"
echo ""
echo "Watch the deployment logs"
echo "Get URL when done: fly status"
echo ""

echo "✅ Follow these steps in order!"

