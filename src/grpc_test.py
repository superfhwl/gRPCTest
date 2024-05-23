from __future__ import print_function
import grpc
import message_pb2
import message_pb2_grpc

def run():
  with grpc.insecure_channel('localhost:50051') as channel:
    stub = message_pb2_grpc.GreetServiceStub(channel)
    response = stub.SayHello(message_pb2.HelloRequest(name='World'))
    print("Greeter client received: " + response.message)

if __name__ == '__main__':
    run()