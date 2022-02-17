# nat64-test-bed

A facility for testing NAT64 capabilities. The NAT64 test bed consists of a set of Docker containers simulating a real-world NAT64 environment.

# Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

# Using the Test Bed

TODO:

# Implementation Details

TODO:

# Connecting to IPv6 Hosts Directly

The default setup for the DNS64 container will resolve all hosts to their NAT64'd IPv6 address. This means that a dual-stack host (one which supports IPv4 and IPv6) will resolve to an IPv6 address with the NAT64 prefix and the host's IPv4 embedded in the suffix. Connections to such hosts will ultimately be made via the host's IPv4 address. Hosts with only an IPv6 address (e.g. ipv6.google.com) will not be resolvable and connections will therefore fail.

A more realistic setup would resolve hosts to their true IPv6 address when possible. To achieve this with the NAT64 test bed, take the following steps:

1. Enable IPv6 support in the Docker daemon by following the instructions in [this article](https://docs.docker.com/config/daemon/ipv6/). Note that as of this writing, IPv6 networking is only supported on Docker daemons running on Linux hosts. The subnet defined in `fixed-cidr-v6` must not overlap with the subnet defined for the `testnet` network in the docker-compose.yml file.
2. Enable NAT for the private IPv6 subnet on the host. This is the IPv6 subnet defined for the `testnet` network in the docker-compose.yml file. Note that a reboot of the host will clear out iptables rules, but [they can be persisted](https://askubuntu.com/a/1072948) if desired.
  ```
  ip6tables -t nat -A POSTROUTING -s fd00:dead:beef::/48 ! -o docker0 -j MASQUERADE
  ```
3. Remove the `exclude { any; }` directive from the `dns64` block in `bind9-named.conf` (just remove the line entirely).

# Debugging

TODO:
