#!/bin/bash

# JuliaCog.sh
# Script to create and update Julia packages for OpenCog repositories.

set -e  # Exit on error

# Function to print informational messages
echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Function to print error messages
echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# Directory where Julia packages will be stored
JULIA_PACKAGES_DIR="julia_packages"

# Create the directory if it doesn't exist
mkdir -p "$JULIA_PACKAGES_DIR"

# Define repositories that should have Julia packages
# Since we want all repositories, we can skip this filter or decide based on language
# For demonstration, assuming all repos need Julia packages

# Check if repos_list.txt exists
if [ ! -f "repos_list.txt" ]; then
    echo_error "repos_list.txt not found. Please run generate_repos_list.sh first."
    exit 1
fi

# Loop through each repository in repos_list.txt
while IFS= read -r repo; do
    echo_info "Processing Julia package for repository: $repo"

    REPO_DIR="repos/$repo"
    PACKAGE_DIR="$JULIA_PACKAGES_DIR/${repo}_jl"

    # Create package directory
    mkdir -p "$PACKAGE_DIR"

    # Check if Project.toml exists
    if [ -f "$REPO_DIR/Project.toml" ] || [ -f "$REPO_DIR/pyproject.toml" ]; then
        echo_info "Found Project.toml or pyproject.toml for $repo. Creating/updating Julia package."
    else
        echo_info "No Project.toml or pyproject.toml found for $repo. Creating Project.toml."

        # Create Project.toml with default/template content
        cat > "$REPO_DIR/Project.toml" <<EOL
name = "${repo}_jl"
uuid = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"  # Generate a unique UUID
authors = ["Your Name <you@example.com>"]
version = "0.1.0"

[deps]
CxxWrap = "1c8e82f5-b9be-5285-83f2-fd8f2bafaa15"
CxxWrap.Cxx = "b16e3e95-5700-5e0a-9f74-744f13eb832a"
CMake = "20f8f3ca-fd8b-5c7a-9561-6f7a1b3a7d0c"

[compat]
julia = "1.6"
EOL

        # Optionally, generate a unique UUID using Julia
        # Navigate to the repository and run Julia to generate UUID
        julia -e 'using UUIDs; println(UUIDs.uuid4())' > temp_uuid.txt
        UUID=$(cat temp_uuid.txt)
        sed -i "s/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/$UUID/" "$REPO_DIR/Project.toml"
        rm temp_uuid.txt

        echo_info "Created Project.toml for $repo. Please customize it as needed."
    fi

    # Initialize Julia package
    julia -e "using Pkg; Pkg.generate(\"${repo}_jl\", \"Package\")" --project="$PACKAGE_DIR"

    # Navigate into the Julia package
    cd "$PACKAGE_DIR/${repo}_jl"

    # Add dependencies (already added in Project.toml, but ensure installation)
    julia -e "using Pkg; Pkg.instantiate()"

    # Create build.jl
    cat > build.jl <<EOL
using CxxWrap, CxxWrap.Cxx, CMake

# Include the C++ header
@cxxinclude "../../repos/$repo/include/$repo.h"

# Link to the C++ library
push!(CxxWrap.LINK_ARGS, "-L../../repos/$repo/build -l$repo")

# Initialize CxxWrap
CxxWrap.init()
EOL

    # Create src/Module.jl
    mkdir -p src
    cat > src/Module.jl <<EOL
module ${repo}_jl

using CxxWrap

# Load the C++ library
CxxWrap.init()

# Define a type for the repository pointer
@cxx constant ${repo}Ptr = CxxVoidPtr

# Bind the create function
@cxx void create_${repo}()

# Bind the destroy function
@cxx void destroy_${repo}(Ptr{Cxx.Void})

# Julia function to create the repository component
function create()
    create_${repo}()
    return ${repo}Ptr()
end

# Julia function to destroy the repository component
function destroy(repo_ptr::${repo}Ptr)
    destroy_${repo}(repo_ptr)
end

end # module
EOL

    # Build the Julia package
    julia -e "using Pkg; Pkg.build()" --project="$PACKAGE_DIR"

    echo_info "Julia package for $repo created/updated successfully."

    echo ""
done < repos_list.txt

echo_info "All Julia packages processed."
