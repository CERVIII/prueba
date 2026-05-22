FROM	alpine:3.21

# Install PHP 8.3 & MariaDB-client dependencies
RUN		apk update && apk upgrade &&\
		apk add php83 php83-fpm php83-bcmath php83-bz2 php83-calendar php83-cli php83-ctype \
			php83-curl php83-dom php83-exif php83-fileinfo php83-gd php83-gmp \
			php83-iconv php83-imap php83-intl php83-json php83-mbstring \
			php83-mysqli php83-mysqlnd php83-openssl php83-pcntl php83-pdo php83-pdo_mysql \
			php83-pdo_pgsql php83-pdo_sqlite php83-pgsql php83-phar php83-posix php83-session \
			php83-shmop php83-simplexml php83-soap php83-sockets php83-sodium php83-sqlite3 \
			php83-sysvsem php83-sysvshm php83-tokenizer php83-xml php83-xmlreader php83-xmlwriter \
			php83-xsl php83-zip php83-zlib &&\
		apk add mariadb-client

# Configure PHP-fpm to listen on internal inception network port 9000
RUN		sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf

# Increase PHP memory limit for WP-CLI
RUN		sed -i 's/memory_limit = .*/memory_limit = 256M/g' /etc/php83/php.ini

# Install WP-CLI
#	Moving wp-cli.phar to /usr/bin/wp-cli.phar rather than /usr/bin/wp to avoid
#	PHP errors for phar vendors files missing. This is a wp-cli bug:
#		https://github.com/wp-cli/config-command/issues/141
#		https://github.com/wp-cli/config-command/issues/31
#		https://github.com/wp-cli/wp-cli/issues/4689#issuecomment-366428642
RUN		apk add curl &&\
		curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&\
		chmod +x wp-cli.phar &&\
		mv wp-cli.phar /usr/bin/wp-cli.phar

# Copy WordPress configuration file
COPY	./conf/configure-wordpress.sh /tmp/configure-wordpress.sh
RUN		chmod +x /tmp/configure-wordpress.sh

WORKDIR /var/www/html/wordpress

# Run the WordPress configuration file at container startup
ENTRYPOINT	[ "sh", "/tmp/configure-wordpress.sh" ]
