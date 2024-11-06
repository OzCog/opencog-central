#!/bin/bash

# clone_repos.sh
# Script to clone multiple repositories into the repos/ directory.

set -e  # Exit on error

# Define the base GitHub URL
BASE_URL="https://github.com/OpenCog"

# Ensure the repos directory exists
mkdir -p repos

# Read repository names from all_repos.txt and clone them
while IFS= read -r repo; do
    if [ -d "repos/$repo" ]; then
        echo "[INFO] Repository '$repo' already exists. Skipping."
    else
        echo "[INFO] Cloning repository '$repo'..."
        git clone "$BASE_URL/$repo.git" "repos/$repo"
        echo "[INFO] Cloned '$repo' successfully."
    fi
done < all_repos.txt

echo "[INFO] All repositories cloned successfully."
