#include <iostream>
#include <chrono>
#include <thread>
#include <prefab/prefab.h>

int main() {
    try {
        std::cout << "Prefab C++ Client - Service Discovery Example" << std::endl;
        std::cout << "=============================================" << std::endl;
        
        // Create a client with mDNS discovery enabled
        prefab::ClientConfig config;
        config.enableMdnsDiscovery = true;
        prefab::PrefabClient client(config);
        
        std::cout << "Searching for Prefab servers on the network..." << std::endl;
        
        bool foundService = false;
        
        // Try to discover services
        foundService = client.discoverServices([&](const std::string& hostname, int port) {
            std::cout << "Found Prefab server at: " << hostname << ":" << port << std::endl;
            
            // Set the discovered URL
            std::string url = "http://" + hostname + ":" + std::to_string(port);
            client.setBaseUrl(url);
            
            // Test the connection
            if (client.testConnection()) {
                std::cout << "Successfully connected to: " << url << std::endl;
            } else {
                std::cout << "Found server but connection test failed: " << url << std::endl;
            }
        }, 5000); // 5 second timeout
        
        if (!foundService) {
            std::cout << "No Prefab servers found on the network." << std::endl;
            std::cout << "Trying common local addresses..." << std::endl;
            
            // Try some common addresses manually
            std::vector<std::string> commonUrls = {
                "http://localhost:8080",
                "http://127.0.0.1:8080",
                "http://192.168.1.100:8080",
                "http://192.168.0.100:8080"
            };
            
            for (const auto& url : commonUrls) {
                std::cout << "Trying: " << url << "... ";
                client.setBaseUrl(url);
                
                if (client.testConnection()) {
                    std::cout << "SUCCESS!" << std::endl;
                    foundService = true;
                    break;
                } else {
                    std::cout << "failed" << std::endl;
                }
            }
        }
        
        if (!foundService) {
            std::cout << std::endl;
            std::cout << "No Prefab servers could be reached." << std::endl;
            std::cout << "Make sure:" << std::endl;
            std::cout << "1. Prefab server is running" << std::endl;
            std::cout << "2. Server is accessible from this machine" << std::endl;
            std::cout << "3. No firewall is blocking port 8080" << std::endl;
            return 1;
        }
        
        std::cout << std::endl;
        std::cout << "Using Prefab server at: " << client.getBaseUrl() << std::endl;
        
        // Now try to get some basic data
        try {
            auto homes = client.getHomes();
            std::cout << "Successfully retrieved " << homes.size() << " home(s) from the server." << std::endl;
            
            for (const auto& home : homes) {
                std::cout << "  - " << home.name << std::endl;
            }
        } catch (const prefab::PrefabException& e) {
            std::cout << "Error retrieving homes: " << e.what() << std::endl;
        }
        
    } catch (const prefab::PrefabException& e) {
        std::cerr << "Prefab Error: " << e.what();
        if (e.getHttpCode() > 0) {
            std::cerr << " (HTTP " << e.getHttpCode() << ")";
        }
        std::cerr << std::endl;
        return 1;
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}