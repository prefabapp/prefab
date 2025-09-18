#include <iostream>
#include <string>
#include <prefab/prefab.h>

void printAccessoryDetails(const prefab::Accessory& accessory) {
    std::cout << "Accessory: " << accessory.name << std::endl;
    
    if (accessory.manufacturer.has_value()) {
        std::cout << "  Manufacturer: " << accessory.manufacturer.value() << std::endl;
    }
    if (accessory.model.has_value()) {
        std::cout << "  Model: " << accessory.model.value() << std::endl;
    }
    if (accessory.isReachable.has_value()) {
        std::cout << "  Reachable: " << (accessory.isReachable.value() ? "Yes" : "No") << std::endl;
    }
    
    if (accessory.services.has_value()) {
        std::cout << "  Services:" << std::endl;
        for (const auto& service : accessory.services.value()) {
            std::cout << "    - " << service.typeName << " (" << service.name << ")" << std::endl;
            
            if (!service.characteristics.empty()) {
                std::cout << "      Characteristics:" << std::endl;
                for (const auto& characteristic : service.characteristics) {
                    std::cout << "        * " << characteristic.typeName 
                              << " = " << characteristic.value
                              << " [" << characteristic.uniqueIdentifier << "]" << std::endl;
                }
            }
        }
    }
}

int main(int argc, char* argv[]) {
    try {
        prefab::PrefabClient client;
        
        std::cout << "Prefab C++ Client - Accessory Control Example" << std::endl;
        std::cout << "==============================================" << std::endl;
        
        // Test connection
        if (!client.testConnection()) {
            std::cout << "Cannot connect to Prefab server at " << client.getBaseUrl() << std::endl;
            return 1;
        }
        
        std::cout << "Connected to: " << client.getBaseUrl() << std::endl;
        std::cout << std::endl;
        
        // If specific accessory is provided as command line arguments
        if (argc >= 4) {
            std::string homeName = argv[1];
            std::string roomName = argv[2];
            std::string accessoryName = argv[3];
            
            std::cout << "Getting details for accessory: " << accessoryName << std::endl;
            std::cout << "In room: " << roomName << ", Home: " << homeName << std::endl;
            std::cout << std::endl;
            
            try {
                auto accessory = client.getAccessory(homeName, roomName, accessoryName);
                printAccessoryDetails(accessory);
                
                // If we have 5 arguments, try to update a characteristic
                if (argc >= 6) {
                    std::string characteristicType = argv[4];
                    std::string newValue = argv[5];
                    
                    std::cout << std::endl;
                    std::cout << "Attempting to update characteristic " << characteristicType 
                              << " to value: " << newValue << std::endl;
                    
                    try {
                        auto result = client.updateCharacteristicByType(
                            homeName, roomName, accessoryName, characteristicType, newValue);
                        std::cout << "Update result: " << result << std::endl;
                    } catch (const prefab::PrefabException& e) {
                        std::cout << "Update failed: " << e.what() << std::endl;
                    }
                }
                
            } catch (const prefab::PrefabException& e) {
                std::cout << "Error getting accessory details: " << e.what() << std::endl;
                return 1;
            }
            
        } else {
            // Interactive mode - list all accessories
            auto homes = client.getHomes();
            
            for (const auto& home : homes) {
                std::cout << "Home: " << home.name << std::endl;
                
                try {
                    auto rooms = client.getRooms(home.name);
                    for (const auto& room : rooms) {
                        std::cout << "  Room: " << room.name << std::endl;
                        
                        try {
                            auto accessories = client.getAccessories(home.name, room.name);
                            for (const auto& accessory : accessories) {
                                std::cout << "    Accessory: " << accessory.name << std::endl;
                            }
                        } catch (const prefab::PrefabException& e) {
                            std::cout << "    Error getting accessories: " << e.what() << std::endl;
                        }
                    }
                } catch (const prefab::PrefabException& e) {
                    std::cout << "  Error getting rooms: " << e.what() << std::endl;
                }
                std::cout << std::endl;
            }
            
            std::cout << "Usage for accessory control:" << std::endl;
            std::cout << "  " << argv[0] << " <home> <room> <accessory> [characteristic_type] [new_value]" << std::endl;
            std::cout << std::endl;
            std::cout << "Example HomeKit characteristic types:" << std::endl;
            std::cout << "  00000025-0000-1000-8000-0026BB765291  (On/Off)" << std::endl;
            std::cout << "  00000008-0000-1000-8000-0026BB765291  (Brightness)" << std::endl;
            std::cout << "  0000000A-0000-1000-8000-0026BB765291  (Current Temperature)" << std::endl;
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