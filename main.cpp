
#include <iostream>
#include <memory>
#include <string>
#include <thread>

#include "src/cpp_greet_service.h"

int main()
{
    std::string server_address("0.0.0.0:50051");
    std::unique_ptr<Server> server;

    // 创建并启动服务器线程
    std::thread server_thread([&]()
                              { RunServer(server_address, server); });

    // 主线程可以继续执行其他任务
    std::cout << "Main thread continues to run..." << std::endl;

    // 模拟主线程等待一段时间后停止服务器
    const int STOP_TICK = 60 * 100;
    for (auto tick = 0; tick < STOP_TICK; tick++)
    {
        std::string data = "Current Tick: " + std::to_string(tick);
        WriteData(data);
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }
    

    // 优雅地关闭服务器
    if (server)
    {
        server->Shutdown();
    }

    // 等待服务器线程结束
    server_thread.join();
    std::cout << "Server has been stopped." << std::endl;

    return 0;
}