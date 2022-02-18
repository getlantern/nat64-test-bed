#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Expects 3 positional arguments"
    exit 1
fi

SERVER_HOST=$1
SERVER_PORT=$2
TIMEOUT_SECONDS=$3

echo "Waiting $TIMEOUT_SECONDS seconds for server at $SERVER_HOST:$SERVER_PORT"

SECONDS_ELAPSED=0
until [ $SECONDS_ELAPSED -ge $TIMEOUT_SECONDS ] || nc -z $SERVER_HOST $SERVER_PORT; do
    sleep 1
    ((SECONDS_ELAPSED++))
done

if [ $SECONDS_ELAPSED -ge $TIMEOUT_SECONDS ]; then
    echo "Timed out waiting for server"
    exit 1
else
    echo "Server up!"
fi