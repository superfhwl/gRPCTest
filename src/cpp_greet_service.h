#include <iostream>
#include <memory>
#include <string>
#include <thread>

#include <grpcpp/grpcpp.h>
#include "message.grpc.pb.h"

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;
using example::HelloRequest;
using example::HelloResponse;
using example::GreetService;



// void RunServer();
void RunServer(std::string server_address, std::unique_ptr<Server>& server);

void WriteData(const std::string &input_data);
void ReadData(std::string &output_data);
