# OpenCog Ecosystem Documentation

**Comprehensive Analysis and Integration Guide**

This document provides a complete analysis of the OpenCog ecosystem with 92 components,
comparing CircleCI, CMakeLists.txt, and README specifications to resolve conflicts
and provide unified build and dependency management.

*Generated: 2025-06-16 02:56:53*

## 📊 Component Audit Summary

### Overview Statistics

- **Total Components**: 92
- **Functional Categories**: 13
- **Components with CMake**: 42
- **Components with Documentation**: 79

### Components by Category

| Category | Count | Description |
|----------|-------|-------------|
| orc-ai | 7 | AI & Learning algorithms and frameworks |
| orc-as | 14 | AtomSpace knowledge representation |
| orc-bi | 3 | Bioinformatics and life sciences |
| orc-ct | 11 | Cognitive tools and mental processes |
| orc-dv | 11 | Development tools and utilities |
| orc-em | 3 | Emotion AI and affective computing |
| orc-gm | 3 | Gaming and virtual environments |
| orc-in | 6 | Infrastructure and deployment |
| orc-nl | 7 | Natural Language processing systems |
| orc-oc | 6 | OpenCog integration framework |
| orc-ro | 12 | Robotics and sensory processing |
| orc-sv | 4 | Servers, agents, and distributed systems |
| orc-wb | 5 | Web interfaces and API systems |


## 🔄 Build Plan Comparison

### Current State Analysis

- **CircleCI Jobs**: 18 automated build jobs
- **CMake Projects**: 49 components with CMakeLists.txt
- **Documented Components**: 79 components with README files

### Coverage Analysis

- **Complete coverage** (all three): 16 components
- **CircleCI + CMake only**: 0 components
- **CircleCI + README only**: 1 components
- **CMake + README only**: 29 components
- **CircleCI only**: 1 components
- **CMake only**: 4 components
- **README only**: 33 components

## ⚠️ Conflict Resolution

### Identified Conflicts

#### Conflict 1: Components in CircleCI but missing CMakeLists.txt

**Type**: `missing_cmake`

**Affected components**:
- language-learning
- package

**Recommended action**:
Add CMakeLists.txt files to enable local building and dependency management.

#### Conflict 2: Components with CMake but missing from CircleCI

**Type**: `missing_circleci`

**Affected components**:
- CMakeLists.txt
- atomspace-metta
- atomspace-bridge
- ros_opencog_robot_embodiment
- benchmark
- vision
- atomspace-ipfs
- perception
- python-attic
- atomspace-cog
- cheminformatics
- agi-bio
- pau2motors
- destin
- atomspace-websockets
- atomspace-rpc
- ghost_bridge
- atomspace-dht
- robots_config
- pattern-index
- TinyCog
- generate
- sensory
- opencog-to-minecraft
- blender_api_msgs
- visualization
- copied-cmake
- link-grammar
- ros-behavior-scripting
- dimensional-embedding
- pi_vision
- kokkos_integrations
- atomspace-agents

**Recommended action**:
Add CircleCI job definitions to enable automated testing and builds.

#### Conflict 3: Documented components without build automation

**Type**: `missing_build`

**Affected components**:
- semantic-vision
- rest-api-documentation
- opencog-neo4j
- opencog-debian
- external-tools
- stochastic-language-generation
- agents
- opencog-nix
- opencog.org
- blender_api
- python-destin
- opencog-cycl
- atomspace-typescript
- link-grammar-website
- docker
- cogprotolab
- opencog_rpi
- loving-ai
- profile
- python-client
- loving-ai-ghost
- atomspace-explorer
- test-datasets
- guile-dbi
- tv-toolbox
- ocpkg
- rocca
- logicmoo_cogserver
- relex
- linkgrammar-relex-web
- pln-brca-xp
- atomspace-js
- unity3d-opencog-game

**Recommended action**:
Add either CMake or CircleCI configuration to enable automated building.

## 🔍 Missing Dependencies Analysis

Found 129 potential missing dependencies:

### orc-ai

- **miner** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **miner** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **asmoses** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **asmoses** missing dependency: `mpi`
  - Original reference: `MPI`
- **asmoses** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **asmoses** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **ure** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **ure** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **learn** missing dependency: `atomspacerocks`
  - Original reference: `AtomSpaceRocks`
- **pln** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **moses** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **moses** missing dependency: `mpi`
  - Original reference: `MPI`
- **moses** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **moses** missing dependency: `doxygen`
  - Original reference: `Doxygen`

### orc-as

- **atomspace-agents** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-agents** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **atomspace-agents** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **atomspace-dht** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-dht** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **atomspace** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace** missing dependency: `folly`
  - Original reference: `Folly`
- **atomspace** missing dependency: `ocaml`
  - Original reference: `OCaml`
- **atomspace** missing dependency: `stack`
  - Original reference: `Stack`
- **atomspace** missing dependency: `unixodbc`
  - Original reference: `UnixODBC`
- **atomspace** missing dependency: `pgsql`
  - Original reference: `PGSQL`
- **atomspace** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **atomspace** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **atomspace-rocks** missing dependency: `rocksdb`
  - Original reference: `RocksDB`
- **atomspace-rocks** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-rocks** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **atomspace-rocks** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **atomspace-ipfs** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-ipfs** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **atomspace-websockets** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-restful** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-restful** missing dependency: `pkgconfig`
  - Original reference: `PkgConfig`
- **atomspace-restful** missing dependency: `tbb`
  - Original reference: `TBB`
- **atomspace-restful** missing dependency: `zmq`
  - Original reference: `ZMQ`
- **atomspace-restful** missing dependency: `attentionbank`
  - Original reference: `AttentionBank`
- **atomspace-restful** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **atomspace-restful** missing dependency: `jsoncpp`
  - Original reference: `jsoncpp`
- **atomspace-bridge** missing dependency: `pgsql`
  - Original reference: `PGSQL`
- **atomspace-bridge** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-bridge** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **atomspace-bridge** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **atomspace-metta** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-metta** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **atomspace-rpc** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-cog** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **atomspace-cog** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **atomspace-cog** missing dependency: `doxygen`
  - Original reference: `Doxygen`

### orc-ct

- **generate** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **pattern-index** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **pattern-index** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **attention** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **attention** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **attention** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **dimensional-embedding** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **dimensional-embedding** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **spacetime** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **spacetime** missing dependency: `octomap`
  - Original reference: `Octomap`
- **spacetime** missing dependency: `doxygen`
  - Original reference: `Doxygen`
- **unify** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **unify** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **visualization** missing dependency: `gtk3`
  - Original reference: `GTK3`
- **visualization** missing dependency: `doxygen`
  - Original reference: `Doxygen`

### orc-dv

- **cogutil** missing dependency: `pthreads`
  - Original reference: `PThreads`
- **cogutil** missing dependency: `stlport`
  - Original reference: `STLPort`
- **cogutil** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **cogutil** missing dependency: `gnubacktrace`
  - Original reference: `GNUBacktrace`
- **cogutil** missing dependency: `bfd`
  - Original reference: `BFD`
- **cogutil** missing dependency: `iberty`
  - Original reference: `Iberty`
- **cogutil** missing dependency: `parallelstl`
  - Original reference: `ParallelSTL`
- **cogutil** missing dependency: `doxygen`
  - Original reference: `Doxygen`

### orc-em

- **ghost_bridge** missing dependency: `catkin`
  - Original reference: `catkin`
- **ghost_bridge** missing dependency: `catkin`
  - Original reference: `catkin`
- **ghost_bridge** missing dependency: `catkin`
  - Original reference: `catkin`
- **ghost_bridge** missing dependency: `catkin`
  - Original reference: `catkin`

### orc-gm

- **TinyCog** missing dependency: `opencv`
  - Original reference: `OpenCV`
- **TinyCog** missing dependency: `dlib`
  - Original reference: `dlib`
- **TinyCog** missing dependency: `protobuf`
  - Original reference: `Protobuf`
- **TinyCog** missing dependency: `raspicam`
  - Original reference: `raspicam`
- **TinyCog** missing dependency: `pkgconfig`
  - Original reference: `PkgConfig`
- **TinyCog** missing dependency: `openmp`
  - Original reference: `OpenMP`
- **TinyCog** missing dependency: `pocketsphinx`
  - Original reference: `PocketSphinx`
- **TinyCog** missing dependency: `festival`
  - Original reference: `Festival`
- **TinyCog** missing dependency: `est`
  - Original reference: `EST`
- **TinyCog** missing dependency: `wiringpi`
  - Original reference: `WiringPi`
- **TinyCog** missing dependency: `alsa`
  - Original reference: `alsa`

### orc-nl

- **lg-atomese** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **lg-atomese** missing dependency: `linkgrammar`
  - Original reference: `LinkGrammar`
- **lg-atomese** missing dependency: `uuid`
  - Original reference: `UUID`
- **lg-atomese** missing dependency: `doxygen`
  - Original reference: `Doxygen`

### orc-oc

- **opencog** missing dependency: `attentionbank`
  - Original reference: `AttentionBank`
- **opencog** missing dependency: `lgatomese`
  - Original reference: `LGAtomese`
- **opencog** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **opencog** missing dependency: `ghc`
  - Original reference: `GHC`
- **opencog** missing dependency: `stack`
  - Original reference: `Stack`
- **opencog** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **opencog** missing dependency: `doxygen`
  - Original reference: `Doxygen`

### orc-ro

- **blender_api_msgs** missing dependency: `catkin`
  - Original reference: `catkin`
- **blender_api_msgs** missing dependency: `catkin`
  - Original reference: `catkin`
- **blender_api_msgs** missing dependency: `catkin`
  - Original reference: `catkin`
- **blender_api_msgs** missing dependency: `catkin`
  - Original reference: `catkin`
- **pau2motors** missing dependency: `catkin`
  - Original reference: `catkin`
- **pau2motors** missing dependency: `catkin`
  - Original reference: `catkin`
- **pau2motors** missing dependency: `catkin`
  - Original reference: `catkin`
- **perception** missing dependency: `catkin`
  - Original reference: `catkin`
- **perception** missing dependency: `catkin`
  - Original reference: `catkin`
- **perception** missing dependency: `catkin`
  - Original reference: `catkin`
- **ros-behavior-scripting** missing dependency: `catkin`
  - Original reference: `catkin`
- **robots_config** missing dependency: `catkin`
  - Original reference: `catkin`
- **robots_config** missing dependency: `catkin`
  - Original reference: `catkin`
- **vision** missing dependency: `opencv`
  - Original reference: `OpenCV`
- **vision** missing dependency: `catch2`
  - Original reference: `Catch2`
- **vision** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **vision** missing dependency: `doxygen`
  - Original reference: `Doxygen`

### orc-sv

- **cogserver** missing dependency: `openssl`
  - Original reference: `OpenSSL`
- **cogserver** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **cogserver** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **cogserver** missing dependency: `doxygen`
  - Original reference: `Doxygen`

### orc-wb

- **python-attic** missing dependency: `attentionbank`
  - Original reference: `AttentionBank`
- **python-attic** missing dependency: `cxxtest`
  - Original reference: `Cxxtest`
- **python-attic** missing dependency: `ghc`
  - Original reference: `GHC`
- **python-attic** missing dependency: `stack`
  - Original reference: `Stack`
- **python-attic** missing dependency: `linkgrammar`
  - Original reference: `LinkGrammar`
- **python-attic** missing dependency: `uuid`
  - Original reference: `UUID`
- **python-attic** missing dependency: `valgrind`
  - Original reference: `VALGRIND`
- **python-attic** missing dependency: `doxygen`
  - Original reference: `Doxygen`

## 🏗️ Component Classification by Layer & Function

Components are classified into architectural layers based on their dependencies and functionality:

### Foundation Layer (14 components)

**orc-ai**: asmoses, moses
**orc-dv**: cogprotolab, cogutil, external-tools, guile-dbi, integrated_output, node_modules, ocpkg, rust_crates, src, test-datasets
**orc-ro**: blender_api, blender_api_msgs

### Core Layer (15 components)

**orc-as**: atomspace, atomspace-agents, atomspace-bridge, atomspace-cog, atomspace-dht, atomspace-explorer, atomspace-ipfs, atomspace-js, atomspace-metta, atomspace-restful, atomspace-rocks, atomspace-rpc, atomspace-typescript, atomspace-websockets
**orc-sv**: agents

### Logic Layer (2 components)

**orc-ai**: ure
**orc-ct**: unify

### Cognitive Layer (11 components)

**orc-ct**: attention, dimensional-embedding, distributional-value, kokkos_integrations, pattern-index, profile, spacetime, tv-toolbox
**orc-sv**: cogserver, logicmoo_cogserver, rocca

### Advanced Layer (5 components)

**orc-ai**: destin, miner, pln
**orc-bi**: pln-brca-xp
**orc-dv**: benchmark

### Learning Layer (3 components)

**orc-ai**: learn
**orc-ct**: generate
**orc-nl**: language-learning

### Specialized Layer (21 components)

**orc-bi**: agi-bio, cheminformatics
**orc-ct**: visualization
**orc-em**: ghost_bridge, loving-ai, loving-ai-ghost
**orc-gm**: TinyCog
**orc-nl**: lg-atomese, link-grammar, link-grammar-website, linkgrammar-relex-web, relex, stochastic-language-generation
**orc-ro**: pau2motors, perception, pi_vision, robots_config, ros-behavior-scripting, semantic-vision, sensory, vision

### Integration Layer (14 components)

**orc-gm**: opencog-to-minecraft, unity3d-opencog-game
**orc-oc**: opencog, opencog-cycl, opencog-debian, opencog-neo4j, opencog-nix, opencog.org
**orc-ro**: opencog_rpi, ros_opencog_robot_embodiment
**orc-wb**: python-attic, python-client, python-destin, rest-api-documentation

### Packaging Layer (7 components)

**orc-in**: copied-cmake, copied-scm, copied-yml, docker, docs, scripts
**orc-wb**: python_packages

## 🔧 Build Order Recommendations

### Optimal Build Sequence

Based on dependency analysis, the following build order minimizes compilation time:

```bash
# Phase 1: Foundation (parallel possible)
build cogutil &
build moses &
wait

# Phase 2: Core (parallel after foundation)
build atomspace &
build atomspace-rocks &
build atomspace-restful &
wait

# Phase 3: Logic (parallel after core)
build unify &
build ure &
wait

# Phase 4: Cognitive (parallel after logic)
build cogserver &
build attention &
build spacetime &
wait

# Phase 5: Advanced (parallel after cognitive)
build pln &
build miner &
build asmoses &
wait

# Phase 6: Integration
build opencog
```

### Parallelization Opportunities

- **Layer 1**: 2 components can build in parallel
- **Layer 2**: 3-4 components can build in parallel
- **Layer 3**: 2 components can build in parallel
- **Layer 4**: 3 components can build in parallel
- **Layer 5**: 3+ components can build in parallel

**Estimated time savings**: 40-60% reduction in total build time

## 🎯 Integration Recommendations

### Unified Build System

1. **Consolidate CMakeLists.txt**: Ensure all components have proper CMake configuration
2. **Update CircleCI**: Add missing components to automated build pipeline
3. **Dependency Management**: Implement pkg-config files for all components
4. **Documentation**: Standardize README format across all components

### Missing Component Resolution

Priority order for addressing missing components in build systems:

1. **High Priority**: Core components missing from CircleCI
2. **Medium Priority**: Documented components without build automation
3. **Low Priority**: Experimental or deprecated components

### Quality Assurance

- **Automated Testing**: Ensure all components have test suites
- **Dependency Validation**: Verify all dependencies are available
- **Build Verification**: Test complete build pipeline regularly
- **Documentation**: Keep README files synchronized with implementation

### Future Maintenance

- **Regular Audits**: Run this analysis monthly to catch inconsistencies
- **Component Lifecycle**: Establish process for adding/removing components
- **Version Management**: Implement semantic versioning across ecosystem
- **Release Coordination**: Coordinate releases across dependent components

---

*Analysis includes 18 CircleCI jobs, 49 CMake projects, and 79 documented components*