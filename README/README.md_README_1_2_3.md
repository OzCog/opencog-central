# OpenCog Orchestration (orc-oc)

[![CircleCI](https://circleci.com/gh/opencog/opencog-central.svg?style=svg)](https://circleci.com/gh/opencog/opencog-central)

This directory contains the complete orchestration of all OpenCog components,
providing a unified build system and workflow for the entire OpenCog ecosystem.

## Overview

The OpenCog Orchestration consolidates all OpenCog-related components into
a single, well-organized structure with proper dependency management and 
build ordering. This ensures reliable, reproducible builds and installations
across all OpenCog modules, from core AI reasoning to specialized applications.

## Components

The orchestration includes the following components, built in dependency order:

### Core Framework
- **opencog** - The core OpenCog framework including reasoning, learning, and natural language processing
  - Natural Language Processing (NLP) modules
  - Pattern matching and reasoning engines  
  - Learning algorithms and cognitive architectures
  - Chat systems and dialogue management

### Knowledge Integration Systems
- **opencog-cycl** - Integration with Cyc knowledge bases and CycL reasoning
  - Maps Cyc KBs to AtomSpace representation
  - Provides enhanced inference mechanisms for knowledge bases
  - Translates CycL rules into OpenCog format

- **opencog-neo4j** - Neo4j graph database integration
  - High-performance graph storage backend
  - Efficient knowledge graph operations
  - Scalable graph analytics and traversal

### Deployment and Distribution
- **opencog-debian** - Debian/Ubuntu packaging system
  - APT-compatible package distribution
  - System-wide installation support
  - Dependency management for Linux distributions
  - Automated package building and testing

- **opencog-nix** - Nix functional package management
  - Reproducible build environments
  - Immutable package deployments
  - Cross-platform distribution
  - Development environment isolation

### Web Presence and Documentation
- **opencog.org** - Official OpenCog website and documentation
  - Community portal and documentation
  - Research publications and tutorials
  - Project coordination and communication
  - Educational resources

## Building

### Prerequisites

Before building the OpenCog orchestration, ensure you have the following dependencies:

**Core Dependencies:**
- CMake 3.16 or later
- C++17 compatible compiler (GCC 8+, Clang 8+)
- CogUtil 2.0.3+
- AtomSpace 5.0.4+

**Optional Dependencies:**
- Guile 3.0+ (for Scheme scripting)
- Python 3.8+ with development headers
- Cython (for Python bindings)
- Neo4j Python driver (for graph database integration)
- ROS/catkin (for robotics integration)

**Platform-Specific:**
- Unity3D 2020.3+ (for game integration)
- Minecraft 1.16+ (for world integration)
- Neo4j 4.0+ database server

### Quick Start

```bash
# Clone the repository
git clone https://github.com/opencog/opencog-central.git
cd opencog-central/orc-oc

# Create build directory
mkdir build && cd build

# Configure build
cmake ..

# Build all components
make -j$(nproc)

# Install (optional)
sudo make install
```

### Component-Specific Building

#### Core OpenCog Framework
```bash
cd opencog
mkdir build && cd build
cmake ..
make -j$(nproc)
```

#### Knowledge Systems
```bash
# Cycl Integration
cd opencog-cycl
pip3 install -r requirements.txt
python3 cycl-opencog-0-2.py -i input.cycl -o output.scm

# Neo4j Integration  
cd opencog-neo4j
pip3 install neo4j py2neo
# Configure Neo4j connection in config files
```

#### Robotics Integration
```bash
# ROS Integration (requires ROS installation)
cd ros_opencog_robot_embodiment
catkin_make
source devel/setup.bash

# Raspberry Pi (cross-compilation)
cd opencog_rpi
# Follow ARM cross-compilation instructions
```

#### Gaming Platforms
```bash
# Minecraft Integration
cd opencog-to-minecraft
pip3 install -r requirements.txt
python3 minecraft_bot.py

# Unity3D (requires Unity Editor)
# Open unity3d-opencog-game project in Unity
```

### Testing

Run the test suite to verify your installation:

```bash
# Core tests
make test

# Python integration tests
python3 -m pytest tests/

# Component-specific tests
cd opencog && make test
```

## Usage Examples

### Basic Reasoning
```python
from opencog.atomspace import AtomSpace
from opencog.scheme import scheme_eval

atomspace = AtomSpace()
scheme_eval(atomspace, '(use-modules (opencog exec))')

# Load knowledge and run inference
scheme_eval(atomspace, '(load "knowledge-base.scm")')
result = scheme_eval(atomspace, '(cog-execute! (ConceptNode "reasoning-query"))')
```

### Robot Control
```python
import rospy
from opencog_msgs.msg import AtomSpaceMsg

# Initialize ROS node
rospy.init_node('opencog_robot')

# Connect to OpenCog atomspace
# Send cognitive commands to robot
```

### Minecraft AI Agent
```python
from opencog_minecraft import MinecraftBot

bot = MinecraftBot()
bot.connect("localhost", 25565)
bot.set_goal("build_house")
bot.execute_plan()
```

## Architecture

The OpenCog orchestration follows a layered architecture:

```
┌─────────────────────────────────────────┐
│           Applications Layer            │
│  (Games, Robotics, Web, Packages)      │
├─────────────────────────────────────────┤
│         Integration Layer               │
│    (ROS, Unity, Minecraft, Neo4j)      │
├─────────────────────────────────────────┤
│        Knowledge Systems Layer          │
│      (Cycl, Graphs, Reasoning)         │
├─────────────────────────────────────────┤
│           Core OpenCog Layer            │
│    (NLP, Learning, Pattern Matching)   │
├─────────────────────────────────────────┤
│           Foundation Layer              │
│        (AtomSpace, CogUtil)             │
└─────────────────────────────────────────┘
```

## Development

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Coding Standards

- Follow C++17 best practices
- Use consistent indentation (4 spaces)
- Include comprehensive comments
- Write unit tests for new features
- Update documentation as needed

### Debugging

Enable debug builds for development:

```bash
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j$(nproc)

# Run with debugging
gdb ./opencog-program
```

## Configuration

### Environment Variables

- `OPENCOG_LOG_LEVEL`: Set logging verbosity (DEBUG, INFO, WARN, ERROR)
- `ATOMSPACE_COG_SERVER_PORT`: Port for network AtomSpace access
- `GUILE_LOAD_PATH`: Additional Scheme module paths

### Configuration Files

- `opencog.conf`: Main configuration file
- `logging.conf`: Logging configuration  
- `modules.conf`: Module loading configuration

## Troubleshooting

### Common Issues

**Build Failures:**
- Ensure all dependencies are installed
- Check CMake version compatibility
- Verify C++17 compiler support

**Runtime Errors:**
- Check log files in `/tmp/opencog.log`
- Verify AtomSpace connectivity
- Ensure proper module loading

**Memory Issues:**
- Monitor AtomSpace memory usage
- Adjust garbage collection settings
- Use memory profiling tools

### Getting Help

- Documentation: https://wiki.opencog.org
- Forums: https://groups.google.com/g/opencog
- IRC: #opencog on Libera.Chat
- GitHub Issues: Report bugs and feature requests

## License

OpenCog components are released under various open source licenses:
- Core OpenCog: AGPL v3
- Some components: Apache 2.0
- Platform integrations: MIT

See individual component directories for specific license information.

## Acknowledgments

The OpenCog project is developed by a global community of researchers, 
developers, and AI enthusiasts. Special thanks to all contributors who
have made this orchestration possible.

For more information about the OpenCog project, visit https://opencog.org
