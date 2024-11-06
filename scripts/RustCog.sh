#!/bin/bash

# RustCog.sh
# Script to create and update Rust Cargo crates for OpenCog repositories.

set -e  # Exit on error

# Function to print informational messages
echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Function to print error messages
echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# Directory where Rust crates will be stored
RUST_CRATES_DIR="rust_crates"

# Create the directory if it doesn't exist
mkdir -p "$RUST_CRATES_DIR"

# Define repositories that should have Rust Cargo crates
# Since we want all repositories, we can skip this filter or decide based on language
# For demonstration, assuming all repos need Rust crates

# Check if repos_list.txt exists
if [ ! -f "repos_list.txt" ]; then
    echo_error "repos_list.txt not found. Please run generate_repos_list.sh first."
    exit 1
fi

# Loop through each repository in repos_list.txt
while IFS= read -r repo; do
    echo_info "Processing Rust Cargo crate for repository: $repo"

    REPO_DIR="repos/$repo"
    CRATE_DIR="$RUST_CRATES_DIR/${repo}_rust"

    # Create crate directory
    mkdir -p "$CRATE_DIR"

    # Check if Cargo.toml exists
    if [ -f "$REPO_DIR/Cargo.toml" ]; then
        echo_info "Found Cargo.toml for $repo. Updating Rust Cargo crate."
    else
        echo_info "No Cargo.toml found for $repo. Creating Cargo.toml."

        # Create Cargo.toml with default/template content
        cat > "$REPO_DIR/Cargo.toml" <<EOL
[package]
name = "${repo}_rust"
version = "0.1.0"
authors = ["Your Name <you@example.com>"]
edition = "2021"

[dependencies]
# List your dependencies here

[lib]
name = "${repo}_rust"
crate-type = ["cdylib"]  # For dynamic linking with other languages
EOL

        echo_info "Created Cargo.toml for $repo. Please customize it as needed."
    fi

    # Copy repository contents to crate directory
    cp -R "$REPO_DIR"/* "$CRATE_DIR"/

    cd "$CRATE_DIR"

    # Initialize Rust crate if Cargo.toml was newly created
    if [ ! -f "src/lib.rs" ]; then
        mkdir -p src
        cat > src/lib.rs <<EOL
// lib.rs for ${repo}_rust

#[no_mangle]
pub extern "C" fn hello() {
    println!("Hello from ${repo}_rust!");
}
EOL
        echo_info "Created src/lib.rs for $repo. Please implement your Rust library functions."
    fi

    # Build the Rust crate
    cargo build --release

    echo_info "Rust Cargo crate for $repo built successfully."

    echo ""
done < repos_list.txt

echo_info "All Rust Cargo crates processed."
