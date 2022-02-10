FROM golang:latest

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y tshark

RUN echo 'package main\n\
\n\
import (\n\
	"log"\n\
	"net/http"\n\
)\n\
\n\
const addr = "0.0.0.0:80"\n\
\n\
func main() {\n\
	log.Println("listening on", addr)\n\
	http.HandleFunc("/test", func(w http.ResponseWriter, req *http.Request) {\n\
		log.Println("received request from", req.RemoteAddr)\n\
		w.WriteHeader(http.StatusOK)\n\
	})\n\
	log.Fatalln(http.ListenAndServe(addr, nil))\n\
}' > main.go

ENTRYPOINT ["go", "run", "main.go"]