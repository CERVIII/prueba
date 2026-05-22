# WordPress Tools

This directory is reserved for additional tools, scripts, or utilities specific to the WordPress service.

## Purpose

According to the Inception subject structure, each service should have a `tools/` directory for:
- WordPress management scripts
- Plugin installation utilities
- Theme customization tools
- Content migration scripts

## Current Status

Currently empty. Add scripts here as needed for:
- Automated plugin installation
- Theme customization
- Content backup and restore
- WP-CLI utility scripts
- Performance optimization tools

## Example Usage

Plugin installation script example:

```bash
# tools/install-plugins.sh
#!/bin/sh
wp-cli.phar plugin install contact-form-7 --activate --allow-root
wp-cli.phar plugin install akismet --activate --allow-root
echo "Plugins installed successfully"
```

Then copy it in the Dockerfile:
```dockerfile
COPY ./tools/install-plugins.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/install-plugins.sh
```

Or call it from the main configuration script:
```bash
# In configure-wordpress.sh
if [ -f /usr/local/bin/install-plugins.sh ]; then
    /usr/local/bin/install-plugins.sh
fi
```
