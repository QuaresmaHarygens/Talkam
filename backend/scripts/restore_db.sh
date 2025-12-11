#!/bin/bash
# Database restore script

set -e

# Configuration
DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-talkam}"
DB_USER="${POSTGRES_USER:-talkam}"
BACKUP_FILE="${1:-}"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    echo "Example: $0 backups/talkam_backup_20250205_120000.sql.gz"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "WARNING: This will replace all data in database: $DB_NAME"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read -r

echo "Starting database restore..."
echo "Database: $DB_NAME"
echo "Backup file: $BACKUP_FILE"

# Determine backup format and restore
if [[ "$BACKUP_FILE" == *.dump ]]; then
    # Custom format dump
    echo "Restoring from custom format dump..."
    PGPASSWORD="${POSTGRES_PASSWORD}" pg_restore \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        --clean \
        --if-exists \
        "$BACKUP_FILE"
elif [[ "$BACKUP_FILE" == *.gz ]]; then
    # Gzipped SQL dump
    echo "Restoring from gzipped SQL dump..."
    gunzip -c "$BACKUP_FILE" | PGPASSWORD="${POSTGRES_PASSWORD}" psql \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME"
elif [[ "$BACKUP_FILE" == *.sql ]]; then
    # Plain SQL dump
    echo "Restoring from SQL dump..."
    PGPASSWORD="${POSTGRES_PASSWORD}" psql \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -f "$BACKUP_FILE"
else
    echo "Error: Unknown backup format"
    exit 1
fi

echo "Restore completed successfully"
