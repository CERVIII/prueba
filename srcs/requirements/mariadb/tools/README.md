# MariaDB Tools

This directory is reserved for additional tools, scripts, or utilities specific to the MariaDB service.

## Purpose

According to the Inception subject structure, each service should have a `tools/` directory for:
- Database backup scripts
- Maintenance utilities
- Migration tools
- Performance monitoring scripts

## Current Status

Currently empty. Add scripts here as needed for:
- Automated database backups
- Database health checks
- SQL migration scripts
- Performance monitoring
- User management utilities

## Example Usage

Database backup script example:

```bash
# tools/backup-db.sh
#!/bin/sh
BACKUP_FILE="/backup/db-backup-$(date +%Y%m%d-%H%M%S).sql"
mysqldump -u root -p${DB_ROOT_PASS} --all-databases > $BACKUP_FILE
echo "Backup saved to $BACKUP_FILE"
```

Then copy it in the Dockerfile:
```dockerfile
COPY ./tools/backup-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/backup-db.sh
```
