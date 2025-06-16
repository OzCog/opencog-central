# AtomSpace Orchestration (orc-as)

[![CircleCI](https://circleci.com/gh/opencog/opencog-central.svg?style=svg)](https://circleci.com/gh/opencog/opencog-central)

This directory contains the complete orchestration of all AtomSpace components,
providing a unified build system and workflow for the entire AtomSpace ecosystem.

## Overview

The AtomSpace Orchestration consolidates all AtomSpace-related components into
a single, well-organized structure with proper dependency management and 
build ordering. This ensures reliable, reproducible builds and installations
across all AtomSpace modules.

## Components

The orchestration includes the following components, built in dependency order:

### Core Foundation
- **atomspace** - The core AtomSpace framework and knowledge representation system

### Storage Backends  
- **atomspace-rocks** - RocksDB persistent storage backend
- **atomspace-bridge** - SQL database bridge for PostgreSQL/MySQL integration

### Network Interfaces
- **atomspace-cog** - Network-distributed AtomSpace storage and synchronization
- **atomspace-restful** - REST API interface for HTTP-based access
- **atomspace-rpc** - Remote Procedure Call interface
- **atomspace-websockets** - WebSocket interface for real-time communication

### Agent Systems
- **atomspace-agents** - Intelligent agent framework built on AtomSpace

### Distributed and Advanced Storage
- **atomspace-dht** - Distributed Hash Table for decentralized storage
- **atomspace-ipfs** - IPFS (InterPlanetary File System) integration

### Language and Platform Integration
- **atomspace-metta** - MeTTa language integration
- **atomspace-js** - JavaScript bindings and interfaces
- **atomspace-typescript** - TypeScript bindings and type definitions

### Tools and Utilities
- **atomspace-explorer** - Web-based exploration and visualization tools

## Building

### Prerequisites

Before building, ensure you have the following dependencies installed:

- CMake 3.16 or higher
- C++17 compatible compiler (GCC 7+, Clang 5+)
- Boost libraries (1.71 or higher)
- CogUtil library
- Additional dependencies as required by individual components

### Quick Build

To build all components in the correct dependency order:

```bash
mkdir build
cd build
cmake ..
make -j$(nproc)
make install
```

### Individual Component Building

Each component can also be built individually if needed:

```bash
cd atomspace
mkdir build && cd build
cmake .. && make -j$(nproc) && make install
```

### Build Options

Common CMake options:

```bash
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_PREFIX_PATH=/usr/local
```

## Installation Order

The components are installed in the following order to ensure proper dependency resolution:

1. atomspace (core)
2. atomspace-rocks, atomspace-bridge (storage backends)
3. atomspace-cog, atomspace-restful, atomspace-rpc, atomspace-websockets (interfaces)
4. atomspace-agents (agent systems)
5. atomspace-dht, atomspace-ipfs (distributed storage)
6. atomspace-metta (language integration)
7. atomspace-explorer, atomspace-js, atomspace-typescript (tools and bindings)

## Testing

To run tests for all components:

```bash
cd build
make test
```

Individual component tests can be run from their respective build directories.

## CircleCI Integration

The orchestration includes a comprehensive CircleCI configuration that:

- Builds components in proper dependency order
- Runs all tests
- Manages caching for faster builds
- Provides parallel build stages where possible

## Docker Support

Docker configurations from individual components are preserved and can be used
for containerized deployments. See individual component README files for
Docker-specific instructions.

## Documentation

Each component maintains its own documentation in its respective directory.
Key documentation locations:

- **atomspace/README.md** - Core AtomSpace documentation
- **atomspace-rocks/README.md** - RocksDB storage documentation
- **atomspace-restful/README.md** - REST API documentation
- And so on for each component...

## Development Workflow

### Adding New Components

1. Place the component directory in orc-as/
2. Update the main CMakeLists.txt to include the component
3. Add appropriate build stage to .circleci/config.yml
4. Update this README.md

### Dependency Management

The build system automatically handles dependencies between components.
If you need to modify dependency order:

1. Update the ADD_SUBDIRECTORY() order in CMakeLists.txt
2. Update the CircleCI workflow dependencies
3. Test the build order thoroughly

## Troubleshooting

### Common Issues

1. **Missing dependencies**: Ensure CogUtil and other prerequisites are installed
2. **Build order problems**: Use the main CMakeLists.txt rather than building components individually
3. **Version conflicts**: Ensure all components are from compatible versions

### Getting Help

- Check individual component README files for specific issues
- Review build logs for detailed error messages
- Consult the main AtomSpace documentation

## Contributing

When contributing to any component:

1. Ensure your changes don't break the orchestrated build
2. Update documentation as needed
3. Run the full test suite
4. Consider the impact on dependent components

## License

Each component maintains its own license. See individual component directories
for specific license information. Most components use the Apache 2.0 license.

## Related Projects

- [OpenCog Framework](https://github.com/opencog/opencog)
- [CogUtil](https://github.com/opencog/cogutil) 
- [URE (Unified Rule Engine)](https://github.com/opencog/ure)
- [PLN (Probabilistic Logic Networks)](https://github.com/opencog/pln)

---

For more detailed information about individual components, please refer to their
respective README files in their subdirectories.