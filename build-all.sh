
#!/bin/bash
set -e

# OpenCog Unified Build Script
echo "=========================================="
echo "OpenCog Unified Framework Build Script"
echo "=========================================="

# Configuration
BUILD_TYPE=${BUILD_TYPE:-Release}
INSTALL_PREFIX=${INSTALL_PREFIX:-/usr/local}
JOBS=${JOBS:-$(nproc)}
BUILD_DIR=${BUILD_DIR:-$(pwd)/build-unified}

echo "Build Type: $BUILD_TYPE"
echo "Install Prefix: $INSTALL_PREFIX"
echo "Jobs: $JOBS"
echo "Build Directory: $BUILD_DIR"
echo ""

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Function to build component
build_component() {
    local component=$1
    local source_dir=$2
    
    echo "Building $component..."
    if [ ! -d "$source_dir" ]; then
        echo "Warning: $source_dir not found, skipping $component"
        return 0
    fi
    
    mkdir -p "$component"
    cd "$component"
    
    cmake "$source_dir" \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX"
    
    make -j"$JOBS"
    make install
    
    cd ..
    echo "$component built successfully!"
    echo ""
}

# Build in dependency order
echo "Starting build process..."
echo ""

# Core foundation
build_component "cogutil" "../orc-oc/cogutil"

# AtomSpace orchestration - all components in proper order
build_component "atomspace-orchestration" "../orc-as"

# URE (depends on atomspace)
build_component "ure" "../orc-ai/ure"

# Attention system
build_component "attention" "../orc-ct/attention"

# SpaceTime
build_component "spacetime" "../orc-ct/spacetime"

# CogServer
build_component "cogserver" "../orc-sv/cogserver"

# PLN
build_component "pln" "../orc-ai/pln"

# Pattern Miner
build_component "miner" "../orc-ai/miner"

# MOSES
build_component "moses" "../orc-ai/moses"

# AS-MOSES
build_component "asmoses" "../orc-ai/asmoses"

# Learning system (if exists)
if [ -d "../orc-ai/learn" ]; then
    build_component "learn" "../orc-ai/learn"
fi

# Main OpenCog
build_component "opencog" "../orc-oc/opencog"

# Additional components
build_component "unify" "../orc-ct/unify"
build_component "generate" "../orc-ct/generate"

# Optional components
if [ -d "../orc-ro/vision" ]; then
    build_component "vision" "../orc-ro/vision"
fi

if [ -d "../orc-bi/cheminformatics" ]; then
    build_component "cheminformatics" "../orc-bi/cheminformatics"
fi

if [ -d "../orc-nl/lg-atomese" ]; then
    build_component "lg-atomese" "../orc-nl/lg-atomese"
fi

if [ -d "../orc-ro/sensory" ]; then
    build_component "sensory" "../orc-ro/sensory"
fi

if [ -d "../orc-sv/agents" ]; then
    build_component "agents" "../orc-sv/agents"
fi

# Build unified main application
echo "Building unified OpenCog application..."
cd "$BUILD_DIR"
cmake .. \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX"

make -j"$JOBS"

echo ""
echo "=========================================="
echo "OpenCog Unified Framework Build Complete!"
echo "=========================================="
echo ""
echo "Installation directory: $INSTALL_PREFIX"
echo "Build directory: $BUILD_DIR"
echo ""
echo "To run the unified system:"
echo "export LD_LIBRARY_PATH=$INSTALL_PREFIX/lib:\$LD_LIBRARY_PATH"
echo "export PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig:\$PKG_CONFIG_PATH"
echo ""
echo "Then run: cogserver or other OpenCog binaries"
