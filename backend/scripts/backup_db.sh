#!/bin/bash
# Database backup script

set -e

# Configuration
DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-talkam}"
DB_USER="${POSTGRES_USER:-talkam}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/talkam_backup_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting database backup..."
echo "Database: $DB_NAME"
echo "Backup file: $BACKUP_FILE"

# Perform backup
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -F c \
    -f "${BACKUP_FILE}.dump"

# Also create SQL dump
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -f "$BACKUP_FILE"

# Compress SQL dump
gzip "$BACKUP_FILE"

echo "Backup completed: ${BACKUP_FILE}.gz"
echo "Custom format dump: ${BACKUP_FILE}.dump"

# Optional: Upload to S3 or remote storage
if [ -n "$S3_BACKUP_BUCKET" ]; then
    echo "Uploading to S3..."
    aws s3 cp "${BACKUP_FILE}.gz" "s3://${S3_BACKUP_BUCKET}/database/"
    aws s3 cp "${BACKUP_FILE}.dump" "s3://${S3_BACKUP_BUCKET}/database/"
    echo "Upload completed"
fi

# Cleanup old backups (keep last 7 days)
find "$BACKUP_DIR" -name "talkam_backup_*.sql.gz" -mtime +7 -delete
find "$BACKUP_DIR" -name "talkam_backup_*.dump" -mtime +7 -delete

echo "Backup process completed successfully"
