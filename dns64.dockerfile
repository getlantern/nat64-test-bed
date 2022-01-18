FROM resystit/bind9:latest

ARG NAT64_PREFIX
ARG NAT64_IPV6_ADDR
ARG MY_IPV4

RUN ip -6 route add ${NAT64_PREFIX} via ${NAT64_IPV6_ADDR}
RUN ip addr del ${MY_IPV4} dev eth0