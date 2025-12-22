#pragma once

/**
 * @file prefab.h
 * @brief Main header file for the Prefab C++ client library
 * 
 * This header provides access to HomeKit data through the Prefab HTTP API.
 * The library is designed to work on Raspberry Pi and other Linux systems.
 * 
 * @author Prefab Team
 * @version 1.0.0
 */

#include "models.h"
#include "client.h"

/**
 * @brief Prefab C++ client library for HomeKit data access
 * 
 * This library provides a simple C++ interface to communicate with the Prefab
 * HomeKit HTTP server. It supports automatic service discovery using mDNS/Bonjour
 * and provides strongly-typed access to HomeKit homes, rooms, and accessories.
 * 
 * Example usage:
 * @code
 * #include <prefab/prefab.h>
 * 
 * int main() {
 *     try {
 *         prefab::PrefabClient client;
 *         
 *         // Auto-discover Prefab server on network
 *         if (!client.discoverServices([](const std::string& host, int port) {
 *             std::cout << "Found Prefab server at " << host << ":" << port << std::endl;
 *         })) {
 *             // Fallback to manual configuration
 *             client.setBaseUrl("http://192.168.1.100:8080");
 *         }
 *         
 *         // Get all homes
 *         auto homes = client.getHomes();
 *         for (const auto& home : homes) {
 *             std::cout << "Home: " << home.name << std::endl;
 *             
 *             // Get rooms in this home
 *             auto rooms = client.getRooms(home.name);
 *             for (const auto& room : rooms) {
 *                 std::cout << "  Room: " << room.name << std::endl;
 *                 
 *                 // Get accessories in this room
 *                 auto accessories = client.getAccessories(home.name, room.name);
 *                 for (const auto& accessory : accessories) {
 *                     std::cout << "    Accessory: " << accessory.name << std::endl;
 *                 }
 *             }
 *         }
 *         
 *     } catch (const prefab::PrefabException& e) {
 *         std::cerr << "Error: " << e.what() << std::endl;
 *         return 1;
 *     }
 *     
 *     return 0;
 * }
 * @endcode
 */