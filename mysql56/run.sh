#!/bin/bash

set -e

VOLUME_HOME="/var/lib/mysql"
LOG="/var/log/syslog"

ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_USER:-secret}

DB_NAME=${DB_NAME:-testdb}
DB_USER=${DB_USER:-hardik}
DB_PASS=${DB_PASS:-pass}


function startMySQL() {

    /usr/bin/mysqld_safe > /dev/null 2>&1 &

    # timeout in 1 min.
    LOOP_LIMIT=13
    for (( i=0 ; ; i++ )); do
        if [ ${i} -eq ${LOOP_LIMIT} ]; then
            echo "Timout. Error log is shown below:"
            tail -n 100 ${LOG}
        fi
        echo "=> Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..."
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1 && break
    done
}

function createAdminUser() {

    startMySQL

    echo "=> Creating admin user ${ADMIN_USER} with password ${ADMIN_PASS} ..."

    mysql -u root -e "CREATE USER '${ADMIN_USER}'@'localhost' IDENTIFIED BY '${ADMIN_PASS}'"
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'localhost'"
    mysql -u root -e "CREATE USER '${ADMIN_USER}'@'%' IDENTIFIED BY '${ADMIN_PASS}'"
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'%'"

    echo "=> Done."

    echo "========================================================================"
    echo "You can now connect to this MySQL Server using:"
    echo ""
    echo "    mysql -u$ADMIN_USER -p$ADMIN_PASS -h<host> -P<port>"
    echo ""
    echo "Please remember to change the above password as soon as possible!"
    echo "MySQL user 'root' has no password but only allows local connections"
    echo "========================================================================"

    mysqladmin -u root shutdown
}


# disable error log
sed 's/^log_error/# log_error/' -i /etc/mysql/my.cnf

# fix the permissions and ownership
mkdir -p -m 700 /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

# fix the permissions and ownership
mkdir -p -m 0755 /run/mysqld
chown -R mysql:root /run/mysqld

if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Initializing MySQL ..."
    if [ ! -f /usr/share/mysql/my-default.cnf ] ; then
        cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf
    fi 
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    echo "=> Creating admin user ..."
    
    createAdminUser
else
    echo "=> Using an existing volume of MySQL"
fi

if [[ -n ${DB_NAME} ]]; then
    startMySQL
    echo "=> Creating the dabase ${DB_NAME}"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET \`utf8\` COLLATE \`utf8_unicode_ci\`"
    echo "=> Done."

    if [ -n ${DB_USER} ]; then
        echo "=> Granting access to database ${DB_NAME} to user ${DB_USER}"
        mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'"
        mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}'"
        echo "=> Done."
    fi
    mysqladmin -u root shutdown
fi

exec /usr/bin/mysqld_safe






