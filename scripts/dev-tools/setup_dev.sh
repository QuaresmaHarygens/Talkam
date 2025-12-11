#!/bin/bash
# Development environment setup script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Setting up Talkam Liberia development environment..."
echo "Project root: $PROJECT_ROOT"

# Check prerequisites
command -v python3 >/dev/null 2>&1 || { echo "Error: Python 3 is required"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "Warning: Node.js not found (needed for admin dashboard)"; }
command -v docker >/dev/null 2>&1 || { echo "Warning: Docker not found (needed for local services)"; }

# Setup backend
echo ""
echo "=== Setting up Backend ==="
cd "$PROJECT_ROOT/backend"

if [ ! -d ".venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv .venv
fi

echo "Activating virtual environment..."
source .venv/bin/activate

echo "Installing backend dependencies..."
pip install --upgrade pip
pip install -e .[dev]

if [ ! -f ".env" ]; then
    echo "Creating .env file from example..."
    cp .env.example .env
    echo "Please edit backend/.env with your configuration"
fi

# Setup admin dashboard
echo ""
echo "=== Setting up Admin Dashboard ==="
cd "$PROJECT_ROOT/admin-web"

if [ -f "package.json" ]; then
    if [ ! -d "node_modules" ]; then
        echo "Installing admin dashboard dependencies..."
        npm install
    fi
    
    if [ ! -f ".env" ]; then
        echo "Creating .env file..."
        echo "VITE_API_URL=http://127.0.0.1:8000/v1" > .env
    fi
else
    echo "Admin dashboard not found, skipping..."
fi

# Check Docker services
echo ""
echo "=== Checking Docker Services ==="
if command -v docker >/dev/null 2>&1; then
    if docker ps >/dev/null 2>&1; then
        echo "Docker is running"
        echo "Start services with: docker compose up -d"
    else
        echo "Warning: Docker is not running"
    fi
else
    echo "Docker not installed, skipping..."
fi

# Setup complete
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Edit backend/.env with your configuration"
echo "2. Start Docker services: docker compose up -d"
echo "3. Run database migrations: cd backend && ./scripts/migrate.sh upgrade"
echo "4. Start backend API: cd backend && source .venv/bin/activate && uvicorn app.main:app --reload"
echo "5. Start admin dashboard: cd admin-web && npm run dev"
echo ""
