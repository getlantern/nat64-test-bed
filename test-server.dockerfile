# We use a pinned version rather than 'latest' to avoid unnecessary re-builds of the image.
FROM golang:1.17.7

ARG LISTEN_PORT

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y tshark

RUN echo 'package main\n\
\n\
import (\n\
	"fmt"\n\
	"log"\n\
	"net/http"\n\
)\n\
\n\
const addr = "0.0.0.0:'${LISTEN_PORT}'"\n\
\n\
func main() {\n\
	log.Println("listening on", addr)\n\
	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {\n\
		log.Println("received request from", req.RemoteAddr)\n\
		fmt.Fprintln(w, "successfully connected to the test server")\n\
	})\n\
	log.Fatalln(http.ListenAndServe(addr, nil))\n\
}' > main.go

COPY ./container-scripts/pcap.sh /usr/local/bin/pcap
COPY ./container-scripts/flush-pcap.sh /usr/local/bin/flush-pcap

RUN echo "#!/bin/bash" > /docker-entry.sh
RUN echo "set -e" >> /docker-entry.sh
RUN echo "pcap /pcaps/test-server.pcap" >> /docker-entry.sh
RUN echo 'trap "flush-pcap" EXIT' >> /docker-entry.sh
RUN echo "go run main.go" >> /docker-entry.sh
RUN chmod +x /docker-entry.sh

ENTRYPOINT [ "/docker-entry.sh" ]