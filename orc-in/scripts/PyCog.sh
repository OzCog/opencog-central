#!/bin/bash

# PyCog.sh
# Script to create/update Python packages for all repositories listed in repos_list.txt

set -euo pipefail  # Enable strict error handling

# Function to print informational messages
echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Function to print error messages
echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# Define directories
REPOS_LIST_FILE="repos_list.txt"
REPOS_DIR="repos"
PYTHON_PACKAGES_DIR="python_packages"

# Check if repos_list.txt exists
if [ ! -f "$REPOS_LIST_FILE" ]; then
    echo_error "repos_list.txt not found. Please run generate_repos_list.sh first."
    exit 1
fi

# Create python_packages directory if it doesn't exist
mkdir -p "$PYTHON_PACKAGES_DIR"

# Base URL for cloning (adjust if repositories are hosted elsewhere)
BASE_URL="https://github.com/Ozcog"

# Loop through each repository in repos_list.txt
while IFS= read -r repo; do
    # Skip empty lines or lines starting with #
    if [[ -z "$repo" || "$repo" == \#* ]]; then
        continue
    fi

    echo_info "Processing Python package for repository: $repo"

    REPO_DIR="$REPOS_DIR/$repo"
    PACKAGE_DIR="$PYTHON_PACKAGES_DIR/${repo}_py"

    # Check if the repository directory exists
    if [ ! -d "$REPO_DIR/.git" ]; then
        echo_info "Repository directory '$REPO_DIR' does not exist. Cloning repository..."
        git clone "$BASE_URL/$repo.git" "$REPO_DIR"
        if [ $? -ne 0 ]; then
            echo_error "Failed to clone repository '$repo'. Skipping."
            echo ""
            continue
        fi
        echo_info "Successfully cloned '$repo'."
    else
        echo_info "Repository '$repo' already exists. Skipping clone."
    fi

    # Create package directory
    mkdir -p "$PACKAGE_DIR"

    # Check for setup.py or pyproject.toml
    if [ -f "$REPO_DIR/setup.py" ] || [ -f "$REPO_DIR/pyproject.toml" ]; then
        echo_info "Found setup.py or pyproject.toml for $repo. Creating/updating Python package."
        
        # Assuming you want to copy the necessary files; adjust as needed
        cp "$REPO_DIR/setup.py" "$PACKAGE_DIR/" 2>/dev/null || echo_info "setup.py not found for $repo."
        cp "$REPO_DIR/pyproject.toml" "$PACKAGE_DIR/" 2>/dev/null || echo_info "pyproject.toml not found for $repo."
        
        # Additional processing steps can be added here
    else
        echo_error "Neither setup.py nor pyproject.toml found for '$repo'. Creating default setup.py."
        
        # Create a default setup.py
        cat <<EOL > "$PACKAGE_DIR/setup.py"
from setuptools import setup, find_packages

setup(
    name='$repo',
    version='0.1.0',
    packages=find_packages(),
    install_requires=[
        # Add your dependencies here
    ],
    author='Your Name',
    author_email='you@example.com',
    description='A Python package for $repo.',
    url='$BASE_URL/$repo',
    classifiers=[
        'Programming Language :: Python :: 3',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.6',
)
EOL

        # Create a default pyproject.toml
        cat <<EOL > "$PACKAGE_DIR/pyproject.toml"
[build-system]
requires = ["setuptools>=42", "wheel"]
build-backend = "setuptools.build_meta"
EOL

        echo_info "Default setup.py and pyproject.toml created for '$repo'. Please customize them as needed."
    fi

    echo ""
done < "$REPOS_LIST_FILE"

echo_info "All Python packages processed."
