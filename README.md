# nat64-test-bed

A facility for testing NAT64 capabilities. The NAT64 test bed consists of a set of Docker containers simulating a real-world NAT64 environment.

# Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Some familiarity with Docker and shell scripting.

# Testing the Setup

To ensure the nat64 test bed runs properly on your machine, try running the `test.sh` script. This will start the network of containers, then run a simple test on the client container. This test will attempt to make an HTTP request over IPv6 using the test server's NAT64'd address.

# Using the Test Bed

To test your code in the NAT64 environment, you will need to edit the client container definition in `client.dockerfile`. First, examine what the file is currently doing:
1. A number of packages are installed using `apt-get`.
2. Useful scripts are copied into the container.
3. The scripts are used to:
  i. Configure routing on the container.
  ii. Wait for the test server to start.
  iii. Run the actual test.

In editing the dockerfile, make sure you retain the following properties:
  - Routing is configured (via the script in `client-scripts/configure-routing.sh`) before the tests are run.
  - If using the test server, the `wait-for-server` command is used to ensure the server is up before the tests are run. If you are not using the test server, you can skip this step.
  - The tests produce a non-zero exit code on failure and this exit code is output by the container.

The easiest way to make the dockerfile fit your needs will likely involve the following:
1. Add to the `apt-get` line to install whatever additional packages your test will need (e.g. your language toolchain).
2. Copy over necessary resources from the host OS to the container using the `COPY` directive (e.g. the code you want to test). If you do not want to copy these resources into the nat64-test-bed directory, you will need to edit the context defined for the client service in the `docker-compose.yml` file.
3. Edit the test script in `client-scripts/do-test.sh` to run your tests in the container, using the packages you installed in step 1 and the resources you copied over in step 2.

Once you have edited `client.dockerfile` to suit your needs, you can run your test via the `test.sh` script. If you have made your edits appropriately, the script should output anything your test writes to stdout or stderr and should exit with the exit code returned by your test.

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
