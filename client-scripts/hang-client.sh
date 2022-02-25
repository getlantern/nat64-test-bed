#!/bin/bash

# This script is used to cause the client container to hang, allowing one to enter the container.

touch /var/log/syslog && tail -f /var/log/syslog