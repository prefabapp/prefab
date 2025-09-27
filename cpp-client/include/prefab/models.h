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

        // Custom JSON serialization for optional fields
        friend void to_json(nlohmann::json& j, const CharacteristicMetadata& m) {
            j = nlohmann::json{};
            if (m.manufacturerDescription.has_value()) j["manufacturerDescription"] = m.manufacturerDescription.value();
            if (m.validValues.has_value()) j["validValues"] = m.validValues.value();
            if (m.minimumValue.has_value()) j["minimumValue"] = m.minimumValue.value();
            if (m.maximumValue.has_value()) j["maximumValue"] = m.maximumValue.value();
            if (m.stepValue.has_value()) j["stepValue"] = m.stepValue.value();
            if (m.maxLength.has_value()) j["maxLength"] = m.maxLength.value();
            if (m.format.has_value()) j["format"] = m.format.value();
            if (m.units.has_value()) j["units"] = m.units.value();
        }

        friend void from_json(const nlohmann::json& j, CharacteristicMetadata& m) {
            if (j.contains("manufacturerDescription") && !j["manufacturerDescription"].is_null()) {
                m.manufacturerDescription = j["manufacturerDescription"].get<std::string>();
            }
            if (j.contains("validValues") && !j["validValues"].is_null()) {
                m.validValues = j["validValues"].get<std::vector<std::string>>();
            }
            if (j.contains("minimumValue") && !j["minimumValue"].is_null()) {
                m.minimumValue = j["minimumValue"].get<std::string>();
            }
            if (j.contains("maximumValue") && !j["maximumValue"].is_null()) {
                m.maximumValue = j["maximumValue"].get<std::string>();
            }
            if (j.contains("stepValue") && !j["stepValue"].is_null()) {
                m.stepValue = j["stepValue"].get<std::string>();
            }
            if (j.contains("maxLength") && !j["maxLength"].is_null()) {
                m.maxLength = j["maxLength"].get<std::string>();
            }
            if (j.contains("format") && !j["format"].is_null()) {
                m.format = j["format"].get<std::string>();
            }
            if (j.contains("units") && !j["units"].is_null()) {
                m.units = j["units"].get<std::string>();
            }
        }
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

        // Custom JSON serialization for optional fields
        friend void to_json(nlohmann::json& j, const Service& s) {
            j = nlohmann::json{
                {"uniqueIdentifier", s.uniqueIdentifier},
                {"name", s.name},
                {"typeName", s.typeName},
                {"type", s.type},
                {"isPrimary", s.isPrimary},
                {"isUserInteractive", s.isUserInteractive},
                {"characteristics", s.characteristics}
            };
            if (s.associatedType.has_value()) {
                j["associatedType"] = s.associatedType.value();
            }
        }

        friend void from_json(const nlohmann::json& j, Service& s) {
            j.at("uniqueIdentifier").get_to(s.uniqueIdentifier);
            j.at("name").get_to(s.name);
            j.at("typeName").get_to(s.typeName);
            j.at("type").get_to(s.type);
            j.at("isPrimary").get_to(s.isPrimary);
            j.at("isUserInteractive").get_to(s.isUserInteractive);
            j.at("characteristics").get_to(s.characteristics);
            
            if (j.contains("associatedType") && !j["associatedType"].is_null()) {
                s.associatedType = j["associatedType"].get<std::string>();
            }
        }
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

        // Custom JSON serialization for optional fields
        friend void to_json(nlohmann::json& j, const Accessory& a) {
            j = nlohmann::json{
                {"home", a.home},
                {"room", a.room},
                {"name", a.name}
            };
            if (a.category.has_value()) j["category"] = a.category.value();
            if (a.isReachable.has_value()) j["isReachable"] = a.isReachable.value();
            if (a.supportsIdentify.has_value()) j["supportsIdentify"] = a.supportsIdentify.value();
            if (a.isBridged.has_value()) j["isBridged"] = a.isBridged.value();
            if (a.services.has_value()) j["services"] = a.services.value();
            if (a.firmwareVersion.has_value()) j["firmwareVersion"] = a.firmwareVersion.value();
            if (a.manufacturer.has_value()) j["manufacturer"] = a.manufacturer.value();
            if (a.model.has_value()) j["model"] = a.model.value();
        }

        friend void from_json(const nlohmann::json& j, Accessory& a) {
            j.at("home").get_to(a.home);
            j.at("room").get_to(a.room);
            j.at("name").get_to(a.name);
            
            if (j.contains("category") && !j["category"].is_null()) {
                a.category = j["category"].get<std::string>();
            }
            if (j.contains("isReachable") && !j["isReachable"].is_null()) {
                a.isReachable = j["isReachable"].get<bool>();
            }
            if (j.contains("supportsIdentify") && !j["supportsIdentify"].is_null()) {
                a.supportsIdentify = j["supportsIdentify"].get<bool>();
            }
            if (j.contains("isBridged") && !j["isBridged"].is_null()) {
                a.isBridged = j["isBridged"].get<bool>();
            }
            if (j.contains("services") && !j["services"].is_null()) {
                a.services = j["services"].get<std::vector<Service>>();
            }
            if (j.contains("firmwareVersion") && !j["firmwareVersion"].is_null()) {
                a.firmwareVersion = j["firmwareVersion"].get<std::string>();
            }
            if (j.contains("manufacturer") && !j["manufacturer"].is_null()) {
                a.manufacturer = j["manufacturer"].get<std::string>();
            }
            if (j.contains("model") && !j["model"].is_null()) {
                a.model = j["model"].get<std::string>();
            }
        }
    };

    /**
     * @brief Input structure for updating accessory characteristics
     * Matches the Swift server API: {serviceId, characteristicId, value}
     */
    struct UpdateAccessoryInput {
        std::string serviceId;
        std::string characteristicId;
        std::string value;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(UpdateAccessoryInput,
            serviceId, characteristicId, value)
    };

} // namespace prefab