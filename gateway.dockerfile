FROM ubuntu:latest

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    conntrack \
    iproute2 \
    iptables \
    tshark

ARG MY_IP
ARG NAT64_IP
ARG NAT64_DYN_POOL

COPY ./container-scripts/pcap.sh /usr/local/bin/pcap
COPY ./container-scripts/flush-pcap.sh /usr/local/bin/flush-pcap

RUN echo "#!/bin/bash" > /docker-entry.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "iptables -t nat -A POSTROUTING -j SNAT --to ${MY_IP} -s ${NAT64_DYN_POOL}" >> /docker-entry.sh
RUN echo "ip route add ${NAT64_DYN_POOL} via ${NAT64_IP} dev eth0" >> /docker-entry.sh
RUN echo "pcap /pcaps/gateway.pcap" >> /docker-entry.sh
RUN echo 'trap "flush-pcap" EXIT' >> /docker-entry.sh
RUN echo "conntrack -E" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]
