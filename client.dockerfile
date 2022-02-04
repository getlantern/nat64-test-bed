# This is currently just for debugging.

FROM ubuntu:latest

ARG NAT64_PREFIX
ARG NAT64_IPV6_ADDR
ARG MY_IPV4

# Some extra packages are installed for debugging.
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
  curl \
  dnsutils \
  iproute2 \
  iputils-ping \
  net-tools \
  traceroute \
  tshark

RUN echo "#!/bin/bash" > /docker-entry.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "ip addr del ${MY_IPV4}/16 dev eth0" >> /docker-entry.sh
RUN echo "ip -6 route add ${NAT64_PREFIX} via ${NAT64_IPV6_ADDR}" >> /docker-entry.sh
RUN echo "curl -6 -v hub.docker.com" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]

