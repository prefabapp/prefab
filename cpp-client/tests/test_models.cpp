#include <iostream>
#include <cassert>
#include <prefab/models.h>

int main() {
    std::cout << "Testing Prefab C++ Models..." << std::endl;
    
    try {
        // Test Home serialization
        prefab::Home home;
        home.name = "Test Home";
        
        nlohmann::json j = home;
        auto home2 = j.get<prefab::Home>();
        assert(home.name == home2.name);
        std::cout << "✓ Home serialization test passed" << std::endl;
        
        // Test Room serialization
        prefab::Room room;
        room.home = "Test Home";
        room.name = "Living Room";
        
        nlohmann::json j2 = room;
        auto room2 = j2.get<prefab::Room>();
        assert(room.home == room2.home);
        assert(room.name == room2.name);
        std::cout << "✓ Room serialization test passed" << std::endl;
        
        // Test Accessory basic serialization
        prefab::Accessory accessory;
        accessory.home = "Test Home";
        accessory.room = "Living Room";
        accessory.name = "Smart Light";
        accessory.manufacturer = "Test Manufacturer";
        accessory.isReachable = true;
        
        nlohmann::json j3 = accessory;
        auto accessory2 = j3.get<prefab::Accessory>();
        assert(accessory.home == accessory2.home);
        assert(accessory.room == accessory2.room);
        assert(accessory.name == accessory2.name);
        assert(accessory.manufacturer == accessory2.manufacturer);
        assert(accessory.isReachable == accessory2.isReachable);
        std::cout << "✓ Accessory serialization test passed" << std::endl;
        
        // Test UpdateAccessoryInput
        prefab::UpdateAccessoryInput update;
        update.characteristicUniqueIdentifier = "test-uuid";
        update.value = "50";
        
        nlohmann::json j4 = update;
        auto update2 = j4.get<prefab::UpdateAccessoryInput>();
        assert(update.characteristicUniqueIdentifier == update2.characteristicUniqueIdentifier);
        assert(update.value == update2.value);
        std::cout << "✓ UpdateAccessoryInput serialization test passed" << std::endl;
        
        std::cout << std::endl;
        std::cout << "All model tests passed!" << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Test failed: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}