
all:
	echo "## Go stubs and gateway ##"
	protoc \
		-I /usr/local/include -I . \
		-I ${GOPATH}/src \
		-I ${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--go_out=Mgoogle/api/annotations.proto=github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis/google/api,plugins=grpc:. \
		helloworld/helloworld.proto
	protoc \
		-I /usr/local/include -I . \
		-I ${GOPATH}/src \
		-I ${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--grpc-gateway_out=logtostderr=true:. \
		helloworld/helloworld.proto
	protoc \
		-I /usr/local/include -I . \
		-I ${GOPATH}/src \
		-I ${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--swagger_out=logtostderr=true:. \
		helloworld/helloworld.proto
	echo "## Python stubs ##"
	protoc \
		-I /usr/local/include -I . \
		-I ${GOPATH}/src \
		--plugin=protoc-gen-grpc=`which grpc_python_plugin` \
		--python_out=. \
		--grpc_out=. \
		helloworld/helloworld_raw.proto
	cp helloworld/helloworld_raw_pb2.py client/
	cp helloworld/helloworld_raw_pb2.py server/

clean:
	rm helloworld/*.pb.go && rm helloworld/*.pb.gw.go
	rm helloworld/*.swagger.json
	rm helloworld/*.py
