#!/usr/bin/env bash
set -euo pipefail

# Deployment script for Talkam Liberia backend
# Usage: ./scripts/deploy.sh [environment]

ENV=${1:-staging}
cd "$(dirname "$0")/.."

echo "Deploying to $ENV environment..."

# Build Docker image (if using containers)
if command -v docker &> /dev/null; then
  docker build -t talkam-backend:$ENV -f backend/Dockerfile backend/
  echo "Docker image built: talkam-backend:$ENV"
fi

# Run migrations
cd backend
source .venv/bin/activate || python3 -m venv .venv && source .venv/bin/activate
export PYTHONPATH=$(pwd)
alembic upgrade head
echo "Migrations applied"

# Run tests
pytest || { echo "Tests failed - aborting deployment"; exit 1; }
echo "Tests passed"

echo "Deployment to $ENV complete"
