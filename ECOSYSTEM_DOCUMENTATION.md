# OpenCog Ecosystem Documentation
## Complete Guide to the OpenCog Central Repository

### Overview
The OpenCog ecosystem is a comprehensive artificial general intelligence (AGI) framework consisting of 42 interconnected components. This documentation provides a complete guide to understanding, building, and deploying the entire ecosystem based on actual CMakeLists.txt dependency analysis.

### Repository Structure
```
opencog-central/
├── orc-in/copied-cmake/          # Source CMakeLists.txt files (42 components)
├── cmakelists/                   # Organized CMakeLists with prefixes
├── .circleci/config.yml          # CI/CD pipeline configuration
├── BUILD_ORDER_PLAN.md           # Detailed build sequence (42 components)
├── DEPENDENCY_DIAGRAM.md         # Visual dependency relationships
├── CIRCLECI_CMAKELISTS_COMPARISON.md  # CI/CMake analysis comparison
└── ECOSYSTEM_DOCUMENTATION.md    # This comprehensive guide
```

### Component Categories

#### 🏗️ Foundation Layer (7 components)
**Purpose**: Basic infrastructure and utilities with minimal dependencies
- **cogutil**: Core utilities and foundation classes (Boost only)
- **moses**: Meta-Optimizing Semantic Evolutionary Search (CogUtil + Boost)
- **blender_api_msgs**: 3D visualization integration (Boost only)
- **perception**: Basic perception frameworks (Boost only)
- **ghost_bridge**: Component bridge utilities (Boost only)
- **pau2motors**: Motor control interfaces (Boost only)
- **robots_config**: Robot configuration management (no dependencies)

#### 🧠 Core Knowledge Layer (1 component)
**Purpose**: Central knowledge representation system
- **atomspace**: Core hypergraph knowledge representation (CogUtil + Boost)

#### 🔗 AtomSpace Extensions (25 components)
**Purpose**: Extend and enhance AtomSpace functionality

**Logic & Reasoning:**
- **unify**: Unification algorithms for pattern matching (CogUtil + AtomSpace + Boost)
- **ure**: Unified Rule Engine for inference (CogUtil + AtomSpace + Boost)

**Network & Server:**
- **cogserver**: Network server for distributed cognition (CogUtil + AtomSpace + Boost)
- **attention**: Attention allocation and focus management (CogUtil + AtomSpace + Boost)

**Spatiotemporal:**
- **spacetime**: Spatiotemporal reasoning capabilities (CogUtil + AtomSpace + Boost)

**Language Processing:**
- **lg-atomese**: Link Grammar parser integration (CogUtil + AtomSpace)
- **learn**: Language learning and acquisition systems (CogUtil + AtomSpace)
- **generate**: Natural language generation (CogUtil + AtomSpace)

**Domain-Specific:**
- **vision**: Computer vision and image processing (CogUtil + AtomSpace)
- **cheminformatics**: Chemical informatics and molecular analysis (CogUtil + AtomSpace)
- **sensory**: Multi-modal sensory processing (CogUtil + AtomSpace)
- **agi-bio**: AGI applications in biology (CogUtil + AtomSpace)

**Persistence & APIs:**
- **atomspace-rocks**: RocksDB persistence backend (CogUtil + AtomSpace)
- **atomspace-restful**: RESTful HTTP API (CogUtil + AtomSpace + Boost)
- **atomspace-dht**: Distributed Hash Table persistence (CogUtil + AtomSpace)
- **atomspace-ipfs**: IPFS distributed storage integration (CogUtil + AtomSpace)
- **atomspace-websockets**: WebSocket real-time API (CogUtil + AtomSpace + Boost)
- **atomspace-metta**: MeTTa language integration (CogUtil + AtomSpace)
- **atomspace-cog**: Cognitive architecture integration (CogUtil + AtomSpace)
- **atomspace-bridge**: Component bridge interfaces (CogUtil + AtomSpace)
- **atomspace-agents**: Multi-agent system support (CogUtil + AtomSpace + Boost)
- **atomspace-rpc**: Remote procedure call interface (CogUtil + AtomSpace + Boost)

**Development & Analysis:**
- **visualization**: Data visualization and graph rendering (CogUtil + AtomSpace + Boost)
- **dimensional-embedding**: Vector embedding systems (CogUtil + AtomSpace + Boost)
- **pattern-index**: Pattern indexing and search (CogUtil + AtomSpace + Boost)
- **TinyCog**: Minimal OpenCog implementation (AtomSpace + Guile)
- **ros-behavior-scripting**: ROS robotics integration (no OpenCog dependencies)

#### 🧮 Advanced Reasoning (4 components)
**Purpose**: High-level reasoning and inference requiring URE
- **pln**: Probabilistic Logic Networks for uncertain reasoning (CogUtil + AtomSpace + URE)
- **miner**: Pattern mining and discovery algorithms (CogUtil + AtomSpace + URE + Boost)
- **asmoses**: AtomSpace integration for MOSES (CogUtil + AtomSpace + URE + Boost)
- **benchmark**: Performance testing and optimization (CogUtil + AtomSpace + URE + Boost)

#### 📚 Development Support (1 component)
**Purpose**: Development tools and legacy support
- **python-attic**: Python bindings and legacy code (CogUtil + AtomSpace + URE + Guile)

#### 🎯 Integration Layer (1 component)
**Purpose**: Complete system integration
- **opencog**: Main framework integrating all components (CogUtil + AtomSpace + URE)

#### 📦 Distribution (1 component)
**Purpose**: Packaging and deployment
- **package**: Distribution packages and installers (depends on OpenCog)

### Build Dependencies Analysis

#### Critical Dependency Chain
The longest dependency chain determines minimum build time:
```
cogutil → atomspace → unify → ure → [pln/miner/asmoses] → opencog → package
```

#### Dependency Statistics
- **31 components** depend on CogUtil (foundation layer)
- **29 components** depend on AtomSpace (knowledge layer)
- **20 components** require Boost libraries
- **5 components** require URE (advanced reasoning)
- **3 components** require Guile scripting
- **2 components** require CogServer (attention, learn)
- **1 component** requires SpaceTime (PLN)

#### External Dependencies by Component
- **Boost**: Required by 20 components (foundation libraries)
- **Guile**: Required by 3 components (TinyCog, python-attic)
- **CMake 3.12+**: Minimum version (cogutil requirement)
- **CMake 3.16+**: Required by main consolidated build

### Build Time Estimates (Based on Complexity Analysis)

| Component | Est. Build Time | Dependencies Wait | Total Time |
|-----------|----------------|-------------------|------------|
| cogutil | 8 min | 0 min | 8 min |
| atomspace | 20 min | 8 min | 28 min |
| unify | 12 min | 28 min | 40 min |
| ure | 15 min | 40 min | 55 min |
| pln | 18 min | 55 min | 73 min |
| miner | 22 min | 55 min | 77 min |
| asmoses | 16 min | 55 min | 71 min |
| benchmark | 8 min | 55 min | 63 min |
| opencog | 25 min | 77 min | 102 min |
| package | 3 min | 102 min | 105 min |

**Total optimized pipeline time: ~105 minutes**

### Parallelization Strategy

#### Maximum Parallelization Groups
With unlimited build resources:

**Phase 1 (Foundation - 8 min parallel)**:
- cogutil (required by most)
- moses, blender_api_msgs, perception, ghost_bridge, pau2motors, robots_config, ros-behavior-scripting

**Phase 2 (Core - 20 min sequential)**:
- atomspace (required by 29 components)

**Phase 3 (Extensions - 15 min parallel)**:
- All 25 AtomSpace extension components can build simultaneously

**Phase 4 (Logic - 15 min sequential)**:
- ure (required by advanced reasoning)

**Phase 5 (Advanced - 22 min parallel)**:
- pln, miner, asmoses, benchmark, python-attic

**Phase 6 (Integration - 25 min sequential)**:
- opencog

**Phase 7 (Distribution - 3 min sequential)**:
- package

**Optimized total time: ~108 minutes**

### Quality Assurance

#### Testing Strategy
- **Unit Tests**: Each component includes comprehensive unit tests
- **Integration Tests**: Cross-component functionality validation
- **Performance Tests**: Benchmark component provides optimization metrics
- **Regression Tests**: CI/CD prevents breaking changes
- **Memory Tests**: Valgrind and AddressSanitizer integration

#### Code Quality Standards
- **CMake Standards**: Consistent CMake patterns across all 42 components
- **Dependency Management**: Clear FIND_PACKAGE requirements documented
- **Documentation**: Comprehensive inline and external documentation
- **Error Handling**: Robust error handling and logging throughout
- **Code Style**: Consistent C++ coding standards

### Development Workflow

#### Component Development
1. **Setup**: Clone repository and set up build environment
2. **Component Selection**: Choose components based on development needs
3. **Dependency Building**: Build required dependencies first
4. **Development**: Implement features with testing
5. **Integration**: Test with dependent components
6. **CI Validation**: Ensure CI/CD pipeline passes

#### Build Options
```bash
# Complete ecosystem build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)

# Core components only
cmake -DBUILD_VISION=OFF -DBUILD_CHEMINFORMATICS=OFF ..
make cogutil atomspace ure opencog

# Development build with debugging
cmake -DCMAKE_BUILD_TYPE=Debug -DENABLE_TESTS=ON ..
make -j$(nproc) && make test
```

### Deployment Options

#### Development Environment
```bash
# Full development setup
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DENABLE_TESTS=ON ..
make -j$(nproc)
make install
make test
```

#### Production Environment
```bash
# Optimized production build
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/opencog ..
make -j$(nproc)
make install
```

#### Container Deployment
```bash
# Docker-based deployment
docker build -t opencog-central .
docker run -p 17001:17001 -p 18001:18001 opencog-central
```

#### Selective Component Building
```bash
# Build only reasoning components
cmake -DBUILD_COGUTIL=ON -DBUILD_ATOMSPACE=ON -DBUILD_URE=ON -DBUILD_PLN=ON ..
make cogutil atomspace ure pln

# Build only language processing
cmake -DBUILD_LG_ATOMESE=ON -DBUILD_LEARN=ON -DBUILD_GENERATE=ON ..
make lg-atomese learn generate
```

### Performance Optimization

#### Build Performance
- **ccache**: Compiler caching reduces rebuild times by 70%
- **Ninja**: Faster build system than Make for complex projects
- **Parallel builds**: Optimize -j parameter based on available cores
- **Incremental builds**: Component-level dependency tracking
- **Distributed builds**: distcc for multi-machine compilation

#### Runtime Performance
- **Memory management**: Efficient AtomSpace memory allocation
- **Threading**: Multi-threaded operations in compute-intensive components
- **Caching**: Intelligent caching of computed results
- **Profiling**: Regular performance profiling and optimization
- **SIMD**: Vectorized operations where applicable

### Troubleshooting Guide

#### Common Build Issues

**Missing Dependencies**:
```bash
# Ubuntu/Debian
sudo apt-get install build-essential cmake libboost-all-dev guile-3.0-dev

# CentOS/RHEL
sudo yum install gcc-c++ cmake boost-devel guile-devel
```

**Version Conflicts**:
```bash
# Clear CMake cache
rm -rf CMakeCache.txt CMakeFiles/
cmake ..
```

**Memory Issues**:
```bash
# Reduce parallel jobs for limited RAM
make -j2  # For systems with 4GB RAM
make -j4  # For systems with 8GB RAM
```

#### Runtime Issues

**AtomSpace Configuration**:
- Check AtomSpace data directory permissions
- Verify atom type loading and registration
- Monitor memory usage with AtomSpace statistics

**Network Configuration**:
- Verify CogServer port availability (17001)
- Check firewall settings for distributed setups
- Test network connectivity between nodes

**Performance Issues**:
- Use benchmark component for systematic analysis
- Profile with gprof or perf tools
- Monitor system resources during operation

### CI/CD Integration

#### CircleCI Pipeline
The current CI/CD pipeline builds core components but analysis shows gaps:

**Currently Covered**:
- cogutil, atomspace, unify, ure, cogserver, attention
- spacetime, pln, miner, moses, asmoses
- lg-atomese, learn, opencog

**Missing from CI**:
- 21 specialized components not in current workflow
- Persistence components (atomspace-rocks, atomspace-restful, etc.)
- Development tools (benchmark, visualization, python-attic)
- Domain-specific components (vision, cheminformatics, sensory)

#### Recommended CI Improvements
1. **Add missing components** to CI workflow
2. **Implement conditional builds** based on component changes
3. **Add performance regression testing** using benchmark component
4. **Include security scanning** for all components
5. **Add integration testing** across component boundaries

### Future Roadmap

#### Near-term Improvements (3-6 months)
- **Complete CI coverage** for all 42 components
- **Modular packaging** for individual component distribution
- **Performance optimization** based on benchmark analysis
- **Documentation completion** for all components

#### Medium-term Goals (6-12 months)
- **Cloud-native deployment** with Kubernetes support
- **API standardization** across all components
- **Cross-platform support** (Windows, macOS improvements)
- **Real-time capabilities** for time-critical applications

#### Long-term Vision (1-2 years)
- **Quantum integration** for quantum computing components
- **Neuromorphic computing** support for specialized hardware
- **Advanced distributed cognition** across multiple nodes
- **Domain-specific optimizations** for specialized use cases

### Research Integration

#### Active Research Areas
- **Cognitive architectures**: Integration with other cognitive frameworks
- **Machine learning**: Deep learning integration with symbolic reasoning
- **Natural language**: Advanced NLP and understanding capabilities
- **Robotics**: Real-world robot integration and control
- **Knowledge graphs**: Large-scale knowledge representation

#### Experimental Components
- **TinyCog**: Minimal implementation for embedded systems
- **AtomSpace-IPFS**: Distributed knowledge storage
- **Dimensional-embedding**: Vector space representations
- **AGI-Bio**: Biological intelligence modeling

### Contributing Guidelines

#### Development Process
1. **Component identification**: Choose target component for contribution
2. **Dependency analysis**: Understand component dependencies
3. **Development environment**: Set up proper build environment
4. **Testing**: Implement comprehensive tests
5. **Documentation**: Update relevant documentation
6. **CI validation**: Ensure all tests pass in CI

#### Code Standards
- **C++ Standards**: Follow project C++ coding guidelines
- **CMake Standards**: Use consistent CMake patterns
- **Testing Standards**: Maintain high test coverage
- **Documentation Standards**: Comprehensive inline documentation

### Support and Community

#### Getting Help
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Comprehensive guides and API documentation  
- **Community Forums**: Active community support
- **Developer Chat**: Real-time developer communication

#### Contributing
- **Bug Reports**: Detailed bug reports with reproduction steps
- **Feature Requests**: Well-specified feature requirements
- **Code Contributions**: Pull requests with tests and documentation
- **Documentation**: Improvements to guides and API docs

This comprehensive documentation provides complete coverage of the OpenCog ecosystem based on actual analysis of all 42 components and their dependencies.

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