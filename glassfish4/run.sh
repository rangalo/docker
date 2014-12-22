#!/bin/bash

set -e

ADMIN_PASS=${ADMIN_PASS:-secret}
CH_PWFILE="./.admin_pw_changed"

function change_admin_password() {

    echo ""
    echo "=> Changing admin password..."
    /change_admin_pass.expect ${ADMIN_PASS}
    echo "=> Done."
    echo ""
    echo "=> Enabling secure admin..."
    /enable_secure_login.expect ${ADMIN_PASS}
    echo "=> Done."

    touch $CH_PWFILE

    echo "========================================================================"
    echo "You can now connect to this Glassfish server using:"
    echo ""
    echo "     admin:$ADMIN_PASS"
    echo ""
    echo "Please remember to change the above password as soon as possible!"
    echo "========================================================================"
    
}


if [[ ! -f ${CH_PWFILE} ]]; then

    echo "=> Setting up the container for the first time..."
    asadmin start-domain
    change_admin_password
    asadmin stop-domain
    echo "=> Done."
fi

echo "=> Starting the glassfish server..."
asadmin start-domain -w
echo "=> Done."
