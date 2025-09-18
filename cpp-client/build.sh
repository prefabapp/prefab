#!/bin/bash
# Build script for Prefab C++ Client Library

set -e

echo "Prefab C++ Client Build Script"
echo "=============================="

# Check if we're in the right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo "Error: Please run this script from the cpp-client directory"
    exit 1
fi

# Create build directory
BUILD_DIR="build"
if [ -d "$BUILD_DIR" ]; then
    echo "Removing existing build directory..."
    rm -rf "$BUILD_DIR"
fi

echo "Creating build directory..."
mkdir "$BUILD_DIR"
cd "$BUILD_DIR"

# Default build type
BUILD_TYPE=${1:-Release}

echo "Configuring CMake (Build Type: $BUILD_TYPE)..."
cmake .. \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_TESTS=ON

echo "Building..."
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo "Running tests..."
if make test; then
    echo "✓ All tests passed!"
else
    echo "⚠ Some tests failed"
fi

echo ""
echo "Build completed successfully!"
echo "Examples are available in: $BUILD_DIR/examples/"
echo "Library is available in: $BUILD_DIR/libprefab-client.a"
echo ""
echo "To install system-wide, run:"
echo "  sudo make install"
echo ""
echo "To run examples:"
echo "  ./examples/simple_client"
echo "  ./examples/discovery_example"
echo "  ./examples/accessory_control"