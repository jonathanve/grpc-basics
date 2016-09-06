from __future__ import print_function

import grpc

import helloworld_raw_pb2


def run():
  channel = grpc.insecure_channel('localhost:50051')
  stub = helloworld_raw_pb2.GreeterStub(channel)
  response = stub.SayHello(helloworld_raw_pb2.HelloRequest(name='Jon'))
  print("Greeter client received: " + response.message)


if __name__ == '__main__':
  run()
