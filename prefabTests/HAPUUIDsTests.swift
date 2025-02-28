import XCTest
import HomeKit
@testable import Prefab  // Replace with your actual module name

class HAPUUIDsTests: XCTestCase {
    
    // MARK: - Core UUID Function Tests
    func testHAPUUIDParsing() {
        let doorLock = HMServiceTypeLockMechanism.lowercased()
        XCTAssertEqual(doorLock, "00000045-0000-1000-8000-0026bb765291")
        XCTAssertEqual(getHAPServiceInfo(fromUUIDString: doorLock)?.name, "Lock Mechanism")
    }
    
    func testHAPUUIDCreateAppleDefined() {
        // Test creating UUIDs from identifiers
        let lightbulbUUID = hapUUIDCreateAppleDefined(0x43)
        XCTAssertEqual(lightbulbUUID.uuidString.lowercased(), "00000043-0000-1000-8000-0026bb765291")
        
        // Test higher value
        let highValueUUID = hapUUIDCreateAppleDefined(0x123)
        XCTAssertEqual(highValueUUID.uuidString.lowercased(), "00000123-0000-1000-8000-0026bb765291")
    }
    
    func testHAPUUIDAsString() {
        // Test string representation
        let uuidString = hapUUIDAsString(0x43)
        XCTAssertEqual(uuidString.lowercased(), "00000043-0000-1000-8000-0026bb765291")
        
        // Test higher value
        let highValueString = hapUUIDAsString(0x123)
        XCTAssertEqual(highValueString.lowercased(), "00000123-0000-1000-8000-0026bb765291")
    }
    
    // MARK: - Characteristic Type Tests
    
    func testCharacteristicUUIDGeneration() {
        // Test a few common characteristics
        XCTAssertEqual(HAPCharacteristicType.on.uuidString.lowercased(), "00000025-0000-1000-8000-0026bb765291")
        XCTAssertEqual(HAPCharacteristicType.brightness.uuidString.lowercased(), "00000008-0000-1000-8000-0026bb765291")
        XCTAssertEqual(HAPCharacteristicType.currentTemperature.uuidString.lowercased(), "00000011-0000-1000-8000-0026bb765291")
    }
    
    func testCharacteristicDescription() {
        // Test descriptions are populated
        XCTAssertEqual(HAPCharacteristicType.on.description, "On")
        XCTAssertEqual(HAPCharacteristicType.brightness.description, "Brightness")
        // Even if we don't test all descriptions, ensure they're not empty for random cases
        XCTAssertFalse(HAPCharacteristicType.hue.description.isEmpty)
    }
    
    // MARK: - Service Type Tests
    
    func testServiceUUIDGeneration() {
        // Test a few common services
        XCTAssertEqual(HAPServiceType.lightbulb.uuidString.lowercased(), "00000043-0000-1000-8000-0026bb765291")
        XCTAssertEqual(HAPServiceType.temperatureSensor.uuidString.lowercased(), "0000008a-0000-1000-8000-0026bb765291")
        XCTAssertEqual(HAPServiceType.switch.uuidString.lowercased(), "00000049-0000-1000-8000-0026bb765291")
    }
    
    func testServiceDescription() {
        // Test descriptions are populated
        XCTAssertEqual(HAPServiceType.lightbulb.description, "Lightbulb")
        XCTAssertEqual(HAPServiceType.switch.description, "Switch")
        // Even if we don't test all descriptions, ensure they're not empty for random cases
        XCTAssertFalse(HAPServiceType.temperatureSensor.description.isEmpty)
    }
    
    // MARK: - Service Info Lookup Tests
    
    func testGetHAPServiceInfoFromUUID() {
        // Create a UUID for the lightbulb service
        let uuid = hapUUIDCreateAppleDefined(0x43)
        let info = getHAPServiceInfo(fromUUID: uuid)
        
        // Verify the info is correct
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.type, HAPServiceType.lightbulb)
        XCTAssertEqual(info?.name, "Lightbulb")
        XCTAssertEqual(info?.requiredCharacteristics.count, 1)
        XCTAssertEqual(info?.requiredCharacteristics.first, HAPCharacteristicType.on)
        XCTAssertEqual(info?.optionalCharacteristics.count, 5)
        XCTAssertTrue(info?.optionalCharacteristics.contains(HAPCharacteristicType.brightness) ?? false)
    }
    
    func testGetHAPServiceInfoFromUUIDString() {
        // Test with a string UUID for the temperature sensor
        let info = getHAPServiceInfo(fromUUIDString: "0000008A-0000-1000-8000-0026BB765291")
        
        // Verify the info is correct
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.type, HAPServiceType.temperatureSensor)
        XCTAssertEqual(info?.requiredCharacteristics.count, 1)
        XCTAssertEqual(info?.requiredCharacteristics.first, HAPCharacteristicType.currentTemperature)
    }
    
    func testGetHAPServiceInfoFromIdentifier() {
        // Test with the identifier for the switch service
        let info = getHAPServiceInfo(fromIdentifier: 0x49)
        
        // Verify the info is correct
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.type, HAPServiceType.switch)
        XCTAssertEqual(info?.requiredCharacteristics.count, 1)
        XCTAssertEqual(info?.requiredCharacteristics.first, HAPCharacteristicType.on)
    }
    
    func testGetHAPServiceInfoInvalidUUID() {
        // Test with an invalid UUID
        let uuid = UUID()
        let info = getHAPServiceInfo(fromUUID: uuid)
        
        // Should return nil for unknown UUIDs
        XCTAssertNil(info)
    }
    
    // MARK: - Characteristic Info Lookup Tests
    
    func testGetHAPCharacteristicInfoFromUUID() {
        // Create a UUID for the on characteristic
        let uuid = hapUUIDCreateAppleDefined(0x25)
        let info = getHAPCharacteristicInfo(fromUUID: uuid)
        
        // Verify the info is correct
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.type, HAPCharacteristicType.on)
        XCTAssertEqual(info?.format, .bool)
        XCTAssertTrue(info?.permissions.contains(.read) ?? false)
        XCTAssertTrue(info?.permissions.contains(.write) ?? false)
        XCTAssertTrue(info?.permissions.contains(.events) ?? false)
    }
    
    func testGetHAPCharacteristicInfoFromUUIDString() {
        // Test with a string UUID for the brightness characteristic
        let info = getHAPCharacteristicInfo(fromUUIDString: "00000008-0000-1000-8000-0026BB765291")
        
        // Verify the info is correct
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.type, HAPCharacteristicType.brightness)
        XCTAssertEqual(info?.format, .int)
        XCTAssertEqual(info?.unit, .percentage)
        XCTAssertEqual(info?.minValue as? Int, 0)
        XCTAssertEqual(info?.maxValue as? Int, 100)
    }
    
    func testGetHAPCharacteristicInfoFromIdentifier() {
        // Test with the identifier for the current temperature characteristic
        let info = getHAPCharacteristicInfo(fromIdentifier: 0x11)
        
        // Verify the info is correct
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.type, HAPCharacteristicType.currentTemperature)
        XCTAssertEqual(info?.format, .float)
        XCTAssertEqual(info?.unit, .celsius)
        XCTAssertTrue(info?.permissions.contains(.read) ?? false)
    }
    
    func testGetHAPCharacteristicInfoInvalidUUID() {
        // Test with an invalid UUID
        let uuid = UUID()
        let info = getHAPCharacteristicInfo(fromUUID: uuid)
        
        // Should return nil for unknown UUIDs
        XCTAssertNil(info)
    }
    
    // MARK: - Service-Characteristic Relationship Tests
    
    func testServiceRequiredCharacteristics() {
        // Verify required characteristics for the lightbulb service
        let requiredChars = HAPServiceType.lightbulb.requiredCharacteristics
        XCTAssertEqual(requiredChars.count, 1)
        XCTAssertEqual(requiredChars.first, HAPCharacteristicType.on)
        
        // Verify required characteristics for the thermostat service
        let thermostatChars = HAPServiceType.thermostat.requiredCharacteristics
        XCTAssertEqual(thermostatChars.count, 4)
        XCTAssertTrue(thermostatChars.contains(HAPCharacteristicType.currentTemperature))
        XCTAssertTrue(thermostatChars.contains(HAPCharacteristicType.targetTemperature))
    }
    
    func testServiceOptionalCharacteristics() {
        // Verify optional characteristics for the lightbulb service
        let optionalChars = HAPServiceType.lightbulb.optionalCharacteristics
        XCTAssertEqual(optionalChars.count, 5)
        XCTAssertTrue(optionalChars.contains(HAPCharacteristicType.brightness))
        XCTAssertTrue(optionalChars.contains(HAPCharacteristicType.hue))
        XCTAssertTrue(optionalChars.contains(HAPCharacteristicType.saturation))
    }
    
    func testCharacteristicAllForService() {
        // Verify getting all characteristics for a service
        let allChars = HAPCharacteristicType.allCharacteristicsForService(.lightbulb)
        XCTAssertEqual(allChars.count, 6) // 1 required + 5 optional
        XCTAssertTrue(allChars.contains(HAPCharacteristicType.on))
        XCTAssertTrue(allChars.contains(HAPCharacteristicType.brightness))
    }
    
    func testCharacteristicRequiredByServices() {
        // Get info about the "on" characteristic
        let info = getHAPCharacteristicInfo(fromIdentifier: 0x25) // "on" characteristic
        
        // Verify which services require this characteristic
        XCTAssertNotNil(info)
        let requiredByServices = info?.requiredByServices ?? []
        XCTAssertTrue(requiredByServices.contains(.lightbulb))
        XCTAssertTrue(requiredByServices.contains(.switch))
    }
    
    func testCharacteristicOptionalForServices() {
        // Get info about the "name" characteristic
        let info = getHAPCharacteristicInfo(fromIdentifier: 0x23) // "name" characteristic
        
        // Verify which services optionally include this characteristic
        XCTAssertNotNil(info)
        let optionalForServices = info?.optionalForServices ?? []
        XCTAssertTrue(optionalForServices.contains(.lightbulb))
        XCTAssertTrue(optionalForServices.contains(.temperatureSensor))
    }
} 
