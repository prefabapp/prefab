# Prefab C++ Client Library

A C++ client library for accessing HomeKit data through the Prefab HTTP server. This library is optimized for Raspberry Pi and other Linux systems.

## Features

- **Simple C++ API**: Easy-to-use interface for HomeKit data access
- **Automatic Service Discovery**: Find Prefab servers on the network using mDNS/Bonjour
- **Type Safety**: Strongly-typed data models with JSON serialization
- **Cross-Platform**: Works on Linux, macOS, and other Unix-like systems
- **Raspberry Pi Optimized**: Lightweight and efficient for embedded systems
- **HTTP Client**: Built-in HTTP client with proper error handling

## Requirements

### System Requirements
- **Linux**: Ubuntu 18.04+ or Raspberry Pi OS
- **macOS**: 10.14+ (for development/testing)
- **C++ Compiler**: GCC 7+ or Clang 8+ with C++17 support
- **CMake**: Version 3.16 or later

### Dependencies
- **libcurl**: HTTP client library
- **nlohmann/json**: JSON parsing library (automatically downloaded if not found)
- **Avahi** (optional): For mDNS service discovery on Linux

### Raspberry Pi Setup

On Raspberry Pi OS, install the required dependencies:

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    libcurl4-openssl-dev \
    libavahi-client-dev \
    libavahi-common-dev \
    pkg-config \
    git
```

For other Linux distributions, install the equivalent packages.

## Building

### 1. Clone and Navigate

```bash
cd /path/to/prefab/cpp-client
```

### 2. Create Build Directory

```bash
mkdir build
cd build
```

### 3. Configure with CMake

```bash
# Basic configuration
cmake ..

# Or with custom options
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_TESTS=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local
```

### 4. Build

```bash
make -j$(nproc)
```

### 5. Install (Optional)

```bash
sudo make install
```

### CMake Options

- `BUILD_EXAMPLES` (default: ON): Build example programs
- `BUILD_TESTS` (default: ON): Build test programs
- `INSTALL_EXAMPLES` (default: OFF): Install example programs
- `CMAKE_BUILD_TYPE`: Debug, Release, RelWithDebInfo, MinSizeRel

## Usage

### Basic Example

```cpp
#include <prefab/prefab.h>
#include <iostream>

int main() {
    try {
        // Create client
        prefab::PrefabClient client;
        
        // Test connection
        if (!client.testConnection()) {
            std::cout << "Cannot connect to Prefab server" << std::endl;
            return 1;
        }
        
        // Get all homes
        auto homes = client.getHomes();
        for (const auto& home : homes) {
            std::cout << "Home: " << home.name << std::endl;
            
            // Get rooms
            auto rooms = client.getRooms(home.name);
            for (const auto& room : rooms) {
                std::cout << "  Room: " << room.name << std::endl;
                
                // Get accessories
                auto accessories = client.getAccessories(home.name, room.name);
                for (const auto& accessory : accessories) {
                    std::cout << "    Accessory: " << accessory.name << std::endl;
                }
            }
        }
        
    } catch (const prefab::PrefabException& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
```

### Service Discovery

```cpp
#include <prefab/prefab.h>

int main() {
    prefab::ClientConfig config;
    config.enableMdnsDiscovery = true;
    prefab::PrefabClient client(config);
    
    // Discover services on the network
    bool found = client.discoverServices([](const std::string& hostname, int port) {
        std::cout << "Found Prefab server at: " << hostname << ":" << port << std::endl;
    }, 5000); // 5 second timeout
    
    if (found) {
        std::cout << "Using server: " << client.getBaseUrl() << std::endl;
    } else {
        std::cout << "No servers found, using default" << std::endl;
        client.setBaseUrl("http://192.168.1.100:8080");
    }
    
    return 0;
}
```

### Controlling Accessories

```cpp
#include <prefab/prefab.h>

int main() {
    prefab::PrefabClient client;
    
    // Get detailed accessory information
    auto accessory = client.getAccessory("My Home", "Living Room", "Smart Light");
    
    // Print details
    if (accessory.services.has_value()) {
        for (const auto& service : accessory.services.value()) {
            std::cout << "Service: " << service.typeName << std::endl;
            for (const auto& characteristic : service.characteristics) {
                std::cout << "  " << characteristic.typeName 
                          << " = " << characteristic.value << std::endl;
            }
        }
    }
    
    // Update a characteristic (turn on light)
    try {
        auto result = client.updateCharacteristicByType(
            "My Home", "Living Room", "Smart Light",
            "00000025-0000-1000-8000-0026BB765291", // On/Off characteristic
            "1" // Turn on
        );
        std::cout << "Light turned on: " << result << std::endl;
    } catch (const prefab::PrefabException& e) {
        std::cerr << "Failed to turn on light: " << e.what() << std::endl;
    }
    
    return 0;
}
```

## API Reference

### PrefabClient Class

#### Constructor
```cpp
PrefabClient(const ClientConfig& config = ClientConfig())
```

#### Configuration
```cpp
void setBaseUrl(const std::string& baseUrl)
std::string getBaseUrl() const
bool testConnection()
```

#### Service Discovery
```cpp
bool discoverServices(ServiceDiscoveryCallback callback, int timeoutMs = 5000)
```

#### HomeKit Data Access
```cpp
std::vector<Home> getHomes()
Home getHome(const std::string& homeName)
std::vector<Room> getRooms(const std::string& homeName)
Room getRoom(const std::string& homeName, const std::string& roomName)
std::vector<Accessory> getAccessories(const std::string& homeName, const std::string& roomName)
Accessory getAccessory(const std::string& homeName, const std::string& roomName, const std::string& accessoryName)
```

#### Accessory Control
```cpp
std::string updateAccessory(const std::string& homeName, const std::string& roomName, 
                           const std::string& accessoryName, const UpdateAccessoryInput& update)
std::string updateCharacteristicByType(const std::string& homeName, const std::string& roomName,
                                      const std::string& accessoryName, const std::string& characteristicType,
                                      const std::string& value)
```

### Data Models

#### Home
```cpp
struct Home {
    std::string name;
};
```

#### Room
```cpp
struct Room {
    std::string home;
    std::string name;
};
```

#### Accessory
```cpp
struct Accessory {
    std::string home;
    std::string room;
    std::string name;
    
    // Optional detailed properties
    std::optional<std::string> category;
    std::optional<bool> isReachable;
    std::optional<bool> supportsIdentify;
    std::optional<bool> isBridged;
    std::optional<std::vector<Service>> services;
    std::optional<std::string> firmwareVersion;
    std::optional<std::string> manufacturer;
    std::optional<std::string> model;
};
```

## Building Applications

### Using CMake

Create a `CMakeLists.txt` for your application:

```cmake
cmake_minimum_required(VERSION 3.16)
project(my_prefab_app)

set(CMAKE_CXX_STANDARD 17)

# Find the prefab-client library
find_package(prefab-client REQUIRED)

# Create your executable
add_executable(my_app main.cpp)

# Link with prefab-client
target_link_libraries(my_app prefab::prefab-client)
```

### Manual Compilation

If you prefer manual compilation:

```bash
g++ -std=c++17 -I/usr/local/include main.cpp -lprefab-client -lcurl -o my_app
```

## Running Examples

After building, you can run the example programs:

```bash
# Simple client example
./examples/simple_client

# Service discovery example
./examples/discovery_example

# Accessory control example
./examples/accessory_control

# Control specific accessory
./examples/accessory_control "My Home" "Living Room" "Smart Light"

# Update characteristic
./examples/accessory_control "My Home" "Living Room" "Smart Light" \
    "00000025-0000-1000-8000-0026BB765291" "1"
```

## Common HomeKit Characteristic Types

- **On/Off**: `00000025-0000-1000-8000-0026BB765291`
- **Brightness**: `00000008-0000-1000-8000-0026BB765291`
- **Hue**: `00000013-0000-1000-8000-0026BB765291`
- **Saturation**: `0000002F-0000-1000-8000-0026BB765291`
- **Current Temperature**: `00000011-0000-1000-8000-0026BB765291`
- **Target Temperature**: `00000035-0000-1000-8000-0026BB765291`

## Raspberry Pi Deployment

### Cross-Compilation

For cross-compilation from a development machine:

```bash
# Install cross-compilation tools
sudo apt install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

# Configure for ARM64
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../cmake/raspberry-pi.cmake \
    -DCMAKE_BUILD_TYPE=Release

make -j$(nproc)
```

### Running on Raspberry Pi

1. Copy the built library and examples to your Raspberry Pi
2. Install runtime dependencies:
   ```bash
   sudo apt install libcurl4 libavahi-client3 libavahi-common3
   ```
3. Run your application:
   ```bash
   ./my_prefab_app
   ```

## Troubleshooting

### Connection Issues
- Ensure Prefab server is running and accessible
- Check firewall settings (port 8080)
- Verify network connectivity between devices

### Build Issues
- Ensure all dependencies are installed
- Check CMake version (3.16+ required)
- Verify C++17 compiler support

### mDNS Discovery Issues
- Install Avahi on Linux: `sudo apt install libavahi-client-dev libavahi-common-dev`
- Enable Avahi daemon: `sudo systemctl enable avahi-daemon`
- Start Avahi daemon: `sudo systemctl start avahi-daemon`
- Check network allows multicast traffic

### Raspberry Pi Performance
- Use Release build for better performance
- Consider using static linking for deployment
- Monitor memory usage with complex HomeKit setups

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](../LICENSE) file for details.