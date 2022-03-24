# nat64-test-bed

A facility for testing NAT64 capabilities. The NAT64 test bed consists of a set of Docker containers simulating a real-world NAT64 environment.

# Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Some familiarity with Docker and shell scripting

# Testing the Setup

To ensure the nat64 test bed runs properly on your machine, try running the `test.sh` script. This will start the network of containers, then run a simple test on the client container. This test will attempt to make an HTTP request over IPv6 using the test server's NAT64'd address.

# Using the Test Bed

To test your code in the NAT64 environment, you will need to edit the client container definition in `client.dockerfile`. First, examine what the file is currently doing:

1. A number of packages are installed using `apt-get`.
2. Useful scripts are copied into the container.
3. The scripts are used to:
    1. Configure routing on the container.
    2. Wait for the test server to start.
    3. Run the actual test.

In editing the dockerfile, make sure you retain the following properties:
  - Routing is configured before the tests are run (via the script in `container-scripts/configure-routing.sh`).
  - If using the test server, the `wait-for-server` command is used to ensure the server is up before the tests are run. If you are not using the test server, you can skip this step.
  - The tests produce a non-zero exit code on failure and this exit code is output by the container.

The easiest way to make the dockerfile fit your needs will likely involve the following:
1. Add to the `apt-get` line to install whatever additional packages your test will need (e.g. your language toolchain).
2. Copy over necessary resources from the host OS to the container using the `COPY` directive (e.g. the code you want to test). If you do not want to copy these resources into the nat64-test-bed directory, you will need to edit the context defined for the client service in the `docker-compose.yml` file.
3. Edit the test script in `container-scripts/do-test.sh` to run your tests in the container, using the packages you installed in step 1 and the resources you copied over in step 2.

Once you have edited `client.dockerfile` to suit your needs, you can run your test via the `test.sh` script. If you have made your edits appropriately, the script should output anything your test writes to stdout or stderr and should exit with the exit code returned by your test.

For convenience, a few environment variables will be set in the client container. As of this writing, this includes the following:
- `NAT64_PREFIX`
  The IPv6 prefix used to translate IPv4 addresses. Unless you will be deploying to a controlled environment, this should only be used for debugging. This is because the IPv6 prefix cannot generally be known ahead of time.
- `TEST_SERVER_IPV4`
  This can be used to test connections to IPv4 literals. This is not a common use case, but may be important to support.

To see any other environment variables which may be defined, look at the `environment` section of the client service definition in the `docker-compose.yml` file.

# Implementation Details

The NAT64 test bed consists of a set of Docker containers on a Docker bridge network. The network topology is roughly:

```
+--------+     +-------+     +---------+
| client |<--->| NAT64 |<--->| gateway | <---> public internet via host OS
+--------+     +-------+     +---------+
    |                              |
+-------+                    +-------------+
| DNS64 |                    | test-server |
+-------+                    +-------------+
```

where each container is defined for the following role:

**Client:**
  This container simulates a machine in a NAT64 environment. This machine only has IPv6 connectivity and IPv4 hosts will resolve to an IPv6 address like `<NAT64 prefix>::<embedded IPv4 address>`. Routing of such requests goes through the NAT64 container, to the gateway container, then to the public internet via the host OS. Requests to the test server are likewise routed through the NAT64 container, to the gateway container, then directly to the test server container.

**DNS64:**
  This container acts as the DNS server for the client container, implementing DNS64 address resolution. When the client makes a DNS query for an IPv4 host, the DNS server running on this container returns an address like `<NAT64 prefix>::<embedded IPv4 address>`.

  An important note is that DNS queries for dual-stack hosts (those serving both IPv4 and IPv6) will *also* resolve to a NAT64'd address. Moreover, DNS queries for IPv6-only hosts will fail to resolve. For further explanation of this behavior and a workaround, see [Connecting to IPv6 Hosts Directly](#connecting-to-ipv6-hosts-directly) below.

**NAT64:**
  This container implements IPv6-to-IPv4 address translation for the network using [TAYGA](http://www.litech.org/tayga/). Outbound IPv6 packets from the client container with the NAT64 prefix are routed to the NAT64 container, where they are translated into IPv4 packets. A reverse translation is performed for inbound packets destined for the client container.

**Gateway:**
  The gateway container implements [Source Network Address Translation (SNAT)](https://www.linuxtopia.org/Linux_Firewall_iptables/x4658.html) for the network. This is used to ensure that all packets coming out of the network, destined for the public internet, have the same source IP (the IP of the gateway container).

  The gateway container and this SNAT behavior is actually only necessary for macOS hosts, where Docker-related networking is [quite limited](https://docs.docker.com/desktop/mac/networking/#known-limitations-use-cases-and-workarounds). The gateway container does serve a nice purpose on other hosts in avoiding the need for additional routing rules on the host OS (rules would be required to ensure packets destined for the NAT64 pool of IPv4 addresses go to the NAT64 container, e.g. the static routing rule defined [here](https://github.com/danehans/docker-tayga#detailed-setup)).

**Test Server:**
  This container is not a neccessary component of the test bed; it is provided for convenience and to allow tests to run without the need to hit the public internet (once all images are built).

  This container runs an HTTP server on port 80 and responds to all requests with 200 OK and a brief text body. The host name is provided as an argument to `client.dockerfile` and will resolve to the test server's NAT64'd IPv6 address. If your code can hit the test server, it is working appropriately (for hosts with resolvable IPv4 addresses; things like IPv4 literals may require more advanced testing).


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

A few tools are provided to aid in debugging.

## Entering the Client Container

Generally the client container shuts down, whether the test failed or succeeded. It may be helpful to enter the client container and perform some manual testing. To do so, you can run `./util/enter-client.sh` (from this directory). This will spin up the NAT64 network and attach to the client container via a Bash shell. When you exit the shell, the network will be cleaned up.

While attached to the client container, you can attach to other containers using:
```
docker-compose exec <container-name> /bin/bash
```
replacing `<container-name>` with the name of the container you want to enter, e.g. `gateway` or `nat64`.

## Packet Capture

You can run packet capture on all containers by setting the `PCAP` environment variable to "true". For example,
```
PCAP=true ./test.sh
```
or
```
PCAP=true ./utils/enter-client.sh
```

This will result in packet capture files in the `pcaps` directory in this folder. If you have `tshark` installed, you can view these using commands like
```
tshark -r ./pcaps/client.pcap
```
Alternatively, you can use Wireshark to view the captured packets in a GUI.
