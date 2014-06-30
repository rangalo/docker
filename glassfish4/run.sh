#!/bin/bash

set -e

echo "starting the glassfish server..."
asadmin start-domain -w
