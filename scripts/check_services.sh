#!/bin/bash
# Check if required services are available

echo "🔍 Checking Development Services..."
echo ""

# Check PostgreSQL
echo -n "PostgreSQL: "
if command -v psql >/dev/null 2>&1; then
    if psql -h localhost -U talkam -d talkam -c "SELECT 1;" >/dev/null 2>&1; then
        echo "✅ Running"
    else
        echo "❌ Not accessible (check connection or install Docker)"
    fi
elif docker ps | grep -q talkam_postgres; then
    echo "✅ Running (Docker)"
else
    echo "⚠️  Not running (use managed service or Docker)"
fi

# Check Redis
echo -n "Redis: "
if command -v redis-cli >/dev/null 2>&1; then
    if redis-cli ping >/dev/null 2>&1; then
        echo "✅ Running"
    else
        echo "❌ Not accessible"
    fi
elif docker ps | grep -q talkam_redis; then
    echo "✅ Running (Docker)"
else
    echo "⚠️  Not running (use managed service or Docker)"
fi

# Check MinIO/S3
echo -n "Storage (S3/MinIO): "
if docker ps | grep -q talkam_minio; then
    echo "✅ Running (Docker)"
elif grep -q "s3.amazonaws.com\|minio" backend/.env 2>/dev/null; then
    echo "⚠️  Configured (check credentials)"
else
    echo "⚠️  Not configured"
fi

echo ""
echo "💡 Tip: Services can run via:"
echo "   - Docker: docker compose up -d"
echo "   - Managed services (Neon, Upstash, AWS)"
echo "   - Local installs (brew install postgresql redis)"
