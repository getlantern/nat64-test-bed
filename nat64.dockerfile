# tayga is a NAT64 implementation for Linux:
# http://www.litech.org/tayga/
#
# More information on this image can be found here:
# https://github.com/danehans/docker-tayga
FROM danehans/tayga:latest

ARG GATEWAY_IP

RUN apt update && apt install -y iproute2

RUN echo 2000 CustomTable >> /etc/iproute2/rt_tables
RUN ip rule add from ${TAYGA_CONF_DYNAMIC_POOL} lookup CustomTable
RUN ip route add default via ${GATEWAY_IP} dev eth0 table CustomTable