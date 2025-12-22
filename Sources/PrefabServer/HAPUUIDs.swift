import Foundation

// MARK: - Core UUID Functions

/// Helper to create Apple-defined HAP UUIDs from a base UUID + 16-bit identifier
public func hapUUIDCreateAppleDefined(_ identifier: UInt16) -> UUID {
    // Format the string and create a UUID from it, which is more reliable
    // than trying to create the byte array directly
    let uuidString = String(format: "%08X-0000-1000-8000-0026BB765291", identifier)
    return UUID(uuidString: uuidString)!
}

/// Convert a 16-bit identifier to a string representation of a HAP UUID
public func hapUUIDAsString(_ identifier: UInt16) -> String {
    return String(format: "%08X-0000-1000-8000-0026BB765291", identifier)
}

// MARK: - HAP Characteristic Type

/// HomeKit Accessory Protocol characteristic types
public enum HAPCharacteristicType: UInt16, CaseIterable {
    // Basic characteristics
    case administratorOnlyAccess = 0x01
    case audioFeedback = 0x05
    case brightness = 0x08
    case coolingThresholdTemperature = 0x0D
    case currentDoorState = 0x0E
    case currentHeatingCoolingState = 0x0F
    case currentRelativeHumidity = 0x10
    case currentTemperature = 0x11
    case heatingThresholdTemperature = 0x12
    case hue = 0x13
    case identify = 0x14
    case lockControlPoint = 0x19
    case lockManagementAutoSecurityTimeout = 0x1A
    case lockLastKnownAction = 0x1C
    case lockCurrentState = 0x1D
    case lockTargetState = 0x1E
    case logs = 0x1F
    case manufacturer = 0x20
    case model = 0x21
    case motionDetected = 0x22
    case name = 0x23
    case obstructionDetected = 0x24
    case on = 0x25
    case outletInUse = 0x26
    case rotationDirection = 0x28
    case rotationSpeed = 0x29
    case saturation = 0x2F
    case serialNumber = 0x30
    case targetDoorState = 0x32
    case targetHeatingCoolingState = 0x33
    case targetRelativeHumidity = 0x34
    case targetTemperature = 0x35
    case temperatureDisplayUnits = 0x36
    case version = 0x37
    
    // Security characteristics
    case pairSetup = 0x4C
    case pairVerify = 0x4E
    case pairingFeatures = 0x4F
    case pairingPairings = 0x50
    case firmwareRevision = 0x52
    case hardwareRevision = 0x53
    
    // Sensor characteristics
    case airParticulateDensity = 0x64
    case airParticulateSize = 0x65
    case securitySystemCurrentState = 0x66
    case securitySystemTargetState = 0x67
    case batteryLevel = 0x68
    case carbonMonoxideDetected = 0x69
    case contactSensorState = 0x6A
    case currentAmbientLightLevel = 0x6B
    case currentHorizontalTiltAngle = 0x6C
    case currentPosition = 0x6D
    case currentVerticalTiltAngle = 0x6E
    case holdPosition = 0x6F
    case leakDetected = 0x70
    case occupancyDetected = 0x71
    case positionState = 0x72
    case programmableSwitchEvent = 0x73
    case programmableSwitchOutputState = 0x74
    case statusActive = 0x75
    case smokeDetected = 0x76
    case statusFault = 0x77
    case statusJammed = 0x78
    case statusLowBattery = 0x79
    case statusTampered = 0x7A
    case targetHorizontalTiltAngle = 0x7B
    case targetPosition = 0x7C
    case targetVerticalTiltAngle = 0x7D
    
    // Environmental characteristics
    case securitySystemAlarmType = 0x8E
    case chargingState = 0x8F
    case carbonMonoxideLevel = 0x90
    case carbonMonoxidePeakLevel = 0x91
    case carbonDioxideDetected = 0x92
    case carbonDioxideLevel = 0x93
    case carbonDioxidePeakLevel = 0x94
    case airQuality = 0x95
    
    // Air quality characteristics
    case serviceSignature = 0xA5
    case accessoryFlags = 0xA6
    case lockPhysicalControls = 0xA7
    case targetAirPurifierState = 0xA8
    case currentAirPurifierState = 0xA9
    case currentSlatState = 0xAA
    case filterLifeLevel = 0xAB
    case filterChangeIndication = 0xAC
    case resetFilterIndication = 0xAD
    case currentFanState = 0xAF
    
    // Fan and climate characteristics
    case active = 0xB0
    case currentHeaterCoolerState = 0xB1
    case targetHeaterCoolerState = 0xB2
    case currentHumidifierDehumidifierState = 0xB3
    case targetHumidifierDehumidifierState = 0xB4
    case waterLevel = 0xB5
    case swingMode = 0xB6
    case targetFanState = 0xBF
    
    // Slat characteristics
    case slatType = 0xC0
    case currentTiltAngle = 0xC1
    case targetTiltAngle = 0xC2
    
    // Air quality sensor characteristics
    case ozoneDensity = 0xC3
    case nitrogenDioxideDensity = 0xC4
    case sulphurDioxideDensity = 0xC5
    case pm2_5Density = 0xC6
    case pm10Density = 0xC7
    case vocDensity = 0xC8
    case relativeHumidityDehumidifierThreshold = 0xC9
    case relativeHumidityHumidifierThreshold = 0xCA
    case serviceLabelIndex = 0xCB
    case serviceLabelNamespace = 0xCD
    case colorTemperature = 0xCE
    
    // Irrigation characteristics
    case programMode = 0xD1
    case inUse = 0xD2
    case setDuration = 0xD3
    case remainingDuration = 0xD4
    case valveType = 0xD5
    case isConfigured = 0xD6
    
    // Media characteristics
    case activeIdentifier = 0xE7
    case configuredName = 0xE3
    case currentMediaState = 0xE0
    case targetMediaState = 0xE2
    case pictureMode = 0xE4
    case powerModeSelection = 0x13D
    case remoteKey = 0xE1
    case closedCaptions = 0x123
    case displayOrder = 0x136
    case inputSourceType = 0xDB
    case volume = 0x119
    case mute = 0x11A
    
    // Camera characteristics
    case streamingStatus = 0x120
    case supportedVideoStreamConfiguration = 0x114
    case supportedAudioStreamConfiguration = 0x115
    case supportedRTPConfiguration = 0x116
    case selectedRTPStreamConfiguration = 0x117
    case setupEndpoints = 0x118
    case nightVision = 0x11B
    case opticalZoom = 0x11C
    case digitalZoom = 0x11D
    case imageRotation = 0x11E
    case imageMirroring = 0x11F
    
    // New iOS 15+ characteristics
    case buttonEvent = 0x126
    case selectedAudioStreamConfiguration = 0x128
    case supportedDataStreamTransportConfiguration = 0x130
    case setupDataStreamTransport = 0x131
    case siriInputType = 0x132
    
    public var uuid: UUID {
        return hapUUIDCreateAppleDefined(self.rawValue)
    }
    
    public var uuidString: String {
        return hapUUIDAsString(self.rawValue)
    }
    
    public var description: String {
        switch self {
        // Basic characteristics
        case .administratorOnlyAccess: return "Administrator Only Access"
        case .audioFeedback: return "Audio Feedback"
        case .brightness: return "Brightness"
        case .coolingThresholdTemperature: return "Cooling Threshold Temperature"
        case .currentDoorState: return "Current Door State"
        case .currentHeatingCoolingState: return "Current Heating Cooling State"
        case .currentRelativeHumidity: return "Current Relative Humidity"
        case .currentTemperature: return "Current Temperature"
        case .heatingThresholdTemperature: return "Heating Threshold Temperature"
        case .hue: return "Hue"
        case .identify: return "Identify"
        case .lockControlPoint: return "Lock Control Point"
        case .lockManagementAutoSecurityTimeout: return "Auto Security Timeout"
        case .lockLastKnownAction: return "Last Known Action"
        case .lockCurrentState: return "Current Lock State"
        case .lockTargetState: return "Target Lock State"
        case .logs: return "Logs"
        case .manufacturer: return "Manufacturer"
        case .model: return "Model"
        case .motionDetected: return "Motion Detected"
        case .name: return "Name"
        case .obstructionDetected: return "Obstruction Detected"
        case .on: return "On"
        case .outletInUse: return "Outlet In Use"
        case .rotationDirection: return "Rotation Direction"
        case .rotationSpeed: return "Rotation Speed"
        case .saturation: return "Saturation"
        case .serialNumber: return "Serial Number"
        case .targetDoorState: return "Target Door State"
        case .targetHeatingCoolingState: return "Target Heating Cooling State"
        case .targetRelativeHumidity: return "Target Relative Humidity"
        case .targetTemperature: return "Target Temperature"
        case .temperatureDisplayUnits: return "Temperature Display Units"
        case .version: return "Version"
        
        // Security characteristics
        case .pairSetup: return "Pair Setup"
        case .pairVerify: return "Pair Verify"
        case .pairingFeatures: return "Pairing Features"
        case .pairingPairings: return "Pairing Pairings"
        case .firmwareRevision: return "Firmware Revision"
        case .hardwareRevision: return "Hardware Revision"
        
        // Sensor characteristics
        case .airParticulateDensity: return "Air Particulate Density"
        case .airParticulateSize: return "Air Particulate Size"
        case .securitySystemCurrentState: return "Security System Current State"
        case .securitySystemTargetState: return "Security System Target State"
        case .batteryLevel: return "Battery Level"
        case .carbonMonoxideDetected: return "Carbon Monoxide Detected"
        case .contactSensorState: return "Contact Sensor State"
        case .currentAmbientLightLevel: return "Current Ambient Light Level"
        case .currentHorizontalTiltAngle: return "Current Horizontal Tilt Angle"
        case .currentPosition: return "Current Position"
        case .currentVerticalTiltAngle: return "Current Vertical Tilt Angle"
        case .holdPosition: return "Hold Position"
        case .leakDetected: return "Leak Detected"
        case .occupancyDetected: return "Occupancy Detected"
        case .positionState: return "Position State"
        case .programmableSwitchEvent: return "Programmable Switch Event"
        case .programmableSwitchOutputState: return "Programmable Switch Output State"
        case .statusActive: return "Status Active"
        case .smokeDetected: return "Smoke Detected"
        case .statusFault: return "Status Fault"
        case .statusJammed: return "Status Jammed"
        case .statusLowBattery: return "Status Low Battery"
        case .statusTampered: return "Status Tampered"
        case .targetHorizontalTiltAngle: return "Target Horizontal Tilt Angle"
        case .targetPosition: return "Target Position"
        case .targetVerticalTiltAngle: return "Target Vertical Tilt Angle"
        
        // Environmental characteristics
        case .securitySystemAlarmType: return "Security System Alarm Type"
        case .chargingState: return "Charging State"
        case .carbonMonoxideLevel: return "Carbon Monoxide Level"
        case .carbonMonoxidePeakLevel: return "Carbon Monoxide Peak Level"
        case .carbonDioxideDetected: return "Carbon Dioxide Detected"
        case .carbonDioxideLevel: return "Carbon Dioxide Level"
        case .carbonDioxidePeakLevel: return "Carbon Dioxide Peak Level"
        case .airQuality: return "Air Quality"
        
        // Air quality characteristics
        case .serviceSignature: return "Service Signature"
        case .accessoryFlags: return "Accessory Flags"
        case .lockPhysicalControls: return "Lock Physical Controls"
        case .targetAirPurifierState: return "Target Air Purifier State"
        case .currentAirPurifierState: return "Current Air Purifier State"
        case .currentSlatState: return "Current Slat State"
        case .filterLifeLevel: return "Filter Life Level"
        case .filterChangeIndication: return "Filter Change Indication"
        case .resetFilterIndication: return "Reset Filter Indication"
        case .currentFanState: return "Current Fan State"
        
        // Fan and climate characteristics
        case .active: return "Active"
        case .currentHeaterCoolerState: return "Current Heater Cooler State"
        case .targetHeaterCoolerState: return "Target Heater Cooler State"
        case .currentHumidifierDehumidifierState: return "Current Humidifier Dehumidifier State"
        case .targetHumidifierDehumidifierState: return "Target Humidifier Dehumidifier State"
        case .waterLevel: return "Water Level"
        case .swingMode: return "Swing Mode"
        case .targetFanState: return "Target Fan State"
        
        // Slat characteristics
        case .slatType: return "Slat Type"
        case .currentTiltAngle: return "Current Tilt Angle"
        case .targetTiltAngle: return "Target Tilt Angle"
        
        // Air quality sensor characteristics
        case .ozoneDensity: return "Ozone Density"
        case .nitrogenDioxideDensity: return "Nitrogen Dioxide Density"
        case .sulphurDioxideDensity: return "Sulphur Dioxide Density"
        case .pm2_5Density: return "PM2.5 Density"
        case .pm10Density: return "PM10 Density"
        case .vocDensity: return "VOC Density"
        case .relativeHumidityDehumidifierThreshold: return "Relative Humidity Dehumidifier Threshold"
        case .relativeHumidityHumidifierThreshold: return "Relative Humidity Humidifier Threshold"
        case .serviceLabelIndex: return "Service Label Index"
        case .serviceLabelNamespace: return "Service Label Namespace"
        case .colorTemperature: return "Color Temperature"
        
        // Irrigation characteristics
        case .programMode: return "Program Mode"
        case .inUse: return "In Use"
        case .setDuration: return "Set Duration"
        case .remainingDuration: return "Remaining Duration"
        case .valveType: return "Valve Type"
        case .isConfigured: return "Is Configured"
        
        // Media characteristics
        case .activeIdentifier: return "Active Identifier"
        case .configuredName: return "Configured Name"
        case .currentMediaState: return "Current Media State"
        case .targetMediaState: return "Target Media State"
        case .remoteKey: return "Remote Key"
        case .closedCaptions: return "Closed Captions"
        case .pictureMode: return "Picture Mode"
        case .powerModeSelection: return "Power Mode Selection"
        case .displayOrder: return "Display Order"
        case .volume: return "Volume"
        case .mute: return "Mute"
        
        // Stream characteristics
        case .streamingStatus: return "Streaming Status"
        case .digitalZoom: return "Digital Zoom"
        case .opticalZoom: return "Optical Zoom"
        case .imageMirroring: return "Image Mirroring"
        case .imageRotation: return "Image Rotation"
        case .nightVision: return "Night Vision"
        case .supportedVideoStreamConfiguration: return "Supported Video Stream Configuration"
        case .supportedAudioStreamConfiguration: return "Supported Audio Stream Configuration"
        case .supportedRTPConfiguration: return "Supported RTP Configuration"
        case .selectedRTPStreamConfiguration: return "Selected RTP Stream Configuration"
        case .setupEndpoints: return "Setup Endpoints"
        case .selectedAudioStreamConfiguration: return "Selected Audio Stream Configuration"
        
        // Control characteristics
        case .buttonEvent: return "Button Event"
//        case .tapType: return "Tap Type"
//        case .targetControlList: return "Target Control List"
//        case .targetControlSupportedConfiguration: return "Target Control Supported Configuration"
//        case .inputDeviceType: return "Input Device Type"
        case .inputSourceType: return "Input Source Type"
        
        // Network characteristics
        case .setupDataStreamTransport: return "Setup Data Stream Transport"
        case .supportedDataStreamTransportConfiguration: return "Supported Data Stream Transport Configuration"
        case .siriInputType: return "Siri Input Type"
//        case .wiFiCapabilities: return "WiFi Capabilities"
//        case .wiFiConfigurationControl: return "WiFi Configuration Control"
//        case .wakeConfiguration: return "Wake Configuration"
        
        // Additional characteristics
        default: return "Characteristic \(String(format: "0x%X", self.rawValue))"
        }
    }
}

// MARK: - HAP Service Type

/// HomeKit Accessory Protocol service types
public enum HAPServiceType: UInt16, CaseIterable {
    case accessoryInformation = 0x3E
    case fan = 0x40
    case garageDoorOpener = 0x41
    case lightbulb = 0x43
    case lockManagement = 0x44
    case lockMechanism = 0x45
    case outlet = 0x47
    case `switch` = 0x49
    case thermostat = 0x4A
    case pairing = 0x55
    case securitySystem = 0x7E
    case carbonMonoxideSensor = 0x7F
    case contactSensor = 0x80
    case door = 0x81
    case humiditySensor = 0x82
    case leakSensor = 0x83
    case lightSensor = 0x84
    case motionSensor = 0x85
    case occupancySensor = 0x86
    case smokeSensor = 0x87
    case statefulProgrammableSwitch = 0x88
    case statelessProgrammableSwitch = 0x89
    case temperatureSensor = 0x8A
    case window = 0x8B
    case windowCovering = 0x8C
    case airQualitySensor = 0x8D
    case battery = 0x96
    case carbonDioxideSensor = 0x97
    case fanV2 = 0xB7
    case slats = 0xB9
    case filterMaintenance = 0xBA
    case airPurifier = 0xBB
    case heaterCooler = 0xBC
    case humidifierDehumidifier = 0xBD
    case serviceLabel = 0xCC
    case irrigationSystem = 0xCF
    case valve = 0xD0
    case faucet = 0xD7
    case television = 0xD8
    
    public var uuid: UUID {
        return hapUUIDCreateAppleDefined(self.rawValue)
    }
    
    public var uuidString: String {
        return hapUUIDAsString(self.rawValue)
    }
    
    public var description: String {
        switch self {
        // Basic services
        case .accessoryInformation: return "Accessory Information"
        case .airQualitySensor: return "Air Quality Sensor"
        case .battery: return "Battery Service"
        case .carbonDioxideSensor: return "Carbon Dioxide Sensor"
        case .carbonMonoxideSensor: return "Carbon Monoxide Sensor"
        case .contactSensor: return "Contact Sensor"
        case .door: return "Door"
        case .fan: return "Fan"
        case .fanV2: return "Fan v2"
        case .garageDoorOpener: return "Garage Door Opener"
        case .humiditySensor: return "Humidity Sensor"
        case .leakSensor: return "Leak Sensor"
        case .lightSensor: return "Light Sensor"
        case .lightbulb: return "Lightbulb"
        case .lockManagement: return "Lock Management"
        case .lockMechanism: return "Lock Mechanism"
        case .motionSensor: return "Motion Sensor"
        case .occupancySensor: return "Occupancy Sensor"
        case .outlet: return "Outlet"
        case .securitySystem: return "Security System"
        case .smokeSensor: return "Smoke Sensor"
        case .statefulProgrammableSwitch: return "Stateful Programmable Switch"
        case .statelessProgrammableSwitch: return "Stateless Programmable Switch"
        case .switch: return "Switch"
        case .temperatureSensor: return "Temperature Sensor"
        case .thermostat: return "Thermostat"
        case .window: return "Window"
        case .windowCovering: return "Window Covering"
        
        // Climate control services
        case .airPurifier: return "Air Purifier"
        case .heaterCooler: return "Heater Cooler"
        case .humidifierDehumidifier: return "Humidifier Dehumidifier"
        case .slats: return "Slats"
        case .filterMaintenance: return "Filter Maintenance"
        
        // Additional services
        case .faucet: return "Faucet"
        case .valve: return "Valve"
        case .irrigationSystem: return "Irrigation System"
        case .serviceLabel: return "Service Label"
        case .television: return "Television"
        
        // If we don't have a specific case, fall back to hex representation
        default: return "Service \(String(format: "0x%X", self.rawValue))"
        }
    }
}

// MARK: - Service-Characteristic Relationships

/// Structure representing the characteristic requirements for a service
public struct HAPServiceCharacteristicRequirements {
    let requiredCharacteristics: [HAPCharacteristicType]
    let optionalCharacteristics: [HAPCharacteristicType]
}

/// Dictionary mapping service types to their characteristic requirements
public let hapServiceCharacteristicRequirements: [HAPServiceType: HAPServiceCharacteristicRequirements] = [
    .accessoryInformation: HAPServiceCharacteristicRequirements(
        requiredCharacteristics: [
            .identify, .manufacturer, .model, .name, .serialNumber
        ],
        optionalCharacteristics: [
            .firmwareRevision, .hardwareRevision
        ]
    ),
    .lightbulb: HAPServiceCharacteristicRequirements(
        requiredCharacteristics: [
            .on
        ],
        optionalCharacteristics: [
            .brightness, .colorTemperature, .hue, .name, .saturation
        ]
    ),
    .switch: HAPServiceCharacteristicRequirements(
        requiredCharacteristics: [
            .on
        ],
        optionalCharacteristics: [
            .name
        ]
    ),
    .temperatureSensor: HAPServiceCharacteristicRequirements(
        requiredCharacteristics: [
            .currentTemperature
        ],
        optionalCharacteristics: [
            .name, .statusActive, .statusFault, .statusLowBattery, .statusTampered
        ]
    ),
    .thermostat: HAPServiceCharacteristicRequirements(
        requiredCharacteristics: [
            .currentHeatingCoolingState,
            .currentTemperature,
            .targetHeatingCoolingState,
            .targetTemperature
        ],
        optionalCharacteristics: [
            .coolingThresholdTemperature,
            .heatingThresholdTemperature,
            .name,
            .temperatureDisplayUnits
        ]
    ),
    .lockMechanism: HAPServiceCharacteristicRequirements(
        requiredCharacteristics: [
            .lockCurrentState,
            .lockTargetState
        ],
        optionalCharacteristics: [
            .name
        ]
    ),
    .statelessProgrammableSwitch: HAPServiceCharacteristicRequirements(
        requiredCharacteristics: [
            .programmableSwitchEvent
        ],
        optionalCharacteristics: [
            .name,
            .serviceLabelIndex,
            .statusActive
        ]
    ),
    .statefulProgrammableSwitch: HAPServiceCharacteristicRequirements(
        requiredCharacteristics: [
            .serviceLabelIndex
        ],
        optionalCharacteristics: [
            .name,
            .programmableSwitchEvent,
            .statusActive
        ]
    ),
    
    // Add more services as needed...
]

// MARK: - Convenience Extensions

extension HAPCharacteristicType {
    /// Returns all characteristics for a given service, both required and optional
    public static func allCharacteristicsForService(_ serviceType: HAPServiceType) -> [HAPCharacteristicType] {
        guard let requirements = hapServiceCharacteristicRequirements[serviceType] else {
            return []
        }
        
        return requirements.requiredCharacteristics + requirements.optionalCharacteristics
    }
}

extension HAPServiceType {
    /// Returns the required characteristics for this service
    public var requiredCharacteristics: [HAPCharacteristicType] {
        return hapServiceCharacteristicRequirements[self]?.requiredCharacteristics ?? []
    }
    
    /// Returns the optional characteristics for this service
    public var optionalCharacteristics: [HAPCharacteristicType] {
        return hapServiceCharacteristicRequirements[self]?.optionalCharacteristics ?? []
    }
}

// MARK: - Service Information Lookup

/// Represents information about a HomeKit service
public struct HAPServiceInfo {
    public let type: HAPServiceType
    public let name: String
    public let requiredCharacteristics: [HAPCharacteristicType]
    public let optionalCharacteristics: [HAPCharacteristicType]
    
    /// All characteristics (required + optional)
    public var allCharacteristics: [HAPCharacteristicType] {
        return requiredCharacteristics + optionalCharacteristics
    }
}

/// Get information about a service from its UUID
/// - Parameter uuid: The service UUID
/// - Returns: Service information or nil if not recognized
public func getHAPServiceInfo(fromUUID uuid: UUID) -> HAPServiceInfo? {
    // Find the service type that matches the UUID
    guard let serviceType = HAPServiceType.allCases.first(where: { $0.uuid == uuid }) else {
        return nil
    }
    
    return getHAPServiceInfo(fromType: serviceType)
}

/// Get information about a service from its UUID string
/// - Parameter uuidString: The service UUID as a string
/// - Returns: Service information or nil if not recognized
public func getHAPServiceInfo(fromUUIDString uuidString: String) -> HAPServiceInfo? {
    // Find the service type that matches the UUID string
    guard let serviceType = HAPServiceType.allCases.first(where: { $0.uuidString.lowercased() == uuidString.lowercased() }) else {
        return nil
    }
    
    return getHAPServiceInfo(fromType: serviceType)
}

/// Get information about a service from its 16-bit identifier
/// - Parameter identifier: The 16-bit service identifier
/// - Returns: Service information or nil if not recognized
public func getHAPServiceInfo(fromIdentifier identifier: UInt16) -> HAPServiceInfo? {
    // Find the service type that matches the identifier
    guard let serviceType = HAPServiceType(rawValue: identifier) else {
        return nil
    }
    
    return getHAPServiceInfo(fromType: serviceType)
}

/// Helper to create service info from a service type
private func getHAPServiceInfo(fromType serviceType: HAPServiceType) -> HAPServiceInfo {
    return HAPServiceInfo(
        type: serviceType,
        name: serviceType.description,
        requiredCharacteristics: serviceType.requiredCharacteristics,
        optionalCharacteristics: serviceType.optionalCharacteristics
    )
}

// Usage examples:
// let info1 = getHAPServiceInfo(fromUUID: someUUID)
// let info2 = getHAPServiceInfo(fromUUIDString: "00000043-0000-1000-8000-0026BB765291")
// let info3 = getHAPServiceInfo(fromIdentifier: 0x43) // Lightbulb 

// MARK: - Characteristic Information Lookup

/// Represents information about a HomeKit characteristic
public struct HAPCharacteristicInfo {
    public let type: HAPCharacteristicType
    public let name: String
    public let format: HAPCharacteristicFormat
    public let permissions: HAPCharacteristicPermissions
    public let unit: HAPCharacteristicUnit?
    public let minValue: Any?
    public let maxValue: Any?
    public let stepValue: Any?
    
    /// Services that require this characteristic
    public var requiredByServices: [HAPServiceType] {
        return HAPServiceType.allCases.filter { serviceType in
            serviceType.requiredCharacteristics.contains(type)
        }
    }
    
    /// Services that optionally include this characteristic
    public var optionalForServices: [HAPServiceType] {
        return HAPServiceType.allCases.filter { serviceType in
            serviceType.optionalCharacteristics.contains(type)
        }
    }
}

/// Format of characteristic values
public enum HAPCharacteristicFormat: String {
    case bool
    case uint8
    case uint16
    case uint32
    case uint64
    case int
    case float
    case string
    case tlv8
    case data
}

/// Permissions available for characteristics
public struct HAPCharacteristicPermissions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let read = HAPCharacteristicPermissions(rawValue: 1 << 0)
    public static let write = HAPCharacteristicPermissions(rawValue: 1 << 1)
    public static let events = HAPCharacteristicPermissions(rawValue: 1 << 2) // Supports notifications
    
    /// String representation of permissions
    public var description: String {
        var permissions: [String] = []
        if contains(.read) { permissions.append("read") }
        if contains(.write) { permissions.append("write") }
        if contains(.events) { permissions.append("events") }
        return permissions.joined(separator: ", ")
    }
}

/// Units for characteristic values
public enum HAPCharacteristicUnit: String {
    case celsius
    case percentage
    case arcdegrees
    case lux
    case seconds
}

/// Get information about a characteristic from its UUID
/// - Parameter uuid: The characteristic UUID
/// - Returns: Characteristic information or nil if not recognized
public func getHAPCharacteristicInfo(fromUUID uuid: UUID) -> HAPCharacteristicInfo? {
    // Find the characteristic type that matches the UUID
    guard let characteristicType = HAPCharacteristicType.allCases.first(where: { $0.uuid == uuid }) else {
        return nil
    }
    
    return getHAPCharacteristicInfo(fromType: characteristicType)
}

/// Get information about a characteristic from its UUID string
/// - Parameter uuidString: The characteristic UUID as a string
/// - Returns: Characteristic information or nil if not recognized
public func getHAPCharacteristicInfo(fromUUIDString uuidString: String) -> HAPCharacteristicInfo? {
    // Find the characteristic type that matches the UUID string
    guard let characteristicType = HAPCharacteristicType.allCases.first(where: { 
        $0.uuidString.lowercased() == uuidString.lowercased() 
    }) else {
        return nil
    }
    
    return getHAPCharacteristicInfo(fromType: characteristicType)
}

/// Get information about a characteristic from its 16-bit identifier
/// - Parameter identifier: The 16-bit characteristic identifier
/// - Returns: Characteristic information or nil if not recognized
public func getHAPCharacteristicInfo(fromIdentifier identifier: UInt16) -> HAPCharacteristicInfo? {
    // Find the characteristic type that matches the identifier
    guard let characteristicType = HAPCharacteristicType(rawValue: identifier) else {
        return nil
    }
    
    return getHAPCharacteristicInfo(fromType: characteristicType)
}

/// Helper to create characteristic info from a characteristic type
private func getHAPCharacteristicInfo(fromType characteristicType: HAPCharacteristicType) -> HAPCharacteristicInfo {
    // Get format and other metadata based on characteristic type
    let (format, permissions, unit, minValue, maxValue, stepValue) = getMetadataForCharacteristic(characteristicType)
    
    return HAPCharacteristicInfo(
        type: characteristicType,
        name: characteristicType.description,
        format: format,
        permissions: permissions,
        unit: unit,
        minValue: minValue,
        maxValue: maxValue,
        stepValue: stepValue
    )
}

/// Get metadata for a characteristic based on its type
private func getMetadataForCharacteristic(_ type: HAPCharacteristicType) -> 
    (format: HAPCharacteristicFormat, permissions: HAPCharacteristicPermissions, unit: HAPCharacteristicUnit?, minValue: Any?, maxValue: Any?, stepValue: Any?) {
    
    // Default values
    var format: HAPCharacteristicFormat = .string
    var permissions: HAPCharacteristicPermissions = [.read]
    var unit: HAPCharacteristicUnit? = nil
    var minValue: Any? = nil
    var maxValue: Any? = nil
    var stepValue: Any? = nil
    
    // Determine format, permissions, and other metadata based on characteristic type
    switch type {
    case .on:
        format = .bool
        permissions = [.read, .write, .events]
        
    case .brightness:
        format = .int
        permissions = [.read, .write, .events]
        unit = .percentage
        minValue = 0
        maxValue = 100
        stepValue = 1
        
    case .currentTemperature:
        format = .float
        permissions = [.read, .events]
        unit = .celsius
        minValue = -270.0
        maxValue = 100.0
        stepValue = 0.1
        
    case .hue:
        format = .float
        permissions = [.read, .write, .events]
        unit = .arcdegrees
        minValue = 0.0
        maxValue = 360.0
        stepValue = 1.0
        
    case .saturation:
        format = .float
        permissions = [.read, .write, .events]
        unit = .percentage
        minValue = 0.0
        maxValue = 100.0
        stepValue = 1.0
        
    case .identify:
        format = .bool
        permissions = [.write]
        
    case .name, .manufacturer, .model, .serialNumber:
        format = .string
        permissions = [.read]
        
    // Add more cases as needed for other characteristic types
        
    default:
        // Provide reasonable defaults for unknown characteristics
        if type.rawValue >= 0x50 && type.rawValue <= 0x70 {
            // Most sensor values are read-only with events
            format = .bool
            permissions = [.read, .events]
        } else if type.rawValue >= 0x20 && type.rawValue <= 0x40 {
            // Many standard characteristics are readable and writable
            format = .string
            permissions = [.read, .write]
        }
    }
    
    return (format, permissions, unit, minValue, maxValue, stepValue)
}

// Usage examples:
// let info1 = getHAPCharacteristicInfo(fromUUID: someUUID)
// let info2 = getHAPCharacteristicInfo(fromUUIDString: "00000025-0000-1000-8000-0026BB765291") // On characteristic
// let info3 = getHAPCharacteristicInfo(fromIdentifier: 0x25) // On characteristic 
