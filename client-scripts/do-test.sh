#!/bin/bash

# This script is run once the client container and test server are fully configured and running.
# Edit this script as necessary to run your tests.

if [ $# -lt 2 ]; then
    echo "Expects 2 positional arguments"
    exit 1
fi

TEST_SERVER_HOST=$1
TEST_SERVER_PORT=$2

curl -v -6 http://$TEST_SERVER_HOST:$TEST_SERVER_PORT