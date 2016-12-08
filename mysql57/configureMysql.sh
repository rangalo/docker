#!/bin/bash

set -e

VOLUME_HOME="/var/lib/mysql"
LOG="/var/log/syslog"

ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_PASS:-secret}
ROOT_PASS=${ROOT_PASS:-secret}



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
        mysql -uroot -p${ROOT_PASS} -e "status" > /dev/null 2>&1 && break
    done
}

function changeRootPassword() {
    
    echo "=> Changing root password to: $ROOT_PASS"
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASS';" > /mysql-init.txt
    /usr/bin/mysqld_safe --init-file=/mysql-init.txt > /dev/null 2>&1 &
    LOOP_LIMIT=13
    for (( i=0 ; ; i++ )); do
        if [ ${i} -eq ${LOOP_LIMIT} ]; then
            echo "Timout. Error log is shown below:"
            tail -n 100 ${LOG}
        fi
        echo "=> Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..."
        sleep 5
        mysql -uroot -p${ROOT_PASS} -e "status" > /dev/null 2>&1 && break
    done
    echo "=> Root password changed"
    echo "=> Stopping mysql_safe"
    mysqladmin -u root -p${ROOT_PASS} shutdown
    echo "=> mysql_safe stopped"
}

function createAdminUser() {

    startMySQL

    echo "=> Creating admin user ${ADMIN_USER} with password ${ADMIN_PASS} ..."

    mysql -u root -p${ROOT_PASS} -e "CREATE USER '${ADMIN_USER}'@'localhost' IDENTIFIED BY '${ADMIN_PASS}'"
    mysql -u root -p${ROOT_PASS} -e "GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'localhost' WITH GRANT OPTION"

    mysql -u root -p${ROOT_PASS} -e "CREATE USER '${ADMIN_USER}'@'%' IDENTIFIED BY '${ADMIN_PASS}'"
    mysql -u root -p${ROOT_PASS} -e "GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'%' WITH GRANT OPTION"

    echo "=> Done."

    echo "========================================================================"
    echo "You can now connect to this MySQL Server using:"
    echo ""
    echo "    mysql -u$ADMIN_USER -p$ADMIN_PASS -h<host> -P<port>"
    echo ""
    echo "Please remember to change the above password as soon as possible!"
    echo "MySQL user 'root' has no password but only allows local connections"
    echo "========================================================================"

    mysqladmin -u root -p${ROOT_PASS}  shutdown
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
    # mysql_install_db > /dev/null 2>&1

    mysqld --initialize
    echo "=> Done!"  
    echo "=> Creating admin user ..."
   
    changeRootPassword
    createAdminUser
else
    echo "=> Using an existing volume of MySQL"
fi


echo "=> Starting mysql db"
exec /usr/bin/mysqld_safe --bind-address=0.0.0.0 > /dev/null 2>&1 &






