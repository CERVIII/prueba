# NGINX Tools

This directory is reserved for additional tools, scripts, or utilities specific to the NGINX service.

## Purpose

According to the Inception subject structure, each service should have a `tools/` directory for:
- Helper scripts
- Maintenance utilities
- Deployment tools
- Custom automation

## Current Status

Currently empty. Add scripts here as needed for:
- SSL certificate renewal automation
- Log rotation scripts
- Configuration validation tools
- Health check scripts
- Backup utilities

## Example Usage

If you create a certificate renewal script:

```bash
# tools/renew-cert.sh
#!/bin/sh
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42Network/OU=42Paris/CN=${NGINX_HOST}"
```

Then copy it in the Dockerfile:
```dockerfile
COPY ./tools/renew-cert.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/renew-cert.sh
```
