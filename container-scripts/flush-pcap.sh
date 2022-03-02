#!/bin/sh

if [ ! -z "$(pgrep tshark)" ]; then
    # Wait for remaining packets.
    sleep 0.5
    pkill tshark
    # Allow tshark to finish writing buffer.
    sleep 0.5
fi
