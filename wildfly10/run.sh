#!/bin/bash

ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_PASS:-secret}


${JBOSS_HOME}/bin/add-user.sh "${ADMIN_USER}"  "${ADMIN_PASS}" -s

echo "========================================================================"
echo "You can now connect to this Wildfly server using:"
echo ""
echo "     ${ADMIN_USER}:$ADMIN_PASS"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"

echo ""
echo "=> starting wildfly..."



${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -bmanagement=0.0.0.0
