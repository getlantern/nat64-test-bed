# We use a pinned version rather than 'latest' to avoid unnecessary re-builds of the image.
FROM golang:1.17.7

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y tshark

RUN echo 'package main\n\
\n\
import (\n\
	"fmt"\n\
	"log"\n\
	"net/http"\n\
)\n\
\n\
const addr = "0.0.0.0:80"\n\
\n\
func main() {\n\
	log.Println("listening on", addr)\n\
	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {\n\
		log.Println("received request from", req.RemoteAddr)\n\
		fmt.Fprintln(w, "successfully connected to the test server")\n\
	})\n\
	log.Fatalln(http.ListenAndServe(addr, nil))\n\
}' > main.go

ENTRYPOINT ["go", "run", "main.go"]