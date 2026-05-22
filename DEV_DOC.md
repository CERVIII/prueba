# Developer Documentation

## Overview

This document provides detailed information for developers who need to set up, modify, or maintain the Inception infrastructure. It covers the complete development workflow, from initial setup to deployment and debugging.

## Project Structure

```
inception/
├── Makefile                        # Build automation and orchestration
├── README.md                       # Main project documentation
├── USER_DOC.md                     # User/admin documentation
├── DEV_DOC.md                      # Developer documentation (this file)
├── .gitignore                      # Git ignore rules
├── configure-login.sh              # Script to personalize login name
├── configure-hosts.sh              # Script to configure hosts file
├── anonymize-login.sh              # Script to anonymize before git push
└── srcs/
    ├── .env                        # Environment variables (not in git)
    ├── docker-compose.yml          # Service orchestration definition
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile          # MariaDB container image
        │   ├── .dockerignore       # Files to exclude from build
        │   └── conf/
        │       └── configure-mariadb.sh    # MariaDB initialization script
        ├── nginx/
        │   ├── Dockerfile          # NGINX container image
        │   ├── .dockerignore       # Files to exclude from build
        │   └── conf/
        │       ├── nginx.conf      # NGINX main configuration
        │       └── default.conf    # NGINX server block configuration
        └── wordpress/
            ├── Dockerfile          # WordPress container image
            ├── .dockerignore       # Files to exclude from build
            └── conf/
                └── configure-wordpress.sh  # WordPress setup script
```

## Setting Up the Development Environment

### Prerequisites

Before you begin, ensure you have the following installed:

1. **Docker Engine** (version 20.10 or higher)
   ```bash
   docker --version
   ```

2. **Docker Compose** (version 2.0 or higher)
   ```bash
   docker compose version
   ```

3. **Make utility**
   ```bash
   make --version
   ```

4. **Git** (for version control)
   ```bash
   git --version
   ```

5. **Text editor** (VSCode, Vim, Nano, etc.)

### Initial Setup from Scratch

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd inception
```

#### 2. Configure Your Login

Edit the `Makefile` to set your 42 login:

```makefile
LOGIN = pcervill    # Change this to your login
```

This variable is used throughout the project for:
- Domain name (`pcervill.42.fr`)
- Data directory paths (`/home/pcervill/data/`)
- Configuration file personalization

#### 3. Configure Environment Variables

The `srcs/.env` file contains all environment variables. Review and customize if needed:

```bash
nano srcs/.env
```

**Important variables:**
- `NGINX_HOST`: Domain name (should match `LOGIN.42.fr`)
- `DATA_PATH`: Host directory for persistent data
- Database credentials (`DB_ROOT_PASS`, `WP_DB_USER`, `WP_DB_PASS`)
- WordPress credentials (`WP_ADMIN_USER`, `WP_ADMIN_PASS`, `WP_USER`, `WP_USER_PASS`)

⚠️ **Security:** Never commit the `.env` file. It's already in `.gitignore`.

#### 4. Configure Hosts File

Add the domain to your hosts file for local DNS resolution.

**On Linux/WSL:**
```bash
echo "127.0.0.1 pcervill.42.fr" | sudo tee -a /etc/hosts
```

**On Windows (PowerShell as Administrator):**
```powershell
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 pcervill.42.fr"
```

Verify the entry:
```bash
cat /etc/hosts | grep pcervill
```

#### 5. Create Data Directories

The Makefile will create these automatically, but you can create them manually:

```bash
sudo mkdir -p /home/pcervill/data/mariadb-data
sudo mkdir -p /home/pcervill/data/wordpress-data
```

Set appropriate permissions:
```bash
sudo chown -R $USER:$USER /home/pcervill/data/
```

## Building and Launching

### Using the Makefile

The Makefile provides convenient commands for all operations:

#### Build and Start Everything

```bash
make
```

This runs the `up` target, which:
1. Executes `setup` target (configures files, creates directories)
2. Builds Docker images from Dockerfiles
3. Starts containers with `docker compose up -d --build`

#### Individual Commands

**Build without starting:**
```bash
cd srcs && docker compose build
```

**Start containers (without rebuilding):**
```bash
make start
```

**Stop containers (without removing):**
```bash
make stop
```

**Stop and remove containers:**
```bash
make down
```

**View container status:**
```bash
make status
```

**View logs:**
```bash
make logs
```

**Clean data directories:**
```bash
make clean
```

**Full cleanup (removes images, volumes, everything):**
```bash
make fclean
```

### Building Individual Services

To rebuild only one service:

```bash
cd srcs
docker compose build nginx
docker compose build wordpress
docker compose build mariadb
```

To rebuild without cache (forces fresh build):

```bash
docker compose build --no-cache nginx
```

## Docker Compose Configuration

### Service Definitions

The `docker-compose.yml` defines three services:

#### NGINX Service

```yaml
nginx:
  container_name: nginx
  build: ./requirements/nginx/
  image: nginx:inception
  env_file: .env
  networks:
    - inception
  ports:
    - "443:443"
  restart: on-failure
  volumes:
    - wordpress-data:/var/www/html/
  depends_on:
    - wordpress
```

- **Ports:** Maps host port 443 to container port 443 (HTTPS)
- **Volumes:** Shares WordPress files volume
- **Depends on:** WordPress (ensures WordPress starts first)

#### WordPress Service

```yaml
wordpress:
  container_name: wordpress
  build: ./requirements/wordpress/
  image: wordpress:inception
  env_file: .env
  networks:
    - inception
  restart: on-failure
  volumes:
    - wordpress-data:/var/www/html/
  depends_on:
    - mariadb
```

- **No exposed ports:** Only accessible via Docker network
- **Volumes:** WordPress files stored persistently
- **Depends on:** MariaDB (ensures database is ready)

#### MariaDB Service

```yaml
mariadb:
  container_name: mariadb
  build: ./requirements/mariadb/
  image: mariadb:inception
  env_file: .env
  networks:
    - inception
  restart: on-failure
  volumes:
    - mariadb-data:/var/lib/mysql/
```

- **No exposed ports:** Only accessible via Docker network
- **Volumes:** Database files stored persistently

### Networks

```yaml
networks:
  inception:
    name: inception
    driver: bridge
```

Creates an isolated bridge network for inter-container communication.

### Volumes

```yaml
volumes:
  mariadb-data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: ${DATA_PATH}/mariadb-data
  wordpress-data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: ${DATA_PATH}/wordpress-data
```

Uses bind mounts to map container paths to host directories.

## Dockerfile Details

### NGINX Dockerfile

**Location:** `srcs/requirements/nginx/Dockerfile`

```dockerfile
FROM alpine:3.21

# Install NGINX
RUN apk update && apk upgrade && \
    apk add nginx && \
    mkdir -p /var/www/html/

# Copy configuration
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/default.conf /etc/nginx/http.d/default.conf

# Generate SSL certificate
RUN apk add openssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx-selfsigned.key \
        -out /etc/ssl/certs/nginx-selfsigned.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42Network/OU=42Paris/CN=nginx_host_example"

# Setup user and permissions
RUN adduser -D -g 'www' www && \
    chown -R www:www /run/nginx/ && \
    chown -R www:www /var/www/html/

EXPOSE 443/tcp

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```

**Key points:**
- Uses Alpine Linux 3.21 (lightweight base)
- Generates self-signed SSL certificate with OpenSSL
- Runs NGINX in foreground (`daemon off`) for Docker compatibility
- Exposes port 443 for HTTPS

### WordPress Dockerfile

**Location:** `srcs/requirements/wordpress/Dockerfile`

```dockerfile
FROM alpine:3.21

# Install PHP 8.3 and dependencies
RUN apk update && apk upgrade && \
    apk add php83 php83-fpm [... many PHP extensions ...] && \
    apk add mariadb-client

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf

# Install WP-CLI
RUN apk add curl && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/bin/wp-cli.phar

# Copy configuration script
COPY ./conf/configure-wordpress.sh /tmp/configure-wordpress.sh
RUN chmod +x /tmp/configure-wordpress.sh

WORKDIR /var/www/html/wordpress

ENTRYPOINT ["sh", "/tmp/configure-wordpress.sh"]
```

**Key points:**
- Installs PHP 8.3 with all necessary extensions
- Configures PHP-FPM to listen on network port 9000
- Installs WP-CLI for WordPress management
- Runs initialization script as entrypoint

### MariaDB Dockerfile

**Location:** `srcs/requirements/mariadb/Dockerfile`

```dockerfile
FROM alpine:3.21

# Install MariaDB
RUN apk update && apk upgrade && \
    apk add mariadb mariadb-client

# Copy configuration script
COPY ./conf/configure-mariadb.sh /tmp/configure-mariadb.sh
RUN chmod +x /tmp/configure-mariadb.sh

ENTRYPOINT ["sh", "/tmp/configure-mariadb.sh"]
```

**Key points:**
- Minimal MariaDB installation
- Runs initialization script as entrypoint

## Configuration Scripts

### MariaDB Configuration Script

**Location:** `srcs/requirements/mariadb/conf/configure-mariadb.sh`

**What it does:**
1. Creates MySQL data directory if needed
2. Initializes MySQL database system
3. Creates WordPress database
4. Creates WordPress user with appropriate privileges
5. Configures MariaDB for remote connections
6. Starts MariaDB daemon in foreground

**Key commands:**
- `mysql_install_db`: Initializes database system
- `mysqld --bootstrap`: Runs SQL commands during initialization
- `sed -i`: Modifies configuration to allow remote connections

### WordPress Configuration Script

**Location:** `srcs/requirements/wordpress/conf/configure-wordpress.sh`

**What it does:**
1. Waits for MariaDB to be ready
2. Downloads WordPress core files with WP-CLI
3. Creates `wp-config.php` with database credentials
4. Installs WordPress (creates tables, admin user)
5. Creates additional WordPress user
6. Installs and activates theme
7. Starts PHP-FPM in foreground

**Key commands:**
- `wp-cli.phar core download`: Downloads WordPress
- `wp-cli.phar config create`: Creates configuration file
- `wp-cli.phar core install`: Installs WordPress database
- `wp-cli.phar user create`: Creates users

## Managing Containers

### View Running Containers

```bash
docker ps
```

### View All Containers (including stopped)

```bash
docker ps -a
```

### Execute Commands in Containers

```bash
docker exec <container-name> <command>
```

**Examples:**
```bash
# Access MariaDB
docker exec -it mariadb mariadb -uroot -p${DB_ROOT_PASS}

# Check WordPress PHP version
docker exec wordpress php -v

# Test NGINX configuration
docker exec nginx nginx -t
```

### Interactive Shell in Container

```bash
docker exec -it <container-name> sh
```

**Examples:**
```bash
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh
```

### View Container Logs

```bash
docker logs <container-name>
```

**Follow logs in real-time:**
```bash
docker logs -f <container-name>
```

**View last 50 lines:**
```bash
docker logs --tail 50 <container-name>
```

## Managing Volumes

### List Volumes

```bash
docker volume ls
```

### Inspect Volume Details

```bash
docker volume inspect srcs_mariadb-data
docker volume inspect srcs_wordpress-data
```

### Volume Locations

Since this project uses bind mounts, data is directly accessible:

**MariaDB data:**
```bash
ls -la /home/pcervill/data/mariadb-data/
```

**WordPress files:**
```bash
ls -la /home/pcervill/data/wordpress-data/
```

### Backing Up Volumes

```bash
sudo tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz /home/pcervill/data/
```

### Removing Volumes

⚠️ **Warning:** This deletes all data!

```bash
make clean  # Removes data directories
```

Or manually:
```bash
sudo rm -rf /home/pcervill/data/
```

## Managing Networks

### List Networks

```bash
docker network ls
```

### Inspect Network

```bash
docker network inspect inception
```

Shows connected containers and their IP addresses.

### Test Network Connectivity

From inside a container:

```bash
# From WordPress container, ping MariaDB
docker exec wordpress ping -c 3 mariadb

# From NGINX container, test WordPress connection
docker exec nginx nc -zv wordpress 9000
```

## Data Persistence

### Where Data is Stored

All persistent data is stored on the host machine in bind-mounted directories:

1. **MariaDB Database Files:**
   - **Host Path:** `/home/pcervill/data/mariadb-data/`
   - **Container Path:** `/var/lib/mysql/`
   - **Contents:** MySQL database files, tables, indexes

2. **WordPress Files:**
   - **Host Path:** `/home/pcervill/data/wordpress-data/`
   - **Container Path:** `/var/www/html/`
   - **Contents:** WordPress core, themes, plugins, uploads

### How Persistence Works

- **Bind Mounts:** Docker Compose mounts host directories into containers
- **Lifecycle:** Data persists even when containers are stopped or removed
- **Access:** Files can be directly accessed and modified on the host
- **Backup:** Standard file system backup tools can be used

### Recreating from Persistent Data

If you run `make down` and then `make up` again:

1. Containers are recreated
2. Data directories are re-mounted
3. WordPress configuration is preserved
4. Database is intact
5. No reinstallation needed

### Resetting Everything

To start completely fresh:

```bash
make down      # Stop and remove containers
make clean     # Delete data directories
make          # Rebuild and start from scratch
```

This will:
- Reinstall WordPress
- Recreate the database
- Reset all content to defaults

## Debugging

### Common Issues and Solutions

#### Issue: Container exits immediately after starting

**Diagnosis:**
```bash
docker logs <container-name>
```

**Common causes:**
- Syntax error in configuration script
- Missing environment variable
- PID 1 process exits too quickly

**Solution:**
- Check logs for error messages
- Verify entrypoint script has `exec` for long-running process
- Test script manually inside container

#### Issue: Cannot connect to database from WordPress

**Diagnosis:**
```bash
# Check if MariaDB is listening
docker exec mariadb netstat -tlnp | grep 3306

# Try connecting from WordPress container
docker exec wordpress mariadb -hmariadb -uwp_user -p${WP_DB_PASS}
```

**Common causes:**
- MariaDB not configured for remote connections
- Wrong credentials in `.env`
- WordPress started before MariaDB was ready

**Solution:**
- Check `bind-address` in MariaDB config
- Verify user privileges: `GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'%'`
- Increase `depends_on` wait time or add health checks

#### Issue: NGINX returns 502 Bad Gateway

**Diagnosis:**
```bash
# Check if WordPress is listening on port 9000
docker exec wordpress netstat -tlnp | grep 9000

# Test connection from NGINX
docker exec nginx nc -zv wordpress 9000
```

**Common causes:**
- PHP-FPM not running in WordPress container
- Wrong FastCGI configuration in NGINX
- WordPress container not started

**Solution:**
- Verify PHP-FPM is running: `docker exec wordpress ps aux | grep php-fpm`
- Check NGINX FastCGI config: `fastcgi_pass wordpress:9000;`
- Ensure WordPress container is healthy

#### Issue: SSL certificate errors

This is **expected** with self-signed certificates. Browsers will always warn about them.

**For development:**
- Click "Advanced" and proceed anyway
- Add exception in browser

**For production:**
- Use Let's Encrypt or commercial CA
- Mount real certificates into NGINX container

### Rebuilding After Changes

**After modifying Dockerfiles:**
```bash
make down
cd srcs && docker compose build --no-cache
cd .. && make up
```

**After modifying configuration files:**
```bash
make down
make up
```

Configuration files are copied during build, so changes require rebuild.

**After modifying scripts (configure-*.sh):**
```bash
make down
cd srcs && docker compose build
cd .. && make up
```

Scripts are also copied during build.

## Development Workflow

### Typical Development Cycle

1. **Make changes** to Dockerfiles or scripts
2. **Rebuild affected services:**
   ```bash
   cd srcs && docker compose build <service-name>
   ```
3. **Restart containers:**
   ```bash
   make down && make up
   ```
4. **Check logs for errors:**
   ```bash
   make logs
   ```
5. **Test functionality** in browser or via CLI
6. **Commit changes** to git

### Testing Changes Locally

**Test NGINX config syntax:**
```bash
docker exec nginx nginx -t
```

**Test PHP syntax:**
```bash
docker exec wordpress php -l /path/to/file.php
```

**Test database connectivity:**
```bash
docker exec wordpress mariadb -hmariadb -uwp_user -p${WP_DB_PASS} -e "SHOW DATABASES;"
```

### Git Workflow

**Before committing:**

1. Anonymize login information:
   ```bash
   LOGIN=pcervill ./anonymize-login.sh
   ```

2. Verify `.env` is not tracked:
   ```bash
   git status | grep .env  # Should show nothing
   ```

3. Commit and push:
   ```bash
   git add .
   git commit -m "Your commit message"
   git push
   ```

**After pulling:**

1. Re-configure your login:
   ```bash
   # Edit Makefile to set LOGIN
   make  # This runs configure-login.sh automatically
   ```

## Performance Optimization

### Build Cache

Docker caches layers during build. To optimize:

- Order Dockerfile commands from least to most frequently changed
- Combine related `RUN` commands to reduce layers
- Use `.dockerignore` to exclude unnecessary files

### Runtime Performance

- **Resource limits:** Add resource constraints in `docker-compose.yml`:
  ```yaml
  services:
    nginx:
      deploy:
        resources:
          limits:
            cpus: '0.5'
            memory: 256M
  ```

- **Monitor resource usage:**
  ```bash
  docker stats
  ```

## Security Considerations

### Current Implementation

- Credentials stored in `.env` (not committed to git)
- Self-signed SSL certificates (for development)
- No exposed database port (only accessible via Docker network)
- Minimal Alpine Linux base images (smaller attack surface)

### Production Improvements

1. **Use Docker Secrets:**
   ```yaml
   secrets:
     db_password:
       file: ./secrets/db_password.txt
   ```

2. **Use real SSL certificates** (Let's Encrypt)

3. **Implement health checks:**
   ```yaml
   healthcheck:
     test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
     interval: 10s
     timeout: 5s
     retries: 5
   ```

4. **Run as non-root users** in containers

5. **Regular security updates:**
   ```bash
   # Rebuild with latest Alpine updates
   make down
   cd srcs && docker compose build --no-cache --pull
   cd .. && make up
   ```

## Additional Resources

- **Docker Documentation:** https://docs.docker.com/
- **Docker Compose Reference:** https://docs.docker.com/compose/compose-file/
- **Alpine Linux Package Search:** https://pkgs.alpinelinux.org/
- **WordPress CLI:** https://developer.wordpress.org/cli/commands/
- **MariaDB Knowledge Base:** https://mariadb.com/kb/en/

## Getting Help

If you encounter issues:

1. Check logs: `make logs`
2. Review this documentation
3. Consult the service-specific documentation
4. Check Docker and Docker Compose versions
5. Verify file permissions and ownership
6. Test each service independently
7. Ask peers for review and assistance
