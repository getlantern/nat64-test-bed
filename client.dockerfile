# This is currently just for debugging.

FROM ubuntu:latest

ARG NAT64_PREFIX
ARG NAT64_IPV6_ADDR
ARG MY_IPV4

# Some extra packages are installed for debugging.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  curl \
  dnsutils \
  iproute2 \
  iputils-ping \
  net-tools \
  netcat-openbsd \
  traceroute \
  tshark \
  vim

RUN echo "#!/bin/bash" > /docker-entry.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "ip addr del ${MY_IPV4}/16 dev eth0" >> /docker-entry.sh
RUN echo "ip -6 route add ${NAT64_PREFIX} via ${NAT64_IPV6_ADDR}" >> /docker-entry.sh
RUN echo "sleep 1" >> /docker-entry.sh
RUN echo "curl -6 -v http://test-server" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]

