# Secrets Directory

This directory contains sensitive credentials and secrets used by the Docker containers.

## ⚠️ Security Warning

**NEVER commit secrets to version control!**

The `.gitignore` file should exclude this directory and its contents from being tracked by Git.

## Expected Files (Example)

According to the Inception subject, this directory should contain files such as:

- `credentials.txt` - General credentials
- `db_password.txt` - Database user password
- `db_root_password.txt` - Database root password

## Current Implementation

This project currently uses environment variables in the `.env` file instead of Docker secrets.

To migrate to Docker secrets (recommended for production):

1. Create secret files in this directory:
   ```bash
   echo "WordPressDBPass456!" > secrets/db_password.txt
   echo "SecureRootPassword123!" > secrets/db_root_password.txt
   ```

2. Update `docker-compose.yml` to use secrets:
   ```yaml
   services:
     mariadb:
       secrets:
         - db_password
         - db_root_password
   
   secrets:
     db_password:
       file: ../secrets/db_password.txt
     db_root_password:
       file: ../secrets/db_root_password.txt
   ```

3. Modify scripts to read from `/run/secrets/` instead of environment variables

## Best Practices

- Set restrictive file permissions: `chmod 600 secrets/*.txt`
- Use different passwords for each environment (dev, staging, prod)
- Rotate secrets regularly
- Never echo or log secret values
- Use Docker secrets in production environments
