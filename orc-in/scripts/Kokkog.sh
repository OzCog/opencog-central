#!/bin/bash

# Kokkog.sh
# Script to create and update Kokkos integrations for OpenCog repositories.

set -e  # Exit on error

# Function to print informational messages
echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Function to print error messages
echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# Directory where Kokkos integrations will be stored
KOKKOS_INTEGRATIONS_DIR="kokkos_integrations"

# Create the directory if it doesn't exist
mkdir -p "$KOKKOS_INTEGRATIONS_DIR"

# Define repositories that should have Kokkos integrations
# Since we want all repositories, we can skip this filter or decide based on functionality
# For demonstration, assuming all repos need Kokkos integrations

# Check if repos_list.txt exists
if [ ! -f "repos_list.txt" ]; then
    echo_error "repos_list.txt not found. Please run generate_repos_list.sh first."
    exit 1
fi

# Loop through each repository in repos_list.txt
while IFS= read -r repo; do
    echo_info "Processing Kokkos integration for repository: $repo"

    REPO_DIR="repos/$repo"
    INTEGRATION_DIR="$KOKKOS_INTEGRATIONS_DIR/${repo}_kokkos"

    # Create integration directory
    mkdir -p "$INTEGRATION_DIR"

    # Check if CMakeLists.txt exists
    if [ -f "$REPO_DIR/CMakeLists.txt" ]; then
        echo_info "Found CMakeLists.txt for $repo. Copying to Kokkos integration."
    else
        echo_info "No CMakeLists.txt found for $repo. Creating CMakeLists.txt."

        # Create CMakeLists.txt with default/template content
        cat > "$REPO_DIR/CMakeLists.txt" <<EOL
cmake_minimum_required(VERSION 3.15)
project(${repo}_kokkos)

# Find Kokkos
find_package(Kokkos REQUIRED)

# Add source files
add_library(${repo}_kokkos SHARED src/${repo}.cpp)

# Link Kokkos
target_link_libraries(${repo}_kokkos PRIVATE Kokkos::kokkos)

# Specify C++ standard
set_target_properties(${repo}_kokkos PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED YES)
EOL

        echo_info "Created CMakeLists.txt for $repo. Please customize it as needed."
    fi

    # Check if src/${repo}.cpp exists
    if [ -f "$REPO_DIR/src/${repo}.cpp" ]; then
        echo_info "Found src/${repo}.cpp for $repo. Copying to Kokkos integration."
    else
        echo_info "No src/${repo}.cpp found for $repo. Creating src/${repo}.cpp."

        # Create src directory and src/${repo}.cpp with basic content
        mkdir -p "$REPO_DIR/src"
        cat > "$REPO_DIR/src/${repo}.cpp" <<EOL
// ${repo}.cpp for Kokkos integration

#include <Kokkos_Core.hpp>

extern "C" void initialize_kokkos() {
    Kokkos::initialize();
}

extern "C" void finalize_kokkos() {
    Kokkos::finalize();
}

extern "C" void kokkos_hello() {
    Kokkos::parallel_for("HelloKokkos", 1, KOKKOS_LAMBDA(const int i) {
        printf("Hello from Kokkos in ${repo}!\n");
    });
}
EOL

        echo_info "Created src/${repo}.cpp for $repo. Please implement actual Kokkos functions."
    fi

    # Copy CMakeLists.txt and src/${repo}.cpp to integration directory
    cp "$REPO_DIR/CMakeLists.txt" "$INTEGRATION_DIR/"
    cp "$REPO_DIR/src/${repo}.cpp" "$INTEGRATION_DIR/src/"

    cd "$INTEGRATION_DIR"

    # Build the Kokkos integration
    mkdir -p build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j$(nproc)

    echo_info "Kokkos integration for $repo created/updated successfully."

    echo ""
done < repos_list.txt

echo_info "All Kokkos integrations processed."
