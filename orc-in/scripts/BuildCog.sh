#!/bin/bash

# BuildCog.sh
# Script to create and update GitHub Actions workflows for building repositories.

set -e  # Exit on error

# Function to print informational messages
echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Function to print error messages
echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# Check if repos_list.txt exists
if [ ! -f "repos_list.txt" ]; then
    echo_error "repos_list.txt not found. Please run generate_repos_list.sh first."
    exit 1
fi

# Directory where GitHub Actions workflows are stored
WORKFLOW_DIR=".github/workflows"

# Ensure the workflow directory exists
mkdir -p "$WORKFLOW_DIR"

# Define the name of the workflow file
WORKFLOW_FILE="$WORKFLOW_DIR/build_repos.yml"

echo_info "Creating/Updating GitHub Actions workflow at $WORKFLOW_FILE"

# Start writing the workflow YAML
cat > "$WORKFLOW_FILE" <<EOL
name: Build OpenCog Central Repositories

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-24.04

    strategy:
      matrix:
        repo: [$(paste -sd, repos_list.txt)]

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up CMake
        uses: lukka/get-cmake@v3.26.4

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y build-essential python3 python3-venv

      - name: Build \${{ matrix.repo }}
        run: |
          mkdir -p build/\${{ matrix.repo }}
          cd build/\${{ matrix.repo }}
          cmake ../../repos/\${{ matrix.repo }} -DCMAKE_BUILD_TYPE=Release
          make -j\$(nproc)

      - name: Run tests for \${{ matrix.repo }}
        run: |
          cd build/\${{ matrix.repo }}
          ctest --output-on-failure
EOL

echo_info "GitHub Actions workflow created/updated successfully."
