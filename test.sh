#!/bin/bash

set -e
trap "docker-compose down --volumes" EXIT
docker-compose up --build -d
LOGS=$( docker-compose logs -f client | tee /dev/tty )
EXIT_CODE=$( echo $LOGS | tail -n 2 | head -n 1 | sed 's/^.*exited with code \([^ ]*\).*$/\1/g' )
exit $EXIT_CODE
