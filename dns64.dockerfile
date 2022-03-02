FROM resystit/bind9:latest

RUN apk update && apk add bash tshark

ARG NAT64_PREFIX
ARG NAT64_IPV6_ADDR
ARG MY_IPV4

COPY ./container-scripts/pcap.sh /usr/local/bin/pcap
COPY ./container-scripts/flush-pcap.sh /usr/local/bin/flush-pcap

RUN echo "#!/bin/sh" > /docker-entry.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "ip -6 route add ${NAT64_PREFIX} via ${NAT64_IPV6_ADDR}" >> /docker-entry.sh
RUN echo "ip addr del ${MY_IPV4} dev eth0" >> /docker-entry.sh
RUN echo "pcap /pcaps/dns64.pcap" >> /docker-entry.sh
RUN echo 'trap "flush-pcap" EXIT' >> /docker-entry.sh
RUN echo "named -c /etc/bind/named.conf -g -u named" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]