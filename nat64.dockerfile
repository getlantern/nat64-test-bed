# tayga is a NAT64 implementation for Linux:
# http://www.litech.org/tayga/
#
# More information on this image can be found here:
# https://github.com/danehans/docker-tayga
FROM danehans/tayga:latest

ARG GATEWAY_IP

# TODO: remove tshark and DEBIAN_FRONTEND
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y iproute2 tshark

# /docker-entry.sh is a file in the base image. We want to run our own entry file instead.
RUN mv /docker-entry.sh /start-tayga.sh

RUN echo 2000 CustomTable >> /etc/iproute2/rt_tables
RUN echo "#!/bin/bash" > /configure-gateway-routing.sh
RUN echo "ip rule add from ${TAYGA_CONF_DYNAMIC_POOL} lookup CustomTable" >> /configure-gateway-routing.sh
RUN echo "ip route add default via ${GATEWAY_IP} dev eth0 table CustomTable" >> /configure-gateway-routing.sh
RUN chmod +x /configure-gateway-routing.sh

RUN echo "#!/bin/bash" > /docker-entry.sh
RUN echo "/configure-gateway-routing.sh" >> /docker-entry.sh
RUN echo "/start-tayga.sh" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]