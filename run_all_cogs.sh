#!/bin/bash

# run_all_cogs.sh
# Master script to generate repository list and run all Cog scripts in order.

set -e  # Exit on error

# Function to print informational messages
echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Directory where Cog scripts are stored
SCRIPTS_DIR="scripts"

# List of Cog scripts in the order they should be executed
declare -a script_order=("generate_repos_list.sh" "BuildCog.sh" "PyCog.sh" "JuliaCog.sh" "RustCog.sh" "TerraCog.sh" "OpenCoq.sh" "Kokkog.sh")

echo_info "Starting all Cog scripts..."

# Loop through each script and execute it
for script in "${script_order[@]}"; do
    SCRIPT_PATH="$SCRIPTS_DIR/$script"

    if [ -f "$SCRIPT_PATH" ]; then
        echo_info "Executing $script..."
        bash "$SCRIPT_PATH"
        echo_info "$script executed successfully."
        echo ""
    else
        echo_info "$script not found in $SCRIPTS_DIR. Skipping."
    fi
done

echo_info "All Cog scripts executed successfully."
