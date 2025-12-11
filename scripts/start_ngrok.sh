#!/bin/bash
# Script to start ngrok tunnel for backend

echo "🚀 Starting ngrok tunnel..."
echo ""
echo "Backend should be running on port 8000"
echo "If not, start it with:"
echo "  cd backend && source .venv/bin/activate"
echo "  uvicorn app.main:app --reload --host 127.0.0.1 --port 8000"
echo ""
echo "Starting ngrok..."
echo ""

ngrok http 8000



