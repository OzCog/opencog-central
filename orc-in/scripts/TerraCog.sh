#!/bin/bash

# TerraCog.sh
# Script to create and update Terraform providers for OpenCog repositories.

set -e  # Exit on error

# Function to print informational messages
echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Function to print error messages
echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# Directory where Terraform providers will be stored
TERRAFORM_PROVIDERS_DIR="terraform_providers"

# Create the directory if it doesn't exist
mkdir -p "$TERRAFORM_PROVIDERS_DIR"

# Define repositories that should have Terraform providers
# Since we want all repositories, we can skip this filter or decide based on functionality
# For demonstration, assuming all repos need Terraform providers

# Check if repos_list.txt exists
if [ ! -f "repos_list.txt" ]; then
    echo_error "repos_list.txt not found. Please run generate_repos_list.sh first."
    exit 1
fi

# Loop through each repository in repos_list.txt
while IFS= read -r repo; do
    echo_info "Processing Terraform provider for repository: $repo"

    REPO_DIR="repos/$repo"
    PROVIDER_DIR="$TERRAFORM_PROVIDERS_DIR/${repo}_tf"

    # Create provider directory
    mkdir -p "$PROVIDER_DIR"

    # Check if main.tf exists
    if [ -f "$REPO_DIR/main.tf" ]; then
        echo_info "Found main.tf for $repo. Copying to Terraform provider."
    else
        echo_info "No main.tf found for $repo. Creating main.tf."

        # Create main.tf with default/template content
        cat > "$REPO_DIR/main.tf" <<EOL
provider "${repo}" {
  # Configuration options for ${repo} provider
}

resource "${repo}_resource" "example" {
  # Resource configuration
}
EOL

        echo_info "Created main.tf for $repo. Please customize it as needed."
    fi

    # Copy main.tf to provider directory
    cp "$REPO_DIR/main.tf" "$PROVIDER_DIR/"

    cd "$PROVIDER_DIR"

    # Initialize Terraform
    terraform init

    # Validate Terraform configuration
    terraform validate

    echo_info "Terraform provider for $repo created/updated successfully."

    echo ""
done < repos_list.txt

echo_info "All Terraform providers processed."
