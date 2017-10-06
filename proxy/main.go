package main

import (
	"flag"
	"log"
	"net/http"
	"path"
	"strings"

	"github.com/golang/glog"
	"github.com/grpc-ecosystem/grpc-gateway/runtime"
	"golang.org/x/net/context"
	"google.golang.org/grpc"

	gw "github.com/jonathanve/grpc-basics/helloworld"
)

var (
	echoEndpoint = flag.String("echo_endpoint", "localhost:50051", "grpc endpoint")
	swaggerDir   = flag.String("swagger_dir", "../helloworld/", "path to swagger")
)

func allowCORS(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if origin := r.Header.Get("Origin"); origin != "" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			if r.Method == "OPTIONS" && r.Header.Get("Access-Control-Request-Method") != "" {
				preflightHandler(w, r)
				return
			}
		}
		h.ServeHTTP(w, r)
	})
}

func preflightHandler(w http.ResponseWriter, r *http.Request) {
	headers := []string{"Content-Type", "Accept"}
	w.Header().Set("Access-Control-Allow-Headers", strings.Join(headers, ","))
	methods := []string{"GET", "HEAD", "POST", "PUT", "DELETE"}
	w.Header().Set("Access-Control-Allow-Methods", strings.Join(methods, ","))
	glog.Infof("preflight request for %s", r.URL.Path)
	return
}

func serveSwagger(w http.ResponseWriter, r *http.Request) {
	if !strings.HasSuffix(r.URL.Path, ".swagger.json") {
		glog.Errorf("Not Found: %s", r.URL.Path)
		http.NotFound(w, r)
		return
	}

	glog.Infof("Serving %s", r.URL.Path)
	p := strings.TrimPrefix(r.URL.Path, "/swagger/")
	p = path.Join(*swaggerDir, p)
	log.Println(p)
	http.ServeFile(w, r, p)
}

func run(address string) error {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	mux := http.NewServeMux()
	mux.HandleFunc("/swagger/", serveSwagger)

	gwmux := runtime.NewServeMux()
	opts := []grpc.DialOption{grpc.WithInsecure()}
	err := gw.RegisterGreeterHandlerFromEndpoint(ctx, gwmux, *echoEndpoint, opts)
	if err != nil {
		return err
	}
	mux.Handle("/", gwmux)

	http.ListenAndServe(address, allowCORS(mux))
	return nil
}

func main() {
	flag.Parse()
	defer glog.Flush()

	if err := run(":8080"); err != nil {
		glog.Fatal(err)
	}
}
