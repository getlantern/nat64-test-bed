#!/bin/bash

# This script can be used to start the NAT64 network and enter the client container.

set -e
trap "docker-compose down --volumes" EXIT
CLIENT_SCRIPT="hang-client.sh" docker-compose up --build -d
docker-compose exec client /bin/bash
