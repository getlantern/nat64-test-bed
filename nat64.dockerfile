# tayga is a NAT64 implementation for Linux:
# http://www.litech.org/tayga/
#
# More information on this image can be found here:
# https://github.com/danehans/docker-tayga
FROM danehans/tayga:latest

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    iproute2 \
    tshark

# GATEWAY_IP: IP address of the gateway container
# DOCKER_GATEWAY_IP: IP address of the network gateway configured by Docker
ARG TAYGA_CONF_DYNAMIC_POOL
ARG GATEWAY_IP
ARG DOCKER_GATEWAY_IP

# /docker-entry.sh is a file in the base image. We want to run our own entry file instead.
# Additionally, we need to add a routing rule to ensure traffic from the dynamic pool is routed to
# the gateway container.
RUN mv /docker-entry.sh /start-tayga.sh
RUN head -n -3 /start-tayga.sh > /start-tayga.sh.start
RUN tail -n -3 /start-tayga.sh > /start-tayga.sh.end
RUN mv /start-tayga.sh.start /start-tayga.sh
RUN echo "ip addr add ${DOCKER_GATEWAY_IP} dev nat64" >> /start-tayga.sh
RUN cat /start-tayga.sh.end >> /start-tayga.sh
RUN rm /start-tayga.sh.end
RUN chmod +x /start-tayga.sh

RUN echo 2000 CustomTable >> /etc/iproute2/rt_tables
RUN echo "#!/bin/bash" > /configure-gateway-routing.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "ip rule add from ${TAYGA_CONF_DYNAMIC_POOL} lookup CustomTable" >> /configure-gateway-routing.sh
RUN echo "ip route add default via ${GATEWAY_IP} dev eth0 table CustomTable" >> /configure-gateway-routing.sh
RUN chmod +x /configure-gateway-routing.sh

RUN echo "#!/bin/bash" > /docker-entry.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "/configure-gateway-routing.sh" >> /docker-entry.sh
RUN echo "/start-tayga.sh" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]