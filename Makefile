
all:
	echo "## Go stubs and gateway ##"
	protoc \
		-I /usr/local/include -I . \
		-I ${GOPATH}/src \
		-I ${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--go_out=plugins=grpc:. \
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
	python -m grpc_tools.protoc \
		-I /usr/local/include -I . \
		-I ${GOPATH}/src \
		--python_out=. \
		--grpc_python_out=. \
		helloworld/helloworld_raw.proto
	cp helloworld/helloworld_raw_pb2.py client/
	cp helloworld/helloworld_raw_pb2.py server/

clean:
	rm helloworld/*.pb.go && rm helloworld/*.pb.gw.go
	rm helloworld/*.swagger.json
	rm helloworld/*.py

link:
	sudo ln -s $(shell pwd) ${GOPATH}/src/github.com/jonathanve

unlink:
	sudo unlink ${GOPATH}/src/github.com/jonathanve/grpc-basics
