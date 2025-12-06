#pragma once

#include <string>
#include <vector>
#include <memory>
#include <optional>
#include <functional>
#include "models.h"

namespace prefab {

    /**
     * @brief Exception class for Prefab client errors
     */
    class PrefabException : public std::exception {
    private:
        std::string message_;
        int httpCode_;

    public:
        PrefabException(const std::string& message, int httpCode = 0)
            : message_(message), httpCode_(httpCode) {}

        const char* what() const noexcept override {
            return message_.c_str();
        }

        int getHttpCode() const { return httpCode_; }
    };

    /**
     * @brief Configuration for the Prefab client
     */
    struct ClientConfig {
        std::string baseUrl = "http://localhost:8080";
        std::string serviceName = "_prefab._tcp.";
        int timeoutSeconds = 30;
        bool enableMdnsDiscovery = true;

        ClientConfig() = default;
        ClientConfig(const std::string& url) : baseUrl(url) {}
    };

    /**
     * @brief Callback function type for mDNS service discovery
     */
    using ServiceDiscoveryCallback = std::function<void(const std::string& hostname, int port)>;

    /**
     * @brief C++ client for the Prefab HomeKit HTTP API
     * 
     * This client provides access to HomeKit data through the Prefab server's REST API.
     * It can automatically discover Prefab servers on the network using mDNS/Bonjour
     * or connect to a specific server URL.
     */
    class PrefabClient {
    private:
        ClientConfig config_;
        std::string discoveredBaseUrl_;
        
        // Internal HTTP methods
        std::string makeHttpRequest(const std::string& method, const std::string& path, 
                                  const std::string& body = "") const;
        std::string urlEncode(const std::string& value) const;
        
        // mDNS discovery implementation
        bool discoverService();

    public:
        /**
         * @brief Construct a new Prefab Client
         * 
         * @param config Client configuration including base URL and discovery options
         */
        explicit PrefabClient(const ClientConfig& config = ClientConfig());

        /**
         * @brief Destructor
         */
        ~PrefabClient();

        /**
         * @brief Discover Prefab servers on the network using mDNS
         * 
         * @param callback Function called when a service is discovered
         * @param timeoutMs Discovery timeout in milliseconds
         * @return true if at least one service was discovered
         */
        bool discoverServices(ServiceDiscoveryCallback callback, int timeoutMs = 5000);

        /**
         * @brief Set the base URL for the Prefab server
         * 
         * @param baseUrl The base URL (e.g., "http://192.168.1.100:8080")
         */
        void setBaseUrl(const std::string& baseUrl);

        /**
         * @brief Get the current base URL
         * 
         * @return std::string The current base URL
         */
        std::string getBaseUrl() const;

        /**
         * @brief Test connectivity to the Prefab server
         * 
         * @return true if the server is reachable
         */
        bool testConnection();

        // HomeKit API methods

        /**
         * @brief Get all available homes
         * 
         * @return std::vector<Home> List of homes
         */
        std::vector<Home> getHomes();

        /**
         * @brief Get a specific home by name
         * 
         * @param homeName Name of the home
         * @return Home The requested home
         */
        Home getHome(const std::string& homeName);

        /**
         * @brief Get all rooms in a home
         * 
         * @param homeName Name of the home
         * @return std::vector<Room> List of rooms
         */
        std::vector<Room> getRooms(const std::string& homeName);

        /**
         * @brief Get a specific room in a home
         * 
         * @param homeName Name of the home
         * @param roomName Name of the room
         * @return Room The requested room
         */
        Room getRoom(const std::string& homeName, const std::string& roomName);

        /**
         * @brief Get all accessories in a room
         * 
         * @param homeName Name of the home
         * @param roomName Name of the room
         * @return std::vector<Accessory> List of accessories (basic info only)
         */
        std::vector<Accessory> getAccessories(const std::string& homeName, 
                                            const std::string& roomName);

        /**
         * @brief Get detailed information about a specific accessory
         * 
         * @param homeName Name of the home
         * @param roomName Name of the room
         * @param accessoryName Name of the accessory
         * @return Accessory Detailed accessory information including services and characteristics
         */
        Accessory getAccessory(const std::string& homeName, 
                             const std::string& roomName, 
                             const std::string& accessoryName);

        /**
         * @brief Update an accessory's characteristic value
         * 
         * @param homeName Name of the home
         * @param roomName Name of the room
         * @param accessoryName Name of the accessory
         * @param update Update information containing characteristic ID and new value
         * @return std::string Response from the server
         */
        std::string updateAccessory(const std::string& homeName,
                                  const std::string& roomName,
                                  const std::string& accessoryName,
                                  const UpdateAccessoryInput& update);

        /**
         * @brief Find and update a characteristic by type in an accessory
         * 
         * This is a convenience method that finds a characteristic by its type UUID
         * and updates its value without needing to know the exact characteristic UUID.
         * 
         * @param homeName Name of the home
         * @param roomName Name of the room
         * @param accessoryName Name of the accessory
         * @param characteristicType The HomeKit characteristic type UUID
         * @param value The new value to set
         * @return std::string Response from the server
         */
        std::string updateCharacteristicByType(const std::string& homeName,
                                             const std::string& roomName,
                                             const std::string& accessoryName,
                                             const std::string& characteristicType,
                                             const std::string& value);

        // Scene API methods

        /**
         * @brief Get all scenes in a home
         * 
         * @param homeName Name of the home
         * @return std::vector<HomeKitScene> List of scenes
         */
        std::vector<HomeKitScene> getScenes(const std::string& homeName);

        /**
         * @brief Get detailed scene info
         * 
         * @param homeName Name of the home
         * @param sceneId UUID of the scene
         * @return SceneDetail Detailed scene information including actions
         */
        SceneDetail getScene(const std::string& homeName, const std::string& sceneId);

        /**
         * @brief Execute a scene
         * 
         * @param homeName Name of the home
         * @param sceneId UUID of the scene
         * @return std::string Response from the server
         */
        std::string executeScene(const std::string& homeName, const std::string& sceneId);

        // Accessory Group API methods

        /**
         * @brief Get all accessory groups in a home
         * 
         * @param homeName Name of the home
         * @return std::vector<AccessoryGroup> List of groups
         */
        std::vector<AccessoryGroup> getGroups(const std::string& homeName);

        /**
         * @brief Get detailed group info
         * 
         * @param homeName Name of the home
         * @param groupId UUID of the group
         * @return AccessoryGroupDetail Detailed group information including services
         */
        AccessoryGroupDetail getGroup(const std::string& homeName, const std::string& groupId);

        /**
         * @brief Update all accessories in a group
         * 
         * @param homeName Name of the home
         * @param groupId UUID of the group
         * @param update Update information containing characteristic type and value
         * @return std::string Response from the server
         */
        std::string updateGroup(const std::string& homeName,
                               const std::string& groupId,
                               const UpdateGroupInput& update);
    };

} // namespace prefab