#!/bin/bash

if [[ ! -f /opt/mysql/initialized ]]; then
    mkdir -p /opt/mysql
    cp -a /var/lib/mysql/* /opt/mysql/
    chmod -R 755 /opt/mysql
fi

# always update permissions in case of user-id being switched
chown -R mysql:mysql /opt/mysql

if [[ ! -f /opt/mysql_password ]]; then
	echo "No mysql password defined"
	exit 1
fi

if [[ ! -f /opt/mysql/initialized ]]; then
	DB_PASSWORD="$(cat "/opt/mysql_password")"
	mysqld --bootstrap \
		--basedir=/usr \
		--datadir=/opt/mysql \
		--plugin-dir=/usr/lib/mysql/plugin \
		--user=mysql <<EOF
UPDATE mysql.user SET Password=PASSWORD('$DB_PASSWORD') WHERE User='root';
FLUSH PRIVILEGES;
GRANT ALL ON *.* to root@'%' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
    touch /opt/mysql/initialized
fi

exec mysqld --basedir=/usr \
	--datadir=/opt/mysql \
	--plugin-dir=/usr/lib/mysql/plugin \
	--user=mysql \
	--pid-file=/var/run/mysqld/mysqld.pid \
	--socket=/var/run/mysqld/mysqld.sock \
	--port=3306
