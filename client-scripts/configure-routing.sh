#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Expects 3 positional arguments"
    exit 1
fi

MY_IPV4=$1
NAT64_PREFIX=$2
NAT64_IPV6_ADDR=$3

set -e
ip addr del $MY_IPV4/16 dev eth0
ip -6 route add $NAT64_PREFIX via $NAT64_IPV6_ADDR