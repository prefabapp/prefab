#include "prefab/client.h"
#include <curl/curl.h>
#include <sstream>
#include <iostream>
#include <nlohmann/json.hpp>
// threading/sync for non-blocking Avahi discovery
#include <thread>
#include <mutex>
#include <condition_variable>
#include <chrono>

#include <avahi-client/client.h>
#include <avahi-client/lookup.h>
#include <avahi-common/simple-watch.h>
#include <avahi-common/malloc.h>
#include <avahi-common/error.h>
#include <arpa/inet.h>
#include <netdb.h>

using json = nlohmann::json;

namespace prefab {

    // Callback function for curl to write response data
    static size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* userp) {
        userp->append((char*)contents, size * nmemb);
        return size * nmemb;
    }

    PrefabClient::PrefabClient(const ClientConfig& config) : config_(config) {
        // Initialize curl
        curl_global_init(CURL_GLOBAL_DEFAULT);
        
        // If mDNS discovery is enabled and no specific URL provided, try to discover
        if (config_.enableMdnsDiscovery && config_.baseUrl == "http://localhost:8080") {
            discoverService();
        }
    }

    PrefabClient::~PrefabClient() {
        curl_global_cleanup();
    }

    std::string PrefabClient::makeHttpRequest(const std::string& method, const std::string& path, const std::string& body) const {
        CURL* curl;
        CURLcode res;
        std::string response;

        curl = curl_easy_init();
        if (!curl) {
            throw PrefabException("Failed to initialize CURL");
        }

    std::string url = getBaseUrl() + path;
    // Log the outgoing request for diagnostics
    
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, config_.timeoutSeconds);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);

        // Set HTTP method and body
        if (method == "POST" || method == "PUT") {
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, body.c_str());
            curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, body.length());
            
            struct curl_slist* headers = nullptr;
            headers = curl_slist_append(headers, "Content-Type: application/json");
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
            
            if (method == "PUT") {
                curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "PUT");
            }
        }

        res = curl_easy_perform(curl);
        
        long httpCode = 0;
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
        
        curl_easy_cleanup(curl);

        if (res != CURLE_OK) {
            throw PrefabException("CURL request failed: " + std::string(curl_easy_strerror(res)));
        }

        if (httpCode >= 400) {
            // Log a short snippet of the response to help debugging
            std::string resp_snip = response.size() > 200 ? response.substr(0, 200) + "..." : response;
            
            throw PrefabException("HTTP error: " + response, (int)httpCode);
        } else {
            
        }

        return response;
    }

    std::string PrefabClient::urlEncode(const std::string& value) const {
        CURL* curl = curl_easy_init();
        if (!curl) {
            return value; // Fallback to unencoded value
        }
        
        char* encoded = curl_easy_escape(curl, value.c_str(), value.length());
        if (!encoded) {
            curl_easy_cleanup(curl);
            return value;
        }
        
        std::string result(encoded);
        curl_free(encoded);
        curl_easy_cleanup(curl);
        
        return result;
    }

    void PrefabClient::setBaseUrl(const std::string& baseUrl) {
        config_.baseUrl = baseUrl;
        discoveredBaseUrl_ = baseUrl;
    }

    std::string PrefabClient::getBaseUrl() const {
        return discoveredBaseUrl_.empty() ? config_.baseUrl : discoveredBaseUrl_;
    }

    bool PrefabClient::testConnection() {
        try {
            makeHttpRequest("GET", "/homes");
            return true;
        } catch (const PrefabException&) {
            return false;
        }
    }

    std::vector<Home> PrefabClient::getHomes() {
        std::string response = makeHttpRequest("GET", "/homes");
        
        try {
            json j = json::parse(response);
            return j.get<std::vector<Home>>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse homes response: " + std::string(e.what()));
        }
    }

    Home PrefabClient::getHome(const std::string& homeName) {
        std::string path = "/homes/" + urlEncode(homeName);
        std::string response = makeHttpRequest("GET", path);
        
        try {
            json j = json::parse(response);
            return j.get<Home>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse home response: " + std::string(e.what()));
        }
    }

    std::vector<Room> PrefabClient::getRooms(const std::string& homeName) {
        std::string path = "/rooms/" + urlEncode(homeName);
        std::string response = makeHttpRequest("GET", path);
        
        try {
            json j = json::parse(response);
            return j.get<std::vector<Room>>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse rooms response: " + std::string(e.what()));
        }
    }

    Room PrefabClient::getRoom(const std::string& homeName, const std::string& roomName) {
        std::string path = "/rooms/" + urlEncode(homeName) + "/" + urlEncode(roomName);
        std::string response = makeHttpRequest("GET", path);
        
        try {
            json j = json::parse(response);
            return j.get<Room>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse room response: " + std::string(e.what()));
        }
    }

    std::vector<Accessory> PrefabClient::getAccessories(const std::string& homeName, const std::string& roomName) {
        std::string path = "/accessories/" + urlEncode(homeName) + "/" + urlEncode(roomName);
        // Diagnostic log: show constructed path and source parameters so we can detect empty room names
        try {
            std::cerr << "PrefabClient: getAccessories called home=\"" << homeName
                      << "\" room=\"" << roomName << "\" path=\"" << path << "\"" << std::endl;
        } catch (...) {
            // best-effort logging
        }
    
        std::string response = makeHttpRequest("GET", path);
        
        try {
            json j = json::parse(response);
            return j.get<std::vector<Accessory>>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse accessories response: " + std::string(e.what()));
        }
    }

    Accessory PrefabClient::getAccessory(const std::string& homeName, const std::string& roomName, const std::string& accessoryName) {
        std::string path = "/accessories/" + urlEncode(homeName) + "/" + urlEncode(roomName) + "/" + urlEncode(accessoryName);
        // Diagnostic log: show constructed path and parameters so callers can see when roomName is empty
        try {
            std::cerr << "PrefabClient: getAccessory called home=\"" << homeName
                      << "\" room=\"" << roomName << "\" accessory=\"" << accessoryName
                      << "\" path=\"" << path << "\"" << std::endl;
        } catch (...) {}

        std::string response = makeHttpRequest("GET", path);
        
        try {
            json j = json::parse(response);
            return j.get<Accessory>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse accessory response: " + std::string(e.what()));
        }
    }

    std::string PrefabClient::updateAccessory(const std::string& homeName,
                                            const std::string& roomName,
                                            const std::string& accessoryName,
                                            const UpdateAccessoryInput& update) {
        std::string path = "/accessories/" + urlEncode(homeName) + "/" + urlEncode(roomName) + "/" + urlEncode(accessoryName);
        // Diagnostic log: update path and params
        try {
            std::cerr << "PrefabClient: updateAccessory called home=\"" << homeName
                      << "\" room=\"" << roomName << "\" accessory=\"" << accessoryName
                      << "\" path=\"" << path << "\"" << std::endl;
        } catch (...) {}
        
        try {
            json j = update;
            std::string body = j.dump();
            return makeHttpRequest("PUT", path, body);
        } catch (const json::exception& e) {
            throw PrefabException("Failed to serialize update request: " + std::string(e.what()));
        }
    }

    std::string PrefabClient::updateCharacteristicByType(const std::string& homeName,
                                                       const std::string& roomName,
                                                       const std::string& accessoryName,
                                                       const std::string& characteristicType,
                                                       const std::string& value) {
        // First, get the accessory details to find the characteristic
        Accessory accessory = getAccessory(homeName, roomName, accessoryName);
        
        if (!accessory.services.has_value()) {
            throw PrefabException("Accessory has no services");
        }
        
        // Find the characteristic with the matching type and get both service and characteristic IDs
        std::string serviceId;
        std::string characteristicId;
        for (const auto& service : accessory.services.value()) {
            for (const auto& characteristic : service.characteristics) {
                if (characteristic.type == characteristicType) {
                    serviceId = service.uniqueIdentifier;
                    characteristicId = characteristic.uniqueIdentifier;
                    break;
                }
            }
            if (!characteristicId.empty()) break;
        }
        
        if (characteristicId.empty()) {
            throw PrefabException("Characteristic type not found: " + characteristicType);
        }
        
        // Create update request with both serviceId and characteristicId to match Swift server API
        UpdateAccessoryInput update;
        update.serviceId = serviceId;
        update.characteristicId = characteristicId;
        update.value = value;
        
        return updateAccessory(homeName, roomName, accessoryName, update);
    }

    // Avahi discovery implementation (always compiled)
    struct AvahiDiscoveryData {
        ServiceDiscoveryCallback callback;
        bool foundService;
        AvahiSimplePoll* simple_poll;
        std::mutex mutex;
        std::condition_variable cv;
    };

    static void resolve_callback(
        AvahiServiceResolver *r,
        [[maybe_unused]] AvahiIfIndex interface,
        [[maybe_unused]] AvahiProtocol protocol,
        AvahiResolverEvent event,
        [[maybe_unused]] const char *name,
        [[maybe_unused]] const char *type,
        [[maybe_unused]] const char *domain,
        [[maybe_unused]] const char *host_name,
        const AvahiAddress *address,
        uint16_t port,
        [[maybe_unused]] AvahiStringList *txt,
        [[maybe_unused]] AvahiLookupResultFlags flags,
        void* userdata) {
        
        AvahiDiscoveryData* data = static_cast<AvahiDiscoveryData*>(userdata);
        
        switch (event) {
            case AVAHI_RESOLVER_FAILURE:
                break;
                
            case AVAHI_RESOLVER_FOUND: {
                char addr_str[AVAHI_ADDRESS_STR_MAX];
                avahi_address_snprint(addr_str, sizeof(addr_str), address);
                
                data->callback(std::string(addr_str), port);
                {
                    std::lock_guard<std::mutex> lk(data->mutex);
                    data->foundService = true;
                }
                data->cv.notify_one();
                // Stop polling after first service found
                avahi_simple_poll_quit(data->simple_poll);
                break;
            }
        }
        
        avahi_service_resolver_free(r);
    }

    static void browse_callback(
        AvahiServiceBrowser *b,
        AvahiIfIndex interface,
        AvahiProtocol protocol,
        AvahiBrowserEvent event,
        const char *name,
        const char *type,
        const char *domain,
        [[maybe_unused]] AvahiLookupResultFlags flags,
        void* userdata) {
        
        AvahiDiscoveryData* data = static_cast<AvahiDiscoveryData*>(userdata);
        AvahiClient* client = avahi_service_browser_get_client(b);
        
        switch (event) {
            case AVAHI_BROWSER_FAILURE:
                avahi_simple_poll_quit(data->simple_poll);
                break;
                
            case AVAHI_BROWSER_NEW:
                // Resolve the service
                if (!(avahi_service_resolver_new(client, interface, protocol, name, type, domain, 
                                               AVAHI_PROTO_UNSPEC, static_cast<AvahiLookupFlags>(0), 
                                               resolve_callback, userdata))) {
                    avahi_simple_poll_quit(data->simple_poll);
                }
                break;
                
            case AVAHI_BROWSER_REMOVE:
            case AVAHI_BROWSER_ALL_FOR_NOW:
            case AVAHI_BROWSER_CACHE_EXHAUSTED:
                break;
        }
    }

    static void client_callback([[maybe_unused]] AvahiClient *c, AvahiClientState state, void *userdata) {
        AvahiDiscoveryData* data = static_cast<AvahiDiscoveryData*>(userdata);
        if (!data) return;
        if (state == AVAHI_CLIENT_FAILURE) {
            {
                std::lock_guard<std::mutex> lk(data->mutex);
                data->foundService = false;
            }
            data->cv.notify_one();
            avahi_simple_poll_quit(data->simple_poll);
        }
    }

    bool PrefabClient::discoverService() {
        AvahiSimplePoll *simple_poll = avahi_simple_poll_new();
        if (!simple_poll) return false;
        
        // Prepare discovery data BEFORE creating the Avahi client so the client callback
        // can safely access the userdata pointer.
        AvahiDiscoveryData data;
        data.foundService = false;
        data.simple_poll = simple_poll;
        data.callback = [this](const std::string& hostname, int port) {
            std::string url = "http://" + hostname + ":" + std::to_string(port);
            this->discoveredBaseUrl_ = url;
        };
        
        int error = 0;
        AvahiClient *client = avahi_client_new(avahi_simple_poll_get(simple_poll),
                                               static_cast<AvahiClientFlags>(0),
                                               client_callback,
                                               &data,
                                               &error);
        if (!client) {
            avahi_simple_poll_free(simple_poll);
            return false;
        }
        
         AvahiServiceBrowser *sb = avahi_service_browser_new(client, AVAHI_IF_UNSPEC, AVAHI_PROTO_UNSPEC, 
                                                           "_prefab._tcp", nullptr, 
                                                           static_cast<AvahiLookupFlags>(0), 
                                                           browse_callback, &data);
         if (!sb) {
             avahi_client_free(client);
             avahi_simple_poll_free(simple_poll);
             return false;
         }
         
         // Run the Avahi poll loop on a background thread and wait for a discovery
         // event or timeout so this function returns instead of blocking forever.
         std::thread poller([simple_poll]() {
             avahi_simple_poll_loop(simple_poll);
         });
         
         // Wait up to 5 seconds for discovery
         {
             std::unique_lock<std::mutex> lk(data.mutex);
             data.cv.wait_for(lk, std::chrono::seconds(5), [&data]() { return data.foundService; });
         }
         
         // Ensure the poll loop stops (resolve_callback may have already called quit)
         avahi_simple_poll_quit(simple_poll);
         if (poller.joinable()) poller.join();
         
         avahi_service_browser_free(sb);
         avahi_client_free(client);
         avahi_simple_poll_free(simple_poll);
         
         return data.foundService;
     }

     bool PrefabClient::discoverServices(ServiceDiscoveryCallback callback, [[maybe_unused]] int timeoutMs) {
        AvahiSimplePoll *simple_poll = avahi_simple_poll_new();
        if (!simple_poll) return false;
        
        AvahiDiscoveryData data;
        data.foundService = false;
        data.simple_poll = simple_poll;
        data.callback = callback;
        
        int error = 0;
        AvahiClient *client = avahi_client_new(avahi_simple_poll_get(simple_poll),
                                               static_cast<AvahiClientFlags>(0),
                                               client_callback,
                                               &data,
                                               &error);
        if (!client) {
            avahi_simple_poll_free(simple_poll);
            return false;
        }
        
        AvahiServiceBrowser *sb = avahi_service_browser_new(client, AVAHI_IF_UNSPEC, AVAHI_PROTO_UNSPEC,
                                                          "_prefab._tcp", nullptr,
                                                          static_cast<AvahiLookupFlags>(0),
                                                          browse_callback, &data);
        if (!sb) {
            avahi_client_free(client);
            avahi_simple_poll_free(simple_poll);
            return false;
        }
        
        // Run poll loop on a background thread and wait for discovery or timeout
        std::thread poller([simple_poll]() {
            avahi_simple_poll_loop(simple_poll);
        });
        
        int waitMs = (timeoutMs > 0) ? timeoutMs : 5000;
        {
            std::unique_lock<std::mutex> lk(data.mutex);
            data.cv.wait_for(lk, std::chrono::milliseconds(waitMs), [&data]() { return data.foundService; });
        }
        
        avahi_simple_poll_quit(simple_poll);
        if (poller.joinable()) poller.join();
        
        avahi_service_browser_free(sb);
        avahi_client_free(client);
        avahi_simple_poll_free(simple_poll);
        
        return data.foundService;
     }

    // ========================================================================
    // Scene API methods
    // ========================================================================

    std::vector<HomeKitScene> PrefabClient::getScenes(const std::string& homeName) {
        std::string path = "/scenes/" + urlEncode(homeName);
        std::string response = makeHttpRequest("GET", path);
        
        try {
            json j = json::parse(response);
            return j.get<std::vector<HomeKitScene>>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse scenes response: " + std::string(e.what()));
        }
    }

    SceneDetail PrefabClient::getScene(const std::string& homeName, const std::string& sceneId) {
        std::string path = "/scenes/" + urlEncode(homeName) + "/" + urlEncode(sceneId);
        std::string response = makeHttpRequest("GET", path);
        
        try {
            json j = json::parse(response);
            return j.get<SceneDetail>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse scene response: " + std::string(e.what()));
        }
    }

    std::string PrefabClient::executeScene(const std::string& homeName, const std::string& sceneId) {
        std::string path = "/scenes/" + urlEncode(homeName) + "/" + urlEncode(sceneId) + "/execute";
        return makeHttpRequest("POST", path);
    }

    // ========================================================================
    // Accessory Group API methods
    // ========================================================================

    std::vector<AccessoryGroup> PrefabClient::getGroups(const std::string& homeName) {
        std::string path = "/groups/" + urlEncode(homeName);
        std::string response = makeHttpRequest("GET", path);
        
        try {
            json j = json::parse(response);
            return j.get<std::vector<AccessoryGroup>>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse groups response: " + std::string(e.what()));
        }
    }

    AccessoryGroupDetail PrefabClient::getGroup(const std::string& homeName, const std::string& groupId) {
        std::string path = "/groups/" + urlEncode(homeName) + "/" + urlEncode(groupId);
        std::string response = makeHttpRequest("GET", path);
        
        try {
            json j = json::parse(response);
            return j.get<AccessoryGroupDetail>();
        } catch (const json::exception& e) {
            throw PrefabException("Failed to parse group response: " + std::string(e.what()));
        }
    }

    std::string PrefabClient::updateGroup(const std::string& homeName,
                                         const std::string& groupId,
                                         const UpdateGroupInput& update) {
        std::string path = "/groups/" + urlEncode(homeName) + "/" + urlEncode(groupId);
        
        try {
            json j = update;
            std::string body = j.dump();
            return makeHttpRequest("PUT", path, body);
        } catch (const json::exception& e) {
            throw PrefabException("Failed to serialize group update request: " + std::string(e.what()));
        }
    }

} // namespace prefab