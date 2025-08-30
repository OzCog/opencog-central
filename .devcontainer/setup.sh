#!/bin/bash
# OpenCog Guix Shepherd DevContainer Setup Script
# This script helps initialize the Guix Shepherd environment

set -e

echo "🧠 OpenCog Guix Shepherd DevContainer Setup"
echo "==========================================="

# Function to print colored output
print_step() {
    echo -e "\n🔧 $1"
}

print_success() {
    echo -e "✅ $1"
}

print_step "Setting up Shepherd configuration..."
mkdir -p ~/.config/shepherd
cp /workspace/.devcontainer/init.scm ~/.config/shepherd/
print_success "Shepherd configuration copied"

print_step "Starting Shepherd daemon..."
# Start shepherd in background if not already running
if ! pgrep -f "shepherd" > /dev/null; then
    shepherd &
    sleep 2
    print_success "Shepherd daemon started"
else
    print_success "Shepherd daemon already running"
fi

print_step "Updating Guix package definitions..."
guix pull || echo "⚠️  Guix pull failed, continuing..."

print_step "Available Shepherd services:"
echo "  • opencog-build   - Build OpenCog with Guix"
echo "  • opencog-test    - Run OpenCog tests"  
echo "  • opencog-env     - Development environment"
echo "  • guix-pull       - Update package definitions"

echo ""
echo "🎉 DevContainer setup complete!"
echo ""
echo "Quick commands:"
echo "  herd status                    # List services"
echo "  herd start opencog-build      # Build OpenCog"
echo "  herd start opencog-test       # Run tests"
echo "  guix build /workspace/.devcontainer/opencog.scm  # Manual build"
echo ""
echo "Happy coding! 🚀"