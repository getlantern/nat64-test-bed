#!/bin/sh

# This script is intended to be run on a container. If $PCAP is set to "true", this script will run
# packet capture in the background. Assumes Linux and a tshark installation.

if [ $# -lt 1 ]; then
    echo "Expects 1 positional arguments"
    exit 1
fi

if [ "$PCAP" = "true" ]; then
    tshark -q -i any -w $1 &
    # Give tshark time to start.
    sleep 1
fi

