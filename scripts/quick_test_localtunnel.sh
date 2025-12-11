#!/bin/bash

# Quick test with LocalTunnel - No sign-up needed!
# This creates a public URL for your local backend

set -e

echo "🚀 Quick Test with LocalTunnel"
echo ""
echo "This will:"
echo "  1. Start your backend locally"
echo "  2. Create a public tunnel"
echo "  3. Give you a URL to test remotely"
echo ""

# Check if localtunnel is installed
if ! command -v lt &> /dev/null; then
    echo "📦 Installing LocalTunnel..."
    npm install -g localtunnel
fi

# Check if backend is running
if ! curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "⚠️  Backend not running on port 8000"
    echo ""
    echo "Starting backend in background..."
    cd "$(dirname "$0")/../backend"
    
    # Check if virtual environment exists
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    fi
    
    # Start backend in background
    uvicorn app.main:app --host 0.0.0.0 --port 8000 > /tmp/talkam-backend.log 2>&1 &
    BACKEND_PID=$!
    echo "✅ Backend started (PID: $BACKEND_PID)"
    echo "   Waiting 5 seconds for startup..."
    sleep 5
else
    echo "✅ Backend is already running"
fi

echo ""
echo "🌐 Creating LocalTunnel..."
echo ""

# Create tunnel
lt --port 8000 --print-requests | while read -r line; do
    if [[ $line == https://* ]]; then
        TUNNEL_URL="$line"
        echo ""
        echo "✅ Tunnel created!"
        echo ""
        echo "📱 Your public URL:"
        echo "   $TUNNEL_URL"
        echo ""
        echo "🔗 API Endpoint:"
        echo "   ${TUNNEL_URL}/v1"
        echo ""
        echo "🧪 Test it:"
        echo "   curl ${TUNNEL_URL}/v1/health"
        echo ""
        echo "📱 Update mobile app:"
        echo "   ./scripts/update_railway_url.sh ${TUNNEL_URL}"
        echo ""
        echo "⚠️  Note:"
        echo "   • URL changes each time you restart"
        echo "   • Tunnel closes when you stop this script (Ctrl+C)"
        echo "   • Good for quick testing, not production"
        echo ""
        echo "Press Ctrl+C to stop tunnel and backend"
        
        # Save URL to file
        echo "$TUNNEL_URL" > /tmp/talkam-tunnel-url.txt
    else
        echo "$line"
    fi
done

