# Copilot Instructions for Prefab

## Project Overview

Prefab is a macOS/iOS application that provides an HTTP interface to Apple HomeKit data. The project consists of two main components:

1. **Prefab App**: A SwiftUI application that exposes HomeKit data via a REST API
2. **Prefab CLI Tool**: A command-line client for interacting with the Prefab server

The goal is to make HomeKit functionality accessible to macOS systems through a simple HTTP interface, since native HomeKit APIs are primarily available on iOS.

## Architecture

### Core Components

- **prefab/**: Main SwiftUI application
  - `prefabApp.swift`: App entry point with server initialization
  - `ContentView.swift`: Main UI displaying HomeKit homes
  - `model/`: Data models and HomeKit integration
  - `http/`: HTTP server implementation using Hummingbird

- **prefab-client/**: Command-line tool
  - `Root.swift`: CLI entry point using ArgumentParser
  - `Client/`: HTTP client implementation
  - `Command/`: CLI command definitions

### Key Technologies

- **SwiftUI**: User interface framework
- **HomeKit**: Apple's home automation framework
- **Hummingbird**: Swift HTTP server framework
- **ArgumentParser**: Command-line argument parsing
- **HTTPTypes**: Modern HTTP types for Swift

## Development Guidelines

### Code Style and Patterns

1. **Swift Conventions**
   - Use Swift naming conventions (camelCase for variables/functions, PascalCase for types)
   - Prefer `struct` over `class` when possible
   - Use `@StateObject` and `@Published` for SwiftUI state management
   - Follow Apple's Swift API Design Guidelines

2. **HomeKit Integration**
   - Use `HomeBase` singleton for centralized HomeKit management
   - Implement `HMHomeManagerDelegate` for HomeKit updates
   - Use proper authorization checks before accessing HomeKit data
   - Handle HomeKit permissions gracefully in the UI

3. **HTTP Server Patterns**
   - Use middleware for cross-cutting concerns (auth, logging)
   - Implement proper error handling with meaningful HTTP status codes
   - Structure routes in separate files by functionality (Homes, Rooms, Accessories)
   - Use JSON for API responses

4. **Error Handling**
   - Use `throws` and `Result` types for error propagation
   - Provide meaningful error messages to users
   - Log errors appropriately using `OSLog`

### File Organization

```
prefab/
├── prefabApp.swift          # App entry point
├── ContentView.swift        # Main UI
├── model/
│   ├── HomeBase.swift       # HomeKit manager singleton
│   └── HAPUUIDs.swift       # HomeKit UUID definitions
└── http/
    ├── Server.swift         # HTTP server setup
    ├── Routes.swift         # Base route definitions
    ├── Routes+*.swift       # Feature-specific routes
    └── Data.swift           # Data models
```

### API Design

- **Base URL**: `http://localhost:8080`
- **Authentication**: HomeKit authorization required
- **Response Format**: JSON
- **Error Format**: `{"error": "Error message"}`

Common HTTP status codes:
- `200`: Success
- `400`: Bad Request (invalid parameters)
- `403`: Forbidden (HomeKit not authorized)
- `404`: Not Found
- `500`: Internal Server Error

### Testing

- Use XCTest for unit tests
- Tests are currently minimal - expand coverage for new features
- Test both the HTTP API and CLI functionality
- Mock HomeKit data for consistent testing

### HomeKit Specifics

1. **Authorization**
   - Check `homeManager.authorizationStatus` before API calls
   - Handle `.notDetermined`, `.restricted`, `.denied`, and `.authorized` states
   - Prompt users for permission when needed

2. **Data Models**
   - `HMHome`: Represents a HomeKit home
   - `HMRoom`: Rooms within a home
   - `HMAccessory`: HomeKit accessories (lights, locks, etc.)
   - Use HAP (HomeKit Accessory Protocol) UUIDs for characteristic identification

3. **Real-time Updates**
   - Implement delegate methods for HomeKit data changes
   - Use `@Published` properties to update UI automatically
   - Consider WebSocket connections for real-time API updates

### CLI Tool Guidelines

- Use ArgumentParser for command structure
- Implement subcommands for different operations (get, set, list)
- Provide helpful usage messages and examples
- Support JSON output for scripting
- Handle network errors gracefully

### Dependencies Management

The project uses Swift Package Manager through Xcode:
- **Hummingbird**: HTTP server framework
- **ArgumentParser**: CLI argument parsing
- **HTTPTypes**: HTTP type definitions

### Build and Deployment

- Target: macOS 11.0+ and iOS 14.0+
- Uses GitHub Actions for CI/CD
- Supports code signing and provisioning profiles
- Includes both debug and release configurations

### Security Considerations

1. **HomeKit Privacy**
   - Respect user privacy and HomeKit permissions
   - Don't cache sensitive data unnecessarily
   - Implement proper access controls

2. **HTTP Security**
   - Currently runs on localhost only
   - Consider authentication for production use
   - Validate all input parameters

3. **Code Signing**
   - Required for HomeKit entitlements
   - Configured in GitHub Actions workflow

### Common Patterns

1. **Singleton Pattern**: `HomeBase.shared` for HomeKit access
2. **Delegate Pattern**: HomeKit delegate methods for updates
3. **MVVM**: SwiftUI views with Observable models
4. **Route Organization**: Separate route files by feature
5. **Middleware**: Cross-cutting concerns in HTTP pipeline

### Development Workflow

1. **Setup**
   - Ensure Xcode 15.0+ is installed
   - HomeKit simulator or physical HomeKit devices for testing
   - Configure code signing for HomeKit entitlements

2. **Running**
   - Build and run the main app to start the HTTP server
   - Use the CLI tool to test API endpoints
   - Check logs in Console.app for debugging

3. **Testing**
   - Run unit tests in Xcode
   - Test with real HomeKit accessories when possible
   - Verify API responses with curl or the CLI tool

### Future Considerations

- WebSocket support for real-time updates
- Authentication and authorization for remote access
- Configuration file support
- Extended CLI functionality
- Docker container support
- Performance optimization for large HomeKit setups

## Getting Started

1. Clone the repository
2. Open `prefab.xcodeproj` in Xcode
3. Ensure HomeKit entitlements are properly configured
4. Build and run the project
5. Use the CLI tool to interact with the API

For new features, follow the established patterns and maintain consistency with the existing codebase structure.