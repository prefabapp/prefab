# Examples CMakeLists.txt

# Simple client example
add_executable(simple_client simple_client.cpp)
target_link_libraries(simple_client prefab-client)

# Discovery example
add_executable(discovery_example discovery_example.cpp)
target_link_libraries(discovery_example prefab-client)

# Accessory control example
add_executable(accessory_control accessory_control.cpp)
target_link_libraries(accessory_control prefab-client)

# Install examples (optional)
option(INSTALL_EXAMPLES "Install example programs" OFF)
if(INSTALL_EXAMPLES)
    install(TARGETS simple_client discovery_example accessory_control
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/prefab-examples
    )
endif()