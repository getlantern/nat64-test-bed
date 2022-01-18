FROM ubuntu:latest

ARG MY_IP
ARG NAT64_DYN_POOL

RUN apt update && apt install -y iptables
RUN iptables -t nat -A POSTROUTING -j SNAT --to ${MY_IP} -s ${NAT64_DYN_POOL}