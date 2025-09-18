Prefab
======

Prefab is an application that provides a simple HTTP interface to [HomeKit](https://developer.apple.com/documentation/homekit) data. As of this writing the native HomeKit APIs are only available on iOS based systems. The goal of this app is to provide HomeKit access to macOS. The Prefab application provides access to data provided by HomeKit while the prefab CLI tool provides a simple client to request HomeKit data and provide shell access.

## Requirements

- **Xcode**: Version 15.0 or later
- **macOS**: 14.2 or later (for macOS target)
- **iOS**: 17.2 or later (for iOS target)
- **HomeKit Setup**: Physical HomeKit accessories or HomeKit simulator
- **Apple Developer Account**: Required for HomeKit entitlements and code signing

## Dependencies

This project uses Swift Package Manager through Xcode with the following dependencies:

- **[Hummingbird](https://github.com/hummingbird-project/hummingbird.git)**: Swift HTTP server framework
- **[swift-http-types](https://github.com/apple/swift-http-types.git)**: Modern HTTP types for Swift
- **[swift-argument-parser](https://github.com/apple/swift-argument-parser.git)**: Command-line argument parsing

## Setup and Installation

### 1. Clone the Repository

```bash
git clone https://github.com/kellyp/prefab.git
cd prefab
```

### 2. Open in Xcode

```bash
open prefab.xcodeproj
```

### 3. Resolve Dependencies

Dependencies are automatically resolved by Xcode when you first open the project. If you need to manually resolve them:

1. In Xcode, go to **File** → **Packages** → **Resolve Package Versions**
2. Wait for Xcode to download and resolve all Swift packages

### 4. Configure Code Signing

1. Select the **prefab** project in the navigator
2. Select the **Prefab** target
3. Go to **Signing & Capabilities**
4. Select your development team
5. Ensure the **HomeKit** capability is enabled

## Building

### Build from Xcode

1. Select your target device or simulator
2. Press **⌘+B** to build, or **⌘+R** to build and run

### Build from Command Line

```bash
# Build all targets
xcodebuild -project prefab.xcodeproj -scheme Prefab build

# Build for specific destination
xcodebuild -project prefab.xcodeproj -scheme Prefab -destination 'platform=macOS' build
```

### Build Products

The build creates two main products:
- **Prefab.app**: The main SwiftUI application with HTTP server
- **prefab**: The command-line tool (embedded in the app bundle)

## Testing

### Run Tests in Xcode

1. Press **⌘+U** to run all tests
2. Or use **Product** → **Test** from the menu

### Run Tests from Command Line

```bash
# Run all tests
xcodebuild test -project prefab.xcodeproj -scheme Prefab -destination 'platform=macOS'

# Run specific test plan
xcodebuild test -project prefab.xcodeproj -testPlan Prefab -destination 'platform=macOS'
```

### Test Targets

- **prefabTests**: Unit tests for core functionality
- **prefabUITests**: UI automation tests

## Running

### 1. Run the Main Application

**From Xcode:**
- Select the **Prefab** scheme
- Press **⌘+R** to run

**From Command Line:**
```bash
# Option 1: Build to a specific directory (most predictable)
xcodebuild -project prefab.xcodeproj -scheme Prefab -destination 'platform=macOS' \
  -derivedDataPath ./build build
open ./build/Build/Products/Debug-maccatalyst/Prefab.app

# Option 2: Use default derived data path
xcodebuild -project prefab.xcodeproj -scheme Prefab -destination 'platform=macOS' build
open ~/Library/Developer/Xcode/DerivedData/prefab-*/Build/Products/Debug-iphoneos/Prefab.app

# Option 3: Build and run in one command with custom path
xcodebuild -project prefab.xcodeproj -scheme Prefab -destination 'platform=macOS' \
  -derivedDataPath ./build build && \
open ./build/Build/Products/Debug-maccatalyst/Prefab.app
```

The application will:
1. Start the HTTP server on `http://localhost:8080` (accessible at `0.0.0.0:8080`)
2. Advertise the service via mDNS/Bonjour as "Prefab HomeKit Server" (`_prefab._tcp.`)
3. Display a SwiftUI interface showing your HomeKit homes
4. Begin serving HomeKit data via REST API

### Service Discovery

The server automatically advertises itself using mDNS (Bonjour) with:
- **Service Type**: `_prefab._tcp.`
- **Service Name**: "Prefab HomeKit Server"
- **Port**: 8080
- **TXT Record**: Contains version info and API details

You can discover the service using:
```bash
# Using dns-sd command-line tool
dns-sd -B _prefab._tcp.

# Or browse all services
dns-sd -B _tcp.
```

### 2. Use the CLI Tool

The CLI tool is embedded within the app bundle. To use it:

```bash
# Navigate to the app bundle
cd build/Build/Products/Debug/

# Or if running from Xcode's DerivedData
./prefab --help
```

**Available CLI commands:**
```bash
# Get all homes
./prefab homes

# Get specific home details
./prefab home --id [HOME_ID]

# Get rooms in a home
./prefab rooms --home-id [HOME_ID]

# Get accessories
./prefab accessories --home-id [HOME_ID]

# Update accessory
./prefab update-accessory --id [ACCESSORY_ID] --value [VALUE]
```

### 3. API Usage

Once the app is running, you can interact with the HTTP API locally or from other devices on your network:

```bash
# Local access
curl http://localhost:8080/homes

# Network access (replace with actual IP)
curl http://192.168.1.100:8080/homes

# Get specific home
curl http://localhost:8080/homes/[HOME_ID]

# Get rooms in a home
curl http://localhost:8080/homes/[HOME_ID]/rooms

# Get accessories in a home
curl http://localhost:8080/homes/[HOME_ID]/accessories
```

**mDNS/Bonjour Discovery**: Other devices can discover the service automatically and connect using the advertised hostname and port.

## Development Workflow

### First-Time Setup

1. Ensure you have HomeKit accessories set up on your iOS device, or use the HomeKit simulator
2. Build and run the app on your Mac
3. Grant HomeKit permissions when prompted
4. Verify the API is responding at `http://localhost:8080/homes`

### Making Changes

1. Edit Swift files in Xcode
2. The HTTP server will restart automatically when you rebuild
3. Use the CLI tool or curl to test API changes
4. Run tests to ensure nothing is broken

### Debugging

- **Console Logs**: Check Console.app for detailed logging output
- **Network Debugging**: Use tools like curl or Postman to test API endpoints
- **HomeKit Debugging**: Use the Home app on iOS to verify HomeKit state

## Common Issues

### HomeKit Permission Denied

If you get `403 Forbidden` responses:
1. Check that HomeKit permission is granted in System Preferences
2. Verify the HomeKit entitlement is properly configured
3. Ensure you're signed with a valid developer certificate

### Build Failures

If dependencies fail to resolve:
1. Clean build folder (**⌘+Shift+K**)
2. Reset package caches: **File** → **Packages** → **Reset Package Caches**
3. Manually resolve packages: **File** → **Packages** → **Resolve Package Versions**

### Server Won't Start

If the HTTP server fails to start:
1. Check that port 8080 is not in use by another process
2. Review console logs for specific error messages
3. Ensure proper code signing for network access

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request
