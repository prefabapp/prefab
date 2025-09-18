# Tests CMakeLists.txt

# Simple test
add_executable(test_models test_models.cpp)
target_link_libraries(test_models prefab-client)

# Add test
add_test(NAME test_models COMMAND test_models)