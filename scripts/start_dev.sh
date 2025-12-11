#!/bin/bash
# Development environment startup script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Starting Talkam Liberia Development Environment"
echo "=================================================="
echo ""

# Check prerequisites
command -v python3 >/dev/null 2>&1 || { echo "❌ Error: Python 3 is required"; exit 1; }

# Check Docker
if command -v docker >/dev/null 2>&1; then
    echo "✅ Docker found"
    DOCKER_AVAILABLE=true
else
    echo "⚠️  Docker not found - using alternative setup"
    DOCKER_AVAILABLE=false
fi

# Step 1: Start Docker services (if available)
if [ "$DOCKER_AVAILABLE" = true ]; then
    echo ""
    echo "📦 Starting Docker services..."
    cd "$PROJECT_ROOT"
    docker compose up -d postgres redis minio
    echo "⏳ Waiting for services to be ready..."
    sleep 5
    echo "✅ Docker services started"
else
    echo ""
    echo "⚠️  Docker not available. Please ensure:"
    echo "   - PostgreSQL is running on localhost:5432"
    echo "   - Redis is running on localhost:6379"
    echo "   - MinIO/S3 is configured (or update .env)"
    echo ""
    read -p "Press Enter to continue..."
fi

# Step 2: Setup backend
echo ""
echo "🐍 Setting up Python backend..."
cd "$PROJECT_ROOT/backend"

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip --quiet
pip install -e .[dev] --quiet

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file from example..."
    cp .env.example .env
    echo "⚠️  Please review and update backend/.env with your settings"
fi

# Step 3: Initialize database
echo ""
echo "🗄️  Initializing database..."
if [ "$DOCKER_AVAILABLE" = true ] || command -v psql >/dev/null 2>&1; then
    # Run migrations
    export PYTHONPATH="$PROJECT_ROOT/backend"
    alembic upgrade head
    echo "✅ Database initialized"
else
    echo "⚠️  Skipping database initialization (PostgreSQL tools not available)"
fi

# Step 4: Verify setup
echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Review backend/.env configuration"
echo "2. Start the API server:"
echo "   cd backend"
echo "   source .venv/bin/activate"
echo "   uvicorn app.main:app --reload"
echo ""
echo "3. Access API documentation:"
echo "   http://127.0.0.1:8000/docs"
echo ""
echo "4. (Optional) Start admin dashboard:"
echo "   cd admin-web"
echo "   npm install"
echo "   npm run dev"
echo ""
