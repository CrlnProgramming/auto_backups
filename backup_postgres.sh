#!/bin/bash
set -e

DB_USER=""
DB_NAME=""
DB_HOST=""
DB_PORT=""
DB_PASSWORD=""
DATE=$(date +%Y_%m_%d_%H-%M-%S)
MINIO_BUCKET=""
BRANCH=""
BACKUP_DIR="/var/backups"

BACKUP_FILE_SQL="$BACKUP_DIR/$DB_NAME-$DATE-$BRANCH.sql"

export PGPASSWORD=$DB_PASSWORD

pg_dump -U $DB_USER -h $DB_HOST -p $DB_PORT $DB_NAME > $BACKUP_FILE_SQL

unset PGPASSWORD

echo "Upload to MinIO"
mc cp $BACKUP_FILE_SQL myminio/$MINIO_BUCKET/

#delete if expired 2 days
find $BACKUP_DIR -type f -name "*.sql" -mtime +2 -exec rm -f {} \;

#Status
if [ $? -eq 0 ]; then
  echo "Backup successfully created: $BACKUP_FILE_SQL, $BACKUP_FILE_DUMP local and had uploded on the bucket Minio"
else
  echo "Error creating backup"
fi
