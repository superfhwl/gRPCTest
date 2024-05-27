#include "cpp_greet_service.h"

class GreetServiceImpl final : public GreetService::Service
{
    Status SayHello(ServerContext *context, const HelloRequest *request, HelloResponse *response) override
    {
        std::string prefix("Hello ");
        std::string mesage_data;
        ReadData(mesage_data);
        response->set_message(prefix + request->name() + "! " + mesage_data);
        return Status::OK;
    }
};

// 服务器运行函数
void RunServer(std::string server_address, std::unique_ptr<Server> &server)
{
    GreetServiceImpl service;

    ServerBuilder builder;
    builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
    builder.RegisterService(&service);
    server = builder.BuildAndStart();
    std::cout << "Server listening on " << server_address << std::endl;
    server->Wait();
}

std::string g_data;
std::mutex g_data_mutex;

void WriteData(const std::string &input_data)
{
    std::lock_guard<std::mutex> lock(g_data_mutex);
    g_data = input_data;
}

void ReadData(std::string &output_data)
{
    std::lock_guard<std::mutex> lock(g_data_mutex);
    output_data = g_data;
}
