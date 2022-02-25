FROM resystit/bind9:latest

RUN apk update && apk add tshark

ARG NAT64_PREFIX
ARG NAT64_IPV6_ADDR
ARG MY_IPV4

RUN echo "#!/bin/sh" > /docker-entry.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "ip -6 route add ${NAT64_PREFIX} via ${NAT64_IPV6_ADDR}" >> /docker-entry.sh
RUN echo "ip addr del ${MY_IPV4} dev eth0" >> /docker-entry.sh
RUN echo "named -c /etc/bind/named.conf -g -u named" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]