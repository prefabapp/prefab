#pragma once

#include <string>
#include <vector>
#include <optional>
#include <nlohmann/json.hpp>

namespace prefab {

    /**
     * @brief Represents a HomeKit Home
     */
    struct Home {
        std::string name;

        // JSON serialization
        NLOHMANN_DEFINE_TYPE_INTRUSIVE(Home, name)
    };

    /**
     * @brief Represents a HomeKit Room within a Home
     */
    struct Room {
        std::string home;
        std::string name;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(Room, home, name)
    };

    /**
     * @brief Metadata for HomeKit Characteristics
     */
    struct CharacteristicMetadata {
        std::optional<std::string> manufacturerDescription;
        std::optional<std::vector<std::string>> validValues;
        std::optional<std::string> minimumValue;
        std::optional<std::string> maximumValue;
        std::optional<std::string> stepValue;
        std::optional<std::string> maxLength;
        std::optional<std::string> format;
        std::optional<std::string> units;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(CharacteristicMetadata,
            manufacturerDescription, validValues, minimumValue, maximumValue,
            stepValue, maxLength, format, units)
    };

    /**
     * @brief Represents a HomeKit Characteristic
     */
    struct Characteristic {
        std::string uniqueIdentifier;
        std::string description;
        std::vector<std::string> properties;
        std::string typeName;
        std::string type;
        CharacteristicMetadata metadata;
        std::string value;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(Characteristic,
            uniqueIdentifier, description, properties, typeName, type, metadata, value)
    };

    /**
     * @brief Represents a HomeKit Service
     */
    struct Service {
        std::string uniqueIdentifier;
        std::string name;
        std::string typeName;
        std::string type;
        bool isPrimary;
        bool isUserInteractive;
        std::optional<std::string> associatedType;
        std::vector<Characteristic> characteristics;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(Service,
            uniqueIdentifier, name, typeName, type, isPrimary, isUserInteractive,
            associatedType, characteristics)
    };

    /**
     * @brief Represents a HomeKit Accessory
     */
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

        NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(Accessory,
            home, room, name, category, isReachable, supportsIdentify, isBridged,
            services, firmwareVersion, manufacturer, model)
    };

    /**
     * @brief Input structure for updating accessory characteristics
     */
    struct UpdateAccessoryInput {
        std::string characteristicUniqueIdentifier;
        std::string value;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(UpdateAccessoryInput,
            characteristicUniqueIdentifier, value)
    };

} // namespace prefab