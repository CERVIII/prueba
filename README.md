# Inception

*This project has been created as part of the 42 curriculum by pcervill.*

## Description

Inception is a system administration project that introduces Docker containerization and orchestration. The goal is to build a small infrastructure composed of multiple services running in isolated Docker containers, connected through a custom network, with persistent data storage using volumes.

This project sets up a complete web stack consisting of:
- **NGINX** as a reverse proxy with TLS/SSL encryption
- **WordPress** with PHP-FPM for content management
- **MariaDB** as the database backend

The entire infrastructure is deployed using Docker Compose, with each service running in its own container built from custom Dockerfiles based on Alpine Linux 3.21.

### Key Learning Objectives

- Understanding Docker containerization concepts and best practices
- Writing custom Dockerfiles for different services
- Orchestrating multi-container applications with Docker Compose
- Managing persistent data with Docker volumes
- Securing services with environment variables and secrets
- Configuring network isolation and service communication
- Setting up HTTPS with self-signed SSL certificates

## Instructions

### Prerequisites

- A virtual machine or Linux environment (WSL2 on Windows is supported)
- Docker and Docker Compose installed
- `make` utility
- Sudo privileges for directory creation

### Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Configure your login:**
   
   Edit the `Makefile` and set your 42 login:
   ```makefile
   LOGIN = your_login
   ```

3. **Configure environment variables:**
   
   The `.env` file in `srcs/` contains all necessary environment variables. The default values are already set up, but you should review and customize them if needed:
   - Domain name (default: `pcervill.42.fr`)
   - Database credentials
   - WordPress admin credentials
   - Data storage path

4. **Add domain to hosts file:**
   
   On **Windows** (PowerShell as Administrator):
   ```powershell
   Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 pcervill.42.fr"
   ```
   
   On **Linux/WSL**:
   ```bash
   echo "127.0.0.1 pcervill.42.fr" | sudo tee -a /etc/hosts
   ```

5. **Build and launch the infrastructure:**
   ```bash
   make
   ```
   
   This command will:
   - Configure login-specific files
   - Create necessary data directories
   - Build Docker images from Dockerfiles
   - Start all containers with Docker Compose

### Accessing the Website

Once the containers are running, access the WordPress site at:

**https://pcervill.42.fr**

⚠️ Your browser will show a security warning due to the self-signed SSL certificate. Accept the risk to proceed.

### Available Make Commands

- `make` or `make up` - Build and start all containers
- `make down` - Stop and remove all containers
- `make start` - Start existing containers
- `make stop` - Stop running containers
- `make status` - Show container status
- `make logs` - Display container logs
- `make clean` - Remove data directories
- `make fclean` - Full cleanup (removes all Docker resources)

### Default Credentials

**WordPress Admin:**
- Username: `pcervill`
- Password: `PcervillAdminPass789!`

**WordPress Regular User:**
- Username: `cervi`
- Password: `CerviPass321!`

**Database:**
- Database Name: `wordpress_db`
- Username: `wp_user`
- Password: `WordPressDBPass456!`

## Project Architecture

### Docker Containers

The project consists of three main containers:

1. **nginx** (Port 443)
   - Alpine Linux 3.21 base
   - NGINX web server
   - TLSv1.2 and TLSv1.3 support
   - Self-signed SSL certificate
   - Reverse proxy to WordPress

2. **wordpress** (Port 9000)
   - Alpine Linux 3.21 base
   - PHP 8.3 with PHP-FPM
   - WordPress installed via WP-CLI
   - Connects to MariaDB database

3. **mariadb** (Port 3306)
   - Alpine Linux 3.21 base
   - MariaDB database server
   - Persistent data storage

### Network Architecture

All containers communicate through a custom Docker bridge network named `inception`. Only NGINX is exposed to the host machine on port 443.

```
Host Machine (port 443)
    ↓
NGINX Container (TLS/SSL)
    ↓
WordPress Container (PHP-FPM on port 9000)
    ↓
MariaDB Container (MySQL on port 3306)
```

### Data Persistence

Two Docker volumes ensure data persists across container restarts:

- `mariadb-data` → `/home/pcervill/data/mariadb-data` (database files)
- `wordpress-data` → `/home/pcervill/data/wordpress-data` (WordPress files)

These volumes use bind mounts to the host filesystem for easy backup and inspection.

## Technical Decisions

### Virtual Machines vs Docker

**Docker** was chosen over traditional VMs for this project because:

- **Lightweight:** Containers share the host OS kernel, using fewer resources than full VMs
- **Fast startup:** Containers start in seconds vs minutes for VMs
- **Portability:** Docker images run consistently across different environments
- **Isolation:** Processes are isolated without the overhead of separate OS instances
- **Scalability:** Easier to scale services independently

**Trade-offs:** VMs provide stronger isolation and can run different OS types, but Docker's efficiency and speed make it ideal for microservices architecture.

### Secrets vs Environment Variables

**Current Implementation:** This project uses environment variables stored in `.env` files for configuration.

**Docker Secrets** (recommended for production) provide:
- Encrypted storage and transmission of sensitive data
- Access control at the service level
- No secrets stored in images or version control
- Better security for credentials and API keys

**Environment Variables** are:
- Simpler to implement and debug
- Suitable for non-sensitive configuration
- Easier to override during development
- Less secure as they can be exposed in logs and process listings

**Best Practice:** Use Docker secrets for passwords, API keys, and certificates. Use environment variables for non-sensitive configuration like domain names, ports, and feature flags.

### Docker Network vs Host Network

**Docker Bridge Network (`inception`)** is used because:

- **Isolation:** Containers are isolated from the host and other networks
- **Service Discovery:** Containers can reach each other by name (e.g., `wordpress:9000`)
- **Security:** Only explicitly exposed ports are accessible from the host
- **Flexibility:** Multiple isolated networks can coexist

**Host Network** would:
- Give containers direct access to host network interfaces
- Remove network isolation and security benefits
- Be simpler but less secure
- Not work properly on Windows/Mac Docker Desktop

### Docker Volumes vs Bind Mounts

**Bind Mounts** (used in this project) are chosen because:

- **Transparency:** Data is stored in a known host location (`/home/pcervill/data/`)
- **Easy Access:** Files can be inspected and backed up directly from the host
- **Subject Requirement:** Project specification requires volumes in `/home/login/data`
- **Development:** Easier to modify and debug files during development

**Docker Volumes** would provide:
- Better performance on non-Linux hosts
- Managed by Docker (automatic cleanup, lifecycle management)
- Better portability across Docker environments
- Stronger isolation from host filesystem

## Resources

### Docker Documentation

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Curriculum](https://docker-curriculum.com/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)

### Service-Specific Documentation

**NGINX:**
- [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [NGINX SSL Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [OpenSSL Self-Signed Certificates](https://www.openssl.org/docs/man1.0.2/man1/openssl-req.html)

**MariaDB:**
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Configuring MariaDB with Option Files](https://mariadb.com/kb/en/configuring-mariadb-with-option-files/)
- [MariaDB Remote Access Configuration](https://mariadb.com/kb/en/configuring-mariadb-for-remote-client-access/)

**WordPress:**
- [WordPress Official Documentation](https://wordpress.org/documentation/)
- [WP-CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)

**Alpine Linux:**
- [Alpine Linux Official Site](https://www.alpinelinux.org/)
- [Alpine Linux Packages](https://pkgs.alpinelinux.org/)

### AI Usage in This Project

Throughout the development of this project, AI tools (primarily GitHub Copilot and ChatGPT) were used to accelerate development and improve code quality:

**Tasks where AI was used:**
- **Documentation:** AI assisted in generating comprehensive documentation (README.md, USER_DOC.md, DEV_DOC.md) by providing structured templates and technical explanations.
- **Dockerfile optimization:** Suggestions for best practices in Alpine Linux package installation and layer optimization.
- **Script debugging:** Help with bash script syntax, error handling, and Alpine-specific commands.
- **Configuration examples:** Generated initial configuration templates for NGINX SSL, PHP-FPM, and MariaDB.
- **Code comments:** Enhanced code readability with clear explanatory comments.

**Critical review process:**
- All AI-generated code was thoroughly reviewed and tested
- Configurations were validated against Docker and service-specific documentation
- Security best practices were verified independently
- Peer reviews were conducted to ensure correctness

**Parts NOT generated by AI:**
- Core architecture decisions (network topology, volume structure)
- Docker Compose orchestration logic
- Security implementation (secrets, environment variables)
- Project-specific customizations and requirements

AI was used as a productivity tool while maintaining full understanding and ownership of all code and configurations.

### Original Project Resources (for reference)

Docker:
* [Docker Curriculum](https://docker-curriculum.com/)
* [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
* [How to Debug a Docker Compose Build](https://www.matthewsetter.com/basic-docker-compose-debugging/)

Alpine Linux:
* [Alpine Linux](https://www.alpinelinux.org/)

Nginx:
* [NGINX Configuration Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
* [OpenSSL Man Page](https://www.openssl.org/docs/man1.0.2/man1/openssl-req.html)
* [Generate Self-Signed SSL Certificate with OpenSSL](https://stackoverflow.com/a/10176685)

MariaDB:
* [How do I find the MySQL my.cnf location](https://stackoverflow.com/a/2485758)
* [How to Install and Configure Mariadb](https://www.rootusers.com/how-to-install-and-configure-mariadb/)
* [Configuring MariaDB with Option Files](https://mariadb.com/kb/en/configuring-mariadb-with-option-files/)
* [MariaDB Server System Variables](https://mariadb.com/kb/en/server-system-variables/)
* [Configuring MariaDB for Remote Client Access](https://mariadb.com/kb/en/configuring-mariadb-for-remote-client-access/)
* [How to Allow Remote Access to MariaDB in Ubuntu Linux](https://geekrewind.com/allow-remote-access-to-mariadb-database-server-on-ubuntu-18-04/)

WordPress:
* [PHP](https://www.php.net/)
* [Installing WordPress with curl and WP-CLI](https://make.wordpress.org/cli/handbook/guides/installing/)
* [WP-CLI Commands](https://developer.wordpress.org/cli/commands/)
* [WP-CLI Overview](https://jparks.work/index.php?title=Wp-cli)

## License

This project is part of the 42 school curriculum and is intended for educational purposes.
