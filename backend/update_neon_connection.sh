#!/bin/bash
# Helper script to update .env with Neon connection string

if [ -z "$1" ]; then
    echo "Usage: $0 <neon-connection-string>"
    echo ""
    echo "Example:"
    echo "  $0 'postgresql://user:pass@host.neon.tech/dbname?sslmode=require'"
    echo ""
    echo "The script will automatically convert it to asyncpg format."
    exit 1
fi

CONNECTION_STRING="$1"

# Convert postgresql:// to postgresql+asyncpg://
ASYNC_CONNECTION=$(echo "$CONNECTION_STRING" | sed 's|postgresql://|postgresql+asyncpg://|')

# Update .env file
if [ -f ".env" ]; then
    # Backup existing .env
    cp .env .env.backup
    echo "✅ Backed up existing .env to .env.backup"
    
    # Update POSTGRES_DSN
    if grep -q "^POSTGRES_DSN=" .env; then
        sed -i.bak "s|^POSTGRES_DSN=.*|POSTGRES_DSN=$ASYNC_CONNECTION|" .env
        rm .env.bak 2>/dev/null || true
        echo "✅ Updated POSTGRES_DSN in .env"
    else
        echo "POSTGRES_DSN=$ASYNC_CONNECTION" >> .env
        echo "✅ Added POSTGRES_DSN to .env"
    fi
    
    echo ""
    echo "📝 Updated connection string:"
    echo "   $ASYNC_CONNECTION"
    echo ""
    echo "🧪 Next steps:"
    echo "   1. Test connection: ./test_connection.sh"
    echo "   2. Run migrations: alembic upgrade head"
else
    echo "❌ .env file not found"
    exit 1
fi
