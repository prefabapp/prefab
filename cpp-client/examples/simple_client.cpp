#include <iostream>
#include <prefab/prefab.h>

int main() {
    try {
        // Create a Prefab client with default configuration
        prefab::PrefabClient client;
        
        std::cout << "Prefab C++ Client - Simple Example" << std::endl;
        std::cout << "==================================" << std::endl;
        
        // Test connection first
        if (!client.testConnection()) {
            std::cout << "Cannot connect to Prefab server at " << client.getBaseUrl() << std::endl;
            std::cout << "Make sure the Prefab server is running and accessible." << std::endl;
            return 1;
        }
        
        std::cout << "Connected to Prefab server at: " << client.getBaseUrl() << std::endl;
        std::cout << std::endl;
        
        // Get all homes
        auto homes = client.getHomes();
        std::cout << "Found " << homes.size() << " home(s):" << std::endl;
        
        for (const auto& home : homes) {
            std::cout << std::endl;
            std::cout << "Home: " << home.name << std::endl;
            std::cout << "-----" << std::string(home.name.length(), '-') << std::endl;
            
            try {
                // Get rooms in this home
                auto rooms = client.getRooms(home.name);
                std::cout << "  Rooms (" << rooms.size() << "):" << std::endl;
                
                for (const auto& room : rooms) {
                    std::cout << "    - " << room.name << std::endl;
                    
                    try {
                        // Get accessories in this room
                        auto accessories = client.getAccessories(home.name, room.name);
                        if (!accessories.empty()) {
                            std::cout << "      Accessories (" << accessories.size() << "):" << std::endl;
                            for (const auto& accessory : accessories) {
                                std::cout << "        * " << accessory.name << std::endl;
                            }
                        }
                    } catch (const prefab::PrefabException& e) {
                        std::cout << "      Error getting accessories: " << e.what() << std::endl;
                    }
                }
            } catch (const prefab::PrefabException& e) {
                std::cout << "  Error getting rooms: " << e.what() << std::endl;
            }
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