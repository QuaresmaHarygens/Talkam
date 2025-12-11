#!/bin/bash
# Database migration helper script

set -e

cd "$(dirname "$0")/.."

# Check if virtual environment is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Activating virtual environment..."
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    else
        echo "Error: Virtual environment not found. Run: python -m venv .venv"
        exit 1
    fi
fi

# Get command (upgrade, downgrade, revision, etc.)
COMMAND="${1:-upgrade}"
TARGET="${2:-head}"

echo "Running Alembic migration: $COMMAND $TARGET"

case "$COMMAND" in
    upgrade)
        alembic upgrade "$TARGET"
        ;;
    downgrade)
        alembic downgrade "$TARGET"
        ;;
    revision)
        MESSAGE="${3:-}"
        if [ -z "$MESSAGE" ]; then
            echo "Usage: $0 revision <message>"
            exit 1
        fi
        alembic revision --autogenerate -m "$MESSAGE"
        ;;
    history)
        alembic history
        ;;
    current)
        alembic current
        ;;
    *)
        echo "Usage: $0 {upgrade|downgrade|revision|history|current} [target] [message]"
        echo ""
        echo "Examples:"
        echo "  $0 upgrade          # Upgrade to latest"
        echo "  $0 upgrade +1       # Upgrade one version"
        echo "  $0 downgrade -1     # Downgrade one version"
        echo "  $0 revision 'Add users table'  # Create new migration"
        echo "  $0 history          # Show migration history"
        echo "  $0 current          # Show current version"
        exit 1
        ;;
esac

echo "Migration completed successfully"
