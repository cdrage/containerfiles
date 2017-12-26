#!/bin/bash
MYSQL_HOST=${MYSQL_HOST}
MYSQL_USER=root
MYSQL_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_DB=pdns
PDNS_ALLOW_AXFR_IPS=${PDNS_ALLOW_AXFR_IPS:-127.0.0.1}
PDNS_MASTER=${PDNS_MASTER:-yes}
PDNS_SLAVE=${PDNS_SLAVE:-no}
PDNS_CACHE_TTL=${PDNS_CACHE_TTL:-20}
PDNS_DISTRIBUTOR_THREADS=${PDNS_DISTRIBUTOR_THREADS:-3}
PDNS_RECURSIVE_CACHE_TTL=${PDNS_RECURSIVE_CACHE_TTL:-10}

# API
PDNS_API=${PDNS_API:-no}
PDNS_API_KEY=${PDNS_API_KEY:-changeme}
PDNS_WEB_SERVER=${PDNS_WEB_SERVER:-no}
PDNS_WEB_PASSWORD=${PDNS_WEB_PASSWORD:-password}
PDNS_WEB_PORT=${PDNS_WEB_PORT:-80}


POWERADMIN_HOSTMASTER=${POWERADMIN_HOSTMASTER:-}
POWERADMIN_NS1=${POWERADMIN_NS1:-}
POWERADMIN_NS2=${POWERADMIN_NS2:-}

until nc -z ${MYSQL_HOST} 3306; do
    echo "Waiting for database to start up.."
    sleep 1
done

echo "Database has started!"

if mysql -u root -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} "${MYSQL_DB}" >/dev/null 2>&1 </dev/null
then
	echo "Database ${MYSQL_DB} already exists"
else
	mysql -u root -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} -e "CREATE DATABASE ${MYSQL_DB}"
	mysql -u root -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} pdns < /pdns.sql
	mysql -u root -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} pdns < /poweradmin.sql
	rm /pdns.sql /poweradmin.sql
fi

### PDNS
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{PDNS_ALLOW_AXFR_IPS}}/${PDNS_ALLOW_AXFR_IPS}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_MASTER}}/${PDNS_MASTER}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_SLAVE}}/${PDNS_SLAVE}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_CACHE_TTL}}/${PDNS_CACHE_TTL}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_DISTRIBUTOR_THREADS}}/${PDNS_DISTRIBUTOR_THREADS}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_RECURSIVE_CACHE_TTL}}/${PDNS_RECURSIVE_CACHE_TTL}/" /etc/powerdns/pdns.conf

### PDNS API
sed -i "s/{{PDNS_API}}/${PDNS_API}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_API_KEY}}/${PDNS_API_KEY}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_WEB_SERVER}}/${PDNS_WEB_SERVER}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_WEB_PASSWORD}}/${PDNS_WEB_PASSWORD}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_WEB_PORT}}/${PDNS_WEB_PORT}/" /etc/powerdns/pdns.conf

### POWERADMIN
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_HOSTMASTER}}/${POWERADMIN_HOSTMASTER}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_NS1}}/${POWERADMIN_NS1}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_NS2}}/${POWERADMIN_NS2}/" /var/www/html/inc/config.inc.php

exec /usr/bin/supervisord
