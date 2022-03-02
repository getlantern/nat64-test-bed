FROM ubuntu:latest

# The maximum amount of time the client will spend waiting for the test server container to start.
ENV TEST_SERVER_MAX_WAIT_SECONDS 60

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

ARG NAT64_PREFIX
ARG NAT64_IPV6_ADDR
ARG MY_IPV4
ARG TEST_SERVER_HOST
ARG TEST_SERVER_PORT
ARG TEST_SCRIPT

COPY ./container-scripts/configure-client-routing.sh /configure-client-routing.sh
COPY ./container-scripts/wait-for-server.sh /usr/local/bin/wait-for-server
COPY ./container-scripts/pcap.sh /usr/local/bin/pcap
COPY ./container-scripts/flush-pcap.sh /usr/local/bin/flush-pcap
COPY ./container-scripts/${TEST_SCRIPT} /do-test.sh

RUN echo "#!/bin/bash" > /docker-entry.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "/configure-client-routing.sh ${MY_IPV4} ${NAT64_PREFIX} ${NAT64_IPV6_ADDR}" >> /docker-entry.sh
RUN echo "wait-for-server ${TEST_SERVER_HOST} ${TEST_SERVER_PORT} ${TEST_SERVER_MAX_WAIT_SECONDS}" >> /docker-entry.sh
RUN echo "pcap /pcaps/client.pcap" >> /docker-entry.sh
RUN echo 'trap "flush-pcap" EXIT' >> /docker-entry.sh
RUN echo "/do-test.sh ${TEST_SERVER_HOST} ${TEST_SERVER_PORT}" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]

