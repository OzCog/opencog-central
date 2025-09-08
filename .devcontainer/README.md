# GNU Guix Shepherd DevContainer for OpenCog

This devcontainer provides a **GNU Guix Shepherd environment** for reproducible OpenCog development and packaging using only FSF-approved free software tools.

## Features

- **Debian Bookworm base** with GNU Guix package manager
- **GNU Shepherd** for service management and build automation
- **Guile Scheme** for packaging and scripting
- **OpenCog package definition** for reproducible builds
- **Automated services** for building, testing, and development

## Quick Start

1. **Open in DevContainer**: Open this repository in VS Code and select "Reopen in Container"

2. **Start Shepherd services**:
   ```bash
   # Copy Shepherd configuration
   cp /workspace/.devcontainer/init.scm ~/.config/shepherd/
   
   # Start Shepherd
   shepherd &
   
   # Start OpenCog build service
   herd start opencog-build
   ```

3. **Build OpenCog with Guix**:
   ```bash
   guix build /workspace/.devcontainer/opencog.scm
   ```

4. **Enter development environment**:
   ```bash
   guix environment --ad-hoc /workspace/.devcontainer/opencog.scm
   ```

## Shepherd Services

The container includes several pre-configured Shepherd services:

- `opencog-build`: Build OpenCog using Guix
- `opencog-test`: Run OpenCog tests in Guix environment  
- `opencog-env`: Set up OpenCog development environment
- `guix-pull`: Update Guix package definitions
- `guix-daemon`: Guix build daemon (if needed)

### Service Management

```bash
# List available services
herd status

# Start a service
herd start opencog-build

# Stop a service  
herd stop opencog-build

# View service logs
tail -f /tmp/opencog-build.log
```

## Guix Package Definition

The `opencog.scm` file defines the OpenCog package for Guix, including:

- Dependencies (Guile, Boost, Python, etc.)
- Build system configuration (CMake)
- License information (AGPL3+)
- Source location and version

## Why This Setup?

- **Portable**: Anyone can clone the repo and get a working Guix+Shepherd environment instantly
- **Reproducible**: Container and Guix manage all dependencies declaratively  
- **FSF-Sanctioned**: Pure free software stack (Debian/Guix, AGPL, GNU tools)
- **Scheme-Powered**: Shepherd enables scripting build/test servers as Scheme services
- **Extensible**: Easy to add new services and package variants

## Development Workflow

1. **Make changes** to OpenCog source code
2. **Rebuild** with `herd start opencog-build` 
3. **Test** with `herd start opencog-test`
4. **Package updates** by modifying `opencog.scm`
5. **Service automation** by extending `init.scm`

This turns your repo into a *mad scientist's Guix packaging lab* for reproducible cognitive architecture development!

## Extensions

The setup can be extended to:
- Create multiple package variants
- Generate system definitions  
- Build full GuixOS images
- Add CI/CD integration
- Support cross-compilation

## Troubleshooting

### Network Issues During Build

If you encounter network connectivity issues when building the container (e.g., unable to download the Guix installer), this is typically due to restricted network access in the build environment. In such cases:

1. **Use a pre-built container**: The devcontainer will work with any container that has Guix and Shepherd pre-installed
2. **Manual installation**: You can modify the Dockerfile to use package manager installation of Guix if available
3. **Alternative base images**: Consider using a base image that already includes GNU Guix

The core devcontainer configuration will work with any properly configured Guix environment.

## License

This devcontainer configuration is provided under the same license as OpenCog Central (AGPL3+).