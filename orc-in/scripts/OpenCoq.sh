#!/bin/bash

# OpenCoq.sh
# Script to create and update Coq proofs for OpenCog repositories.

set -e  # Exit on error

# Function to print informational messages
echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Function to print error messages
echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# Directory where Coq proofs will be stored
COQ_PROOFS_DIR="coq_proofs"

# Create the directory if it doesn't exist
mkdir -p "$COQ_PROOFS_DIR"

# Define repositories that should have Coq proofs
# Since we want all repositories, we can skip this filter or decide based on functionality
# For demonstration, assuming all repos need Coq proofs

# Check if repos_list.txt exists
if [ ! -f "repos_list.txt" ]; then
    echo_error "repos_list.txt not found. Please run generate_repos_list.sh first."
    exit 1
fi

# Loop through each repository in repos_list.txt
while IFS= read -r repo; do
    echo_info "Processing Coq proofs for repository: $repo"

    REPO_DIR="repos/$repo"
    PROOF_DIR="$COQ_PROOFS_DIR/${repo}_proofs"

    # Create proof directory
    mkdir -p "$PROOF_DIR"

    # Check if Makefile.coq exists
    if [ -f "$REPO_DIR/Makefile.coq" ]; then
        echo_info "Found Makefile.coq for $repo. Copying to Coq proofs."
    else
        echo_info "No Makefile.coq found for $repo. Creating Makefile.coq."

        # Create Makefile.coq with default/template content
        cat > "$REPO_DIR/Makefile.coq" <<EOL
# Makefile.coq for $repo

all: proof.v

proof.v: proof.
    coqc proof.v

clean:
    rm -f *.vo *.glob
EOL

        echo_info "Created Makefile.coq for $repo. Please customize it as needed."
    fi

    # Check if proof.v exists
    if [ -f "$REPO_DIR/proof.v" ]; then
        echo_info "Found proof.v for $repo. Copying to Coq proofs."
    else
        echo_info "No proof.v found for $repo. Creating proof.v."

        # Create proof.v with basic proof content
        cat > "$REPO_DIR/proof.v" <<EOL
(* proof.v for $repo *)

Theorem hello: True.
Proof.
    trivial.
Qed.
EOL

        echo_info "Created proof.v for $repo. Please implement actual proofs."
    fi

    # Copy Coq proof files to proof directory
    cp "$REPO_DIR/Makefile.coq" "$PROOF_DIR/"
    cp "$REPO_DIR/proof.v" "$PROOF_DIR/"

    cd "$PROOF_DIR"

    # Compile Coq proofs
    make -f Makefile.coq

    echo_info "Coq proofs for $repo created/updated successfully."

    echo ""
done < repos_list.txt

echo_info "All Coq proofs processed."
