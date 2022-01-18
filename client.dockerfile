# This is currently just for debugging.

FROM ubuntu:latest

ARG NAT64_PREFIX
ARG NAT64_IPV6_ADDR
ARG MY_IPV4

# Some extra packages are installed for debugging.
RUN apt-get update && apt-get install -y \
  curl \
  dnsutils \
  iproute2 \
  iputils-ping \
  net-tools \
  traceroute \
  tshark

RUN ip addr del ${MY_IPV4} dev eth0
RUN ip -6 route add ${NAT64_PREFIX} via ${NAT64_IPV6_ADDR}

ENTRYPOINT [ "curl" "-6", "-v", "hub.docker.com" ]

