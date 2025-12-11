#!/bin/bash
# Start all development servers

echo "🚀 Starting Talkam Liberia Development Environment"
echo ""

# Check prerequisites
command -v python3 >/dev/null 2>&1 || { echo "❌ Python 3 required"; exit 1; }

# Function to check if port is in use
check_port() {
    lsof -ti:$1 >/dev/null 2>&1
}

# Start Backend API
echo "📡 Starting Backend API..."
if check_port 8000; then
    echo "   ⚠️  Port 8000 already in use (backend may already be running)"
else
    cd backend
    if [ ! -d ".venv" ]; then
        echo "   ⚠️  Virtual environment not found. Run setup first."
        exit 1
    fi
    source .venv/bin/activate
    export PYTHONPATH="$(pwd)"
    echo "   ✅ Starting on http://127.0.0.1:8000"
    uvicorn app.main:app --reload --host 127.0.0.1 --port 8000 > /tmp/talkam-backend.log 2>&1 &
    BACKEND_PID=$!
    echo "   ✅ Backend started (PID: $BACKEND_PID)"
    echo "   📝 Logs: tail -f /tmp/talkam-backend.log"
fi

# Wait for backend to start
sleep 3

# Start Admin Dashboard
echo ""
echo "🌐 Starting Admin Dashboard..."
if check_port 3000; then
    echo "   ⚠️  Port 3000 already in use"
else
    cd ../admin-web
    if [ ! -d "node_modules" ]; then
        echo "   📦 Installing dependencies..."
        npm install
    fi
    echo "   ✅ Starting on http://localhost:3000"
    npm run dev > /tmp/talkam-admin.log 2>&1 &
    ADMIN_PID=$!
    echo "   ✅ Admin dashboard started (PID: $ADMIN_PID)"
    echo "   📝 Logs: tail -f /tmp/talkam-admin.log"
fi

echo ""
echo "✅ Development servers started!"
echo ""
echo "🌐 Access Points:"
echo "   📡 Backend API: http://127.0.0.1:8000"
echo "   📖 API Docs: http://127.0.0.1:8000/docs"
echo "   🖥️  Admin Dashboard: http://localhost:3000"
echo ""
echo "📱 Mobile App:"
echo "   cd mobile && flutter run"
echo ""
echo "📝 View Logs:"
echo "   Backend: tail -f /tmp/talkam-backend.log"
echo "   Admin: tail -f /tmp/talkam-admin.log"
echo ""
echo "🛑 To Stop:"
echo "   pkill -f 'uvicorn app.main:app'"
echo "   pkill -f 'vite'"
