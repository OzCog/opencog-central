# AtomSpace Storage Backend

## Overview

The AtomSpace Storage Backend provides the core storage abstraction layer for the OpenCog AtomSpace. This component defines the base storage interfaces and types that are used by specific storage implementations like RocksDB, PostgreSQL, and other persistence backends.

## Purpose

This intermediate component separates the storage abstraction from the core AtomSpace, allowing for:

1. **Modular Storage Backends**: Clean separation between storage interface and implementation
2. **Dependency Optimization**: Reduced build dependencies for components that only need storage interfaces
3. **Better Testing**: Ability to test storage interfaces independently
4. **Flexible Architecture**: Easier to add new storage backends without affecting core AtomSpace

## Dependencies

- **CogUtil**: Foundation utilities (>= 2.0.2)  
- **AtomSpace**: Core knowledge representation (>= 5.0.3)

## What's Included

- Storage node type definitions
- Base storage interfaces
- Proxy node implementations for storage routing
- Common storage utilities

## Build Requirements

- CMake 3.0.2+
- C++14 compatible compiler
- Boost libraries
- Guile (for Scheme bindings)

## Building

```bash
mkdir build && cd build
cmake ..
make -j$(nproc)
```

## Testing

```bash
make test
```

## License

Licensed under the Apache License 2.0. See LICENSE file for details.