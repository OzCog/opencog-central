#!/bin/bash

# generate_repos_list.sh
# Script to generate a list of repositories in the repos/ directory.

set -e  # Exit immediately if a command exits with a non-zero status.

# Define the directory containing the repositories
REPOS_DIR="repos"

# Define the output file
OUTPUT_FILE="repos_list.txt"

# Check if the repos directory exists
if [ ! -d "$REPOS_DIR" ]; then
    echo "[ERROR] Repositories directory '$REPOS_DIR' does not exist."
    exit 1
fi

# Generate the list of repositories (directories only)
ls -1 "$REPOS_DIR" > "$OUTPUT_FILE"

echo "[INFO] Generated repository list in '$OUTPUT_FILE'."
