# User Documentation

## Overview

This document provides instructions for end users and system administrators on how to use and manage the Inception infrastructure. The stack consists of a WordPress website backed by a MariaDB database, served securely through NGINX with HTTPS encryption.

## Services Provided

The Inception stack provides the following services:

### 1. WordPress Website
- **Purpose:** Content Management System (CMS) for creating and managing website content
- **Access:** https://madel-va.42.fr
- **Features:**
  - Full WordPress functionality
  - Custom theme (Bravada)
  - User management
  - Content creation and publishing

### 2. NGINX Web Server
- **Purpose:** Reverse proxy and web server with TLS/SSL encryption
- **Features:**
  - HTTPS-only access (port 443)
  - TLSv1.2 and TLSv1.3 support
  - Self-signed SSL certificate
  - Proxies requests to WordPress backend

### 3. MariaDB Database
- **Purpose:** Data storage for WordPress
- **Features:**
  - Persistent data storage
  - Automatic backups via bind mounts
  - Isolated database container

## Getting Started

### Prerequisites

Before using the system, ensure:
- Docker and Docker Compose are installed
- You have access to the host machine with sudo privileges
- The domain `madel-va.42.fr` is configured in your hosts file

### Starting the Infrastructure

To start all services:

```bash
make
```

or

```bash
make up
```

This command will:
1. Build all Docker images (if not already built)
2. Create necessary data directories
3. Start all containers in detached mode
4. Initialize the database (first run only)
5. Install and configure WordPress (first run only)

**Expected output:**
```
[+] Building ...
[+] Running 4/4
 ✔ Network inception         Created
 ✔ Container mariadb         Started
 ✔ Container wordpress       Started
 ✔ Container nginx           Started
```

### Stopping the Infrastructure

To stop all running services without removing them:

```bash
make stop
```

The containers will be stopped but not deleted. Data remains intact.

### Shutting Down Completely

To stop and remove all containers:

```bash
make down
```

This removes the containers but preserves the data volumes in `/home/madel-va/data/`.

### Restarting Services

To restart stopped containers:

```bash
make start
```

## Accessing the Services

### Accessing the WordPress Website

1. Open your web browser
2. Navigate to: **https://madel-va.42.fr**
3. Accept the security warning (due to self-signed certificate)
4. You should see the WordPress homepage

### Accessing the WordPress Admin Panel

1. Go to: **https://madel-va.42.fr/wordpress/wp-admin**
2. Log in with admin credentials (see Credentials section below)
3. You can now manage your website content

### First-Time Setup

On first launch, WordPress is automatically installed with:
- Site title: "Inception Project"
- Admin user and regular user pre-created
- Bravada theme installed and activated

No manual WordPress setup is required.

## Managing Credentials

### Credential Locations

All credentials are stored in environment variables defined in:
- **File:** `srcs/.env`
- **Location:** In the project root directory

⚠️ **Security Note:** The `.env` file contains sensitive information and should never be committed to version control. It is already included in `.gitignore`.

### Default Credentials

**WordPress Administrator:**
- **URL:** https://pcervill.42.fr/wordpress/wp-admin
- **Username:** `pcervill`
- **Password:** `PcervillAdminPass789!`
- **Email:** pcervill@madel-va.42.fr

**WordPress Regular User:**
- **Username:** `cervi`
- **Password:** `CerviPass321!`
- **Email:** user@madel-va.42.fr

**MariaDB Database:**
- **Database Name:** `wordpress_db`
- **Username:** `wp_user`
- **Password:** `WordPressDBPass456!`
- **Root Password:** `SecureRootPassword123!`

### Changing Credentials

To change credentials:

1. **Stop the services:**
   ```bash
   make down
   ```

2. **Edit the `.env` file:**
   ```bash
   nano srcs/.env
   ```

3. **Modify the desired credentials:**
   ```bash
   WP_ADMIN_USER=new_admin
   WP_ADMIN_PASS=NewSecurePassword123!
   # ... etc
   ```

4. **Remove existing data** (required for database changes):
   ```bash
   make clean
   ```

5. **Restart the infrastructure:**
   ```bash
   make
   ```

⚠️ **Warning:** Running `make clean` will delete all existing WordPress content and database data.

## Checking Service Status

### View Container Status

To see if all containers are running:

```bash
make status
```

**Expected output:**
```
NAME        IMAGE               STATUS         PORTS
nginx       nginx:inception     Up 2 minutes   0.0.0.0:443->443/tcp
wordpress   wordpress:inception Up 2 minutes   9000/tcp
mariadb     mariadb:inception   Up 2 minutes   3306/tcp
```

All three containers should show `Up` status.

### View Service Logs

To view logs from all services:

```bash
make logs
```

To follow logs in real-time:

```bash
cd srcs && docker compose logs --follow
```

To view logs for a specific service:

```bash
cd srcs && docker compose logs nginx
cd srcs && docker compose logs wordpress
cd srcs && docker compose logs mariadb
```

### Health Checks

**1. Check NGINX is responding:**
```bash
curl -k https://madel-va.42.fr
```
You should see HTML output from WordPress.

**2. Check WordPress PHP-FPM is running:**
```bash
docker exec wordpress ps aux | grep php-fpm
```

**3. Check MariaDB is accepting connections:**
```bash
docker exec mariadb mariadb -uwp_user -pWordPressDBPass456! wordpress_db -e "SELECT 1;"
```

## Common Administrative Tasks

### Backing Up Data

All persistent data is stored in:
- **MariaDB data:** `/home/madel-va/data/mariadb-data/`
- **WordPress files:** `/home/madel-va/data/wordpress-data/`

To create a backup:

```bash
sudo tar -czf backup-$(date +%Y%m%d).tar.gz /home/madel-va/data/
```

### Restoring from Backup

1. Stop the services:
   ```bash
   make down
   ```

2. Remove current data:
   ```bash
   make clean
   ```

3. Restore backup:
   ```bash
   sudo tar -xzf backup-YYYYMMDD.tar.gz -C /
   ```

4. Restart services:
   ```bash
   make up
   ```

### Accessing Container Shells

To troubleshoot or perform manual operations inside containers:

**NGINX container:**
```bash
docker exec -it nginx sh
```

**WordPress container:**
```bash
docker exec -it wordpress sh
```

**MariaDB container:**
```bash
docker exec -it mariadb sh
```

Type `exit` to leave the container shell.

### Viewing WordPress Files

WordPress files are accessible on the host at:
```bash
ls -la /home/madel-va/data/wordpress-data/wordpress/
```

You can edit theme files, plugins, or configuration directly:
```bash
sudo nano /home/madel-va/data/wordpress-data/wordpress/wp-config.php
```

## Troubleshooting

### Problem: Cannot access https://madel-va.42.fr

**Solutions:**
1. Check that containers are running: `make status`
2. Verify hosts file entry:
   - Windows: `C:\Windows\System32\drivers\etc\hosts`
   - Linux: `/etc/hosts`
   - Should contain: `127.0.0.1 madel-va.42.fr`
3. Check NGINX is listening on port 443:
   ```bash
   docker exec nginx netstat -tlnp | grep 443
   ```

### Problem: Containers keep restarting

**Solutions:**
1. Check logs for errors: `make logs`
2. Common issues:
   - Database not ready before WordPress starts (should resolve automatically)
   - Port 443 already in use: `sudo netstat -tlnp | grep 443`
   - Insufficient permissions on data directories

### Problem: "Error establishing database connection"

**Solutions:**
1. Check MariaDB container is running: `make status`
2. Verify database credentials in `srcs/.env`
3. Check MariaDB logs: `docker logs mariadb`
4. Test database connectivity:
   ```bash
   docker exec wordpress mariadb -hmariadb -uwp_user -pWordPressDBPass456! wordpress_db
   ```

### Problem: SSL certificate warnings

This is **expected behavior**. The project uses a self-signed SSL certificate, which browsers don't trust by default.

**To proceed:**
- **Chrome/Edge:** Click "Advanced" → "Proceed to madel-va.42.fr (unsafe)"
- **Firefox:** Click "Advanced" → "Accept the Risk and Continue"

For production environments, you would use a certificate from a trusted Certificate Authority (e.g., Let's Encrypt).

### Problem: Changes to Dockerfiles not taking effect

**Solution:**
Rebuild the images without cache:
```bash
make down
cd srcs && docker compose build --no-cache
cd .. && make up
```

## Performance Considerations

### Resource Usage

Each container uses minimal resources:
- **NGINX:** ~10-20 MB RAM
- **WordPress (PHP-FPM):** ~50-100 MB RAM
- **MariaDB:** ~100-200 MB RAM

Total: ~200-350 MB RAM (typical)

### Monitoring Resource Usage

```bash
docker stats
```

This shows real-time CPU, memory, and network usage for all containers.

## Security Best Practices

1. **Change default passwords** in production environments
2. **Use Docker secrets** instead of `.env` files for sensitive data in production
3. **Keep software updated:** Rebuild images periodically to get security updates
4. **Restrict file permissions:** Ensure `/home/madel-va/data/` has appropriate permissions
5. **Use a real SSL certificate** from a trusted CA in production
6. **Implement firewall rules** to restrict access to port 443
7. **Regular backups:** Schedule automated backups of the data directories

## Support and Further Information

For developer documentation and setup instructions, see:
- **[DEV_DOC.md](DEV_DOC.md)** - Developer documentation

For project overview and technical decisions, see:
- **[README.md](README.md)** - Main project documentation
