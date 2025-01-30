#!/bin/bash

#backups
DATE=$(date +%Y_%m_%d_%H-%M-%S)
MINIO_BUCKET=""
MINIO_BUCKET_VALUE=""
BRANCH=""
BACKUP_DIR="/var/backups/"
BACKUP_DIR_VALUE="/opt"
BACKUPFILE="volumes_backup_${DATE}_${BRANCH}.tar.gz"

cd $BACKUP_DIR_VALUE

echo "Doing arhive for the volumes direction"
tar -czvf $BACKUPFILE volumes || { echo "Failed to create archive"; exit 1; }

mv $BACKUPFILE $BACKUP_DIR

cd $BACKUP_DIR

echo "Upload to MinIO"
mc cp $BACKUPFILE myminio/$MINIO_BUCKET_VALUE/

#delete if expired 2 days
find $BACKUP_DIR -type f -name "*volumes_backup_*.tar.gz" -mtime +1 -exec rm -f {} \;

#Status
if [ $? -eq 0 ]; then
  echo "Backup successfully created: $BACKUPFILE local and had uploded on the bucket Minio"
else
  echo "Error creating backup"
fi
