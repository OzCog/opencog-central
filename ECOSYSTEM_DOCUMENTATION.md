# OpenCog Ecosystem Documentation

This document provides a comprehensive overview of the OpenCog ecosystem, its components, architecture, and build system.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Component Directory](#component-directory)
4. [Build System](#build-system)
5. [Dependencies](#dependencies)
6. [Development Workflow](#development-workflow)
7. [Testing Strategy](#testing-strategy)
8. [Deployment](#deployment)
9. [Troubleshooting](#troubleshooting)
10. [Contributing](#contributing)

## Overview

OpenCog is a comprehensive cognitive architecture designed to create artificial general intelligence (AGI). The ecosystem consists of multiple interconnected components that work together to provide knowledge representation, reasoning, learning, and natural language processing capabilities.

### Core Principles

- **Knowledge Representation**: Unified hypergraph-based representation (AtomSpace)
- **Cognitive Reasoning**: Multiple reasoning engines for different types of inference
- **Learning and Evolution**: Adaptive algorithms for continuous improvement
- **Language Processing**: Natural language understanding and generation
- **Distributed Architecture**: Scalable, networked cognitive systems

## Architecture

The OpenCog ecosystem follows a layered architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   OpenCog   │  │   Agents    │  │   User Interfaces   │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                  Cognitive Systems Layer                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │     PLN     │  │   Attention │  │      Miner          │ │
│  │   (Logic)   │  │ (Focus Mgmt)│  │  (Patterns)         │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                   Language Layer                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ LG-AtomESE  │  │    Learn    │  │ Language-Learning   │ │
│  │  (Grammar)  │  │ (Acquisition)│  │    (Pipeline)       │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                   Learning Layer                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │    MOSES     │  │   AS-MOSES  │  │     SpaceTime       │ │
│  │ (Evolution)  │  │ (AS-Evolve) │  │  (Spatio-Temp)      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                    Logic Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │    Unify    │  │     URE     │  │    CogServer        │ │
│  │ (Matching)  │  │ (Rule Eng.) │  │   (Networking)      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                     Core Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  AtomSpace  │  │ AS-Rocks    │  │   AS-RESTful        │ │
│  │   (Core)    │  │(Persistence)│  │     (API)           │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                  Foundation Layer                          │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    CogUtil                              │ │
│  │        (Utilities, Data Structures, Threading)         │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Component Directory

### Foundation Layer

#### CogUtil
- **Purpose**: Core utilities and foundation library
- **Key Features**: 
  - Thread-safe data structures
  - Memory management utilities
  - Configuration system
  - Logging framework
- **Dependencies**: None (system libraries only)
- **Repository**: `cogutil`
- **Language**: C++

### Core Layer

#### AtomSpace
- **Purpose**: Central knowledge representation system
- **Key Features**:
  - Hypergraph-based knowledge storage
  - Type system for semantic structures
  - Query and pattern matching
  - Event notification system
- **Dependencies**: CogUtil
- **Repository**: `atomspace`
- **Language**: C++, Scheme, Python

#### AtomSpace-Rocks
- **Purpose**: RocksDB-based persistence for AtomSpace
- **Key Features**:
  - High-performance disk storage
  - ACID transactions
  - Backup and recovery
  - Distributed storage capabilities
- **Dependencies**: CogUtil, AtomSpace
- **Repository**: `atomspace-rocks`
- **Language**: C++

#### AtomSpace-RESTful
- **Purpose**: HTTP API for AtomSpace access
- **Key Features**:
  - RESTful web service
  - JSON serialization
  - Authentication and authorization
  - WebSocket support
- **Dependencies**: CogUtil, AtomSpace
- **Repository**: `atomspace-restful`
- **Language**: C++, JavaScript

### Logic Layer

#### Unify
- **Purpose**: Unification algorithms for pattern matching
- **Key Features**:
  - Variable binding and substitution
  - Pattern matching algorithms
  - Type constraint handling
  - Integration with AtomSpace queries
- **Dependencies**: CogUtil, AtomSpace
- **Repository**: `unify`
- **Language**: C++

#### URE (Unified Rule Engine)
- **Purpose**: Forward and backward chaining inference engine
- **Key Features**:
  - Rule-based reasoning
  - Probabilistic inference
  - Goal-directed search
  - Meta-reasoning capabilities
- **Dependencies**: CogUtil, AtomSpace, Unify
- **Repository**: `ure`
- **Language**: C++, Scheme

#### CogServer
- **Purpose**: Network server for distributed cognition
- **Key Features**:
  - Multi-client networking
  - Command-line interface
  - Module loading system
  - Remote AtomSpace access
- **Dependencies**: CogUtil, AtomSpace
- **Repository**: `cogserver`
- **Language**: C++

### Cognitive Systems Layer

#### Attention
- **Purpose**: Attention allocation and focus management
- **Key Features**:
  - Attention value propagation
  - Focus of attention management
  - Forgetting mechanisms
  - Economic attention allocation
- **Dependencies**: CogUtil, AtomSpace, CogServer
- **Repository**: `attention`
- **Language**: C++

#### SpaceTime
- **Purpose**: Spatiotemporal reasoning capabilities
- **Key Features**:
  - Temporal logic reasoning
  - Spatial relationship modeling
  - Event sequence analysis
  - Causal relationship inference
- **Dependencies**: CogUtil, AtomSpace
- **Repository**: `spacetime`
- **Language**: C++

### Advanced Systems Layer

#### PLN (Probabilistic Logic Networks)
- **Purpose**: Uncertain reasoning with probabilistic logic
- **Key Features**:
  - Probabilistic inference rules
  - Uncertainty quantification
  - Belief revision mechanisms
  - Integration with URE
- **Dependencies**: CogUtil, AtomSpace, Unify, URE, SpaceTime
- **Repository**: `pln`
- **Language**: C++, Scheme

#### Miner
- **Purpose**: Pattern mining and discovery algorithms
- **Key Features**:
  - Frequent pattern mining
  - Surprise pattern detection
  - Feature selection algorithms
  - Statistical analysis tools
- **Dependencies**: CogUtil, AtomSpace, Unify, URE
- **Repository**: `miner`
- **Language**: C++

### Learning Systems Layer

#### MOSES
- **Purpose**: Meta-Optimizing Semantic Evolutionary Search
- **Key Features**:
  - Evolutionary program synthesis
  - Feature selection
  - Model optimization
  - Genetic programming
- **Dependencies**: CogUtil
- **Repository**: `moses`
- **Language**: C++

#### AS-MOSES
- **Purpose**: AtomSpace integration for MOSES
- **Key Features**:
  - AtomSpace-based program representation
  - Evolutionary reasoning
  - Cognitive program synthesis
  - Integration with other cognitive systems
- **Dependencies**: CogUtil, AtomSpace, Unify, URE
- **Repository**: `asmoses`
- **Language**: C++

### Language Processing Layer

#### LG-AtomESE
- **Purpose**: Link Grammar parser integration
- **Key Features**:
  - Natural language parsing
  - Grammatical relationship extraction
  - AtomSpace integration
  - Multi-language support
- **Dependencies**: CogUtil, AtomSpace
- **Repository**: `lg-atomese`
- **Language**: C++

#### Learn
- **Purpose**: Language learning and acquisition
- **Key Features**:
  - Unsupervised grammar induction
  - Statistical language learning
  - Pattern discovery in text
  - Language model construction
- **Dependencies**: CogUtil, AtomSpace, CogServer
- **Repository**: `learn`
- **Language**: C++, Python

#### Language-Learning
- **Purpose**: Complete NLP processing pipeline
- **Key Features**:
  - Text preprocessing
  - Morphological analysis
  - Syntactic parsing
  - Semantic analysis
- **Dependencies**: CogUtil
- **Repository**: `language-learning`
- **Language**: Python, C++

### Integration Layer

#### OpenCog
- **Purpose**: Main framework integrating all components
- **Key Features**:
  - Component coordination
  - Unified API
  - Configuration management
  - System orchestration
- **Dependencies**: CogUtil, AtomSpace, CogServer, Attention, Unify, URE, LG-AtomESE
- **Repository**: `opencog`
- **Language**: C++, Scheme, Python

## Build System

### Overview

The OpenCog ecosystem uses a sophisticated multi-layer build system:

1. **CMake**: Primary build system for C++ components
2. **CircleCI**: Continuous integration and deployment
3. **Docker**: Containerized builds and deployments
4. **Workspace Persistence**: Artifact sharing between build stages

### Build Configuration

The consolidated CircleCI configuration (`/.circleci/config.yml`) orchestrates the entire ecosystem build:

- **18 components** built in dependency order
- **Parallel execution** where possible
- **Workspace persistence** for artifact sharing
- **Comprehensive testing** at each stage
- **Packaging and deployment** automation

### Build Optimization Features

- **Compiler Cache (ccache)**: Speeds up rebuilds
- **Parallel Builds**: `-j2` compilation across components  
- **Docker Layer Caching**: Reuses common base images
- **Incremental Testing**: Only tests affected components
- **Artifact Persistence**: Shares build outputs between stages

## Dependencies

### Dependency Graph

The ecosystem follows a strict dependency hierarchy to ensure proper build order and runtime compatibility. See [DEPENDENCY_DIAGRAM.md](DEPENDENCY_DIAGRAM.md) for the complete visual representation.

### Critical Dependencies

1. **CogUtil → Everything**: Foundation library required by all components
2. **AtomSpace → Most Components**: Core knowledge representation
3. **Unify → URE**: Required for rule engine functionality
4. **URE → Advanced Systems**: Required for reasoning components
5. **Multiple → OpenCog**: Integration point for the entire system

### External Dependencies

Each component may have additional external dependencies:

- **System Libraries**: Standard C++ libraries, boost, etc.
- **Database Systems**: RocksDB, PostgreSQL for persistence
- **Language Runtimes**: Guile Scheme, Python for scripting
- **Network Libraries**: Networking and HTTP support
- **Math Libraries**: Linear algebra and statistical computing

## Development Workflow

### Getting Started

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/opencog/opencog-central
   cd opencog-central
   ```

2. **Choose Your Development Approach**:
   - **Full Build**: Use `build-all.sh` for complete ecosystem
   - **Component Build**: Use individual component builds
   - **Orchestrated Build**: Use `orc-as/` or `orc-oc/` for subsystems

3. **Set Up Environment**:
   ```bash
   # Install dependencies (Ubuntu/Debian)
   sudo apt-get update
   sudo apt-get install build-essential cmake git
   
   # Set build preferences
   export BUILD_TYPE=Release
   export JOBS=$(nproc)
   ```

### Development Process

1. **Create Feature Branch**:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make Changes**:
   - Follow component-specific coding standards
   - Add tests for new functionality
   - Update documentation as needed

3. **Test Locally**:
   ```bash
   # Build affected components
   cd component-directory
   mkdir build && cd build
   cmake .. && make -j$(nproc)
   make test
   ```

4. **Integration Testing**:
   ```bash
   # Test with dependent components
   ./build-all.sh  # Or use orchestrated builds
   ```

5. **Submit Changes**:
   ```bash
   git add .
   git commit -m "Add new feature"
   git push origin feature/my-new-feature
   # Create pull request
   ```

### Code Standards

- **C++**: Follow C++17 best practices
- **Indentation**: 4 spaces, no tabs
- **Naming**: CamelCase for classes, snake_case for functions
- **Documentation**: Doxygen comments for public APIs
- **Testing**: Unit tests required for new functionality

## Testing Strategy

### Test Levels

1. **Unit Tests**: Component-level functionality testing
2. **Integration Tests**: Cross-component interaction testing
3. **System Tests**: Full ecosystem functionality testing
4. **Performance Tests**: Benchmarking and optimization testing

### Test Execution

- **Automated Testing**: All tests run in CI pipeline
- **Parallel Execution**: Tests run concurrently where possible
- **Coverage Tracking**: Code coverage monitoring and reporting
- **Regression Testing**: Automated detection of functionality regressions

### Test Organization

```
component/
├── tests/
│   ├── unit/           # Component unit tests
│   ├── integration/    # Integration tests
│   └── data/          # Test data and fixtures
├── benchmarks/        # Performance benchmarks
└── examples/          # Usage examples and demos
```

## Deployment

### Deployment Targets

1. **Development**: Local development environments
2. **Testing**: CI/CD test environments  
3. **Staging**: Pre-production validation
4. **Production**: Live deployment environments

### Deployment Methods

1. **Source Build**: Build from source code
2. **Binary Packages**: Debian/RPM packages
3. **Container Deployment**: Docker containers
4. **Cloud Deployment**: Kubernetes orchestration

### Package Management

- **Debian Packages**: `.deb` files for Ubuntu/Debian
- **Docker Images**: Multi-stage optimized containers
- **Dependency Management**: Automatic dependency resolution
- **Version Management**: Semantic versioning and compatibility

## Troubleshooting

### Common Issues

#### Build Failures

**Dependency Issues**:
```bash
# Ensure all dependencies are installed
sudo apt-get install [missing-dependencies]

# Check dependency versions
cmake --version  # Should be >= 3.16
gcc --version    # Should support C++17
```

**Memory Issues**:
```bash
# Reduce parallel build jobs
export JOBS=1
make -j1

# Increase swap space if needed
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### Runtime Issues

**Library Loading**:
```bash
# Update library paths
sudo ldconfig

# Check library dependencies
ldd /path/to/executable

# Set environment variables
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

**Configuration Issues**:
```bash
# Check configuration files
cat ~/.opencog/opencog.conf

# Verify environment variables
env | grep OPENCOG
```

### Debug Builds

```bash
# Build with debug information
mkdir debug-build && cd debug-build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j$(nproc)

# Run with debugger
gdb ./your-program
```

### Log Analysis

```bash
# Enable verbose logging
export OPENCOG_LOG_LEVEL=DEBUG

# Monitor log files
tail -f /tmp/opencog.log

# Filter specific components
grep "AtomSpace" /tmp/opencog.log
```

## Contributing

### How to Contribute

1. **Report Issues**: Use GitHub issues for bug reports and feature requests
2. **Submit Patches**: Create pull requests with your improvements
3. **Improve Documentation**: Help update and expand documentation
4. **Write Tests**: Add test coverage for existing functionality
5. **Review Code**: Participate in code review process

### Contribution Guidelines

- **Code Quality**: Follow established coding standards
- **Testing**: Include tests with all functional changes
- **Documentation**: Update relevant documentation
- **Compatibility**: Maintain backward compatibility where possible
- **Performance**: Consider performance implications of changes

### Community Resources

- **Mailing Lists**: opencog@googlegroups.com
- **IRC**: #opencog on Libera.Chat
- **Forums**: OpenCog community forums
- **Wiki**: https://wiki.opencog.org
- **GitHub**: https://github.com/opencog

### Development Resources

- **API Documentation**: Generated from source code
- **Architecture Guides**: High-level system documentation
- **Tutorials**: Step-by-step learning materials
- **Examples**: Sample code and use cases
- **Best Practices**: Coding and design guidelines

---

For more detailed information about specific components, refer to their individual README files and documentation.