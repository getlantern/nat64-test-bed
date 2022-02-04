FROM ubuntu:latest

ARG MY_IP
ARG NAT64_IP
ARG NAT64_DYN_POOL

# TODO: remove tshark and DEBIAN_FRONTEND
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y conntrack iptables iproute2 tshark iputils-ping netcat-openbsd

RUN echo "#!/bin/bash" > /docker-entry.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "iptables -t nat -A POSTROUTING -j SNAT --to ${MY_IP} -s ${NAT64_DYN_POOL}" >> /docker-entry.sh
RUN echo "ip route add ${NAT64_DYN_POOL} via ${NAT64_IP} dev eth0" >> /docker-entry.sh
RUN echo "conntrack -E" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]
