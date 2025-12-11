#!/bin/bash
# Start backend API server

set -e

cd "$(dirname "$0")/../backend"

# Activate virtual environment
if [ ! -d ".venv" ]; then
    echo "❌ Virtual environment not found. Run ./scripts/start_dev.sh first"
    exit 1
fi

source .venv/bin/activate

# Set Python path
export PYTHONPATH="$(pwd)"

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from example..."
    cp .env.example .env
    echo "⚠️  Please update backend/.env with your configuration"
fi

echo "🚀 Starting Talkam Liberia Backend API..."
echo ""
echo "API will be available at:"
echo "  - API: http://127.0.0.1:8000"
echo "  - Docs: http://127.0.0.1:8000/docs"
echo "  - ReDoc: http://127.0.0.1:8000/redoc"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Start server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
