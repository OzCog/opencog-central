# OpenCog Central Architecture Documentation Index

This index provides a comprehensive guide to the architectural documentation of the OpenCog Central system, organized by cognitive subsystem and processing layer.

## Main Architecture Documents

- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - Comprehensive architecture documentation with Mermaid diagrams
- **[COGNITIVE_PATTERNS.md](COGNITIVE_PATTERNS.md)** - Detailed cognitive patterns and recursive implementation pathways

## Core System Documentation

### AtomSpace - Central Knowledge Representation
- [AtomSpace README](../orc-as/atomspace/README.md) - Core hypergraph knowledge store
- [AtomSpace Documentation](../orc-as/atomspace/doc/) - Detailed implementation docs

### Probabilistic Logic Network (PLN)
- [PLN README](../pln/README.md) - Probabilistic reasoning engine
- [PLN Examples](../pln/examples/) - Reasoning demonstrations

### Unified Rule Engine (URE)
- [URE Repository](https://github.com/opencog/ure) - Rule-based inference system

## Sensory-Motor Architecture

### Core Design Documents
- [Sensory Architecture](../sensory/Architecture.md) - Sensory-motor system overview
- [System Design](../sensory/Design.md) - Implementation details and API
- [Design Notes A-E](../sensory/DesignNotes-A.md) - Evolution of design thinking

### Implementation Examples
- [Sensory Examples](../sensory/examples/) - Working demonstrations
- [API Basics](../sensory/examples/README.md) - Usage patterns

## Learning and Generation Systems

### Learning Architecture
- [Learning Architecture](../learn/README-Architecture.md) - Unified learning framework
- [Structure Learning](../learn/) - Unsupervised structure discovery

### Generation Systems
- [Generation README](../generate/README.md) - Text and pattern generation
- [Generation Design Notes](../generate/Design-Notes.md) - Implementation approach

### Agent Systems
- [Agents README](../agents/README.md) - Interactive learning agents
- [Agent Examples](../agents/examples/) - Agent demonstrations

## Cognitive Integration Patterns

### Neural-Symbolic Integration
- Pattern matching between neural embeddings and symbolic structures
- Confidence fusion mechanisms
- Cross-modal attention synchronization

### Recursive Processing
- Self-referential pattern analysis
- Meta-cognitive monitoring systems
- Convergence detection algorithms

### Attention Allocation
- Salience computation mechanisms
- Resource allocation strategies
- Adaptive priority management

## System Components by Function

### Knowledge Representation
```
AtomSpace (hypergraph store)
├── Atoms and Links (basic structures)
├── Truth Values (uncertainty representation)
├── Pattern Engine (query and matching)
└── Execution Engine (program execution)
```

### Reasoning and Inference
```
PLN (probabilistic reasoning)
├── Forward Chaining
├── Backward Chaining
├── Truth Value Propagation
└── Common Sense Reasoning

URE (rule-based inference)
├── Rule Management
├── Forward/Backward Chaining
├── Fitness Functions
└── Meta-Rules
```

### Learning Systems
```
Structure Learning
├── Grammatical Inference
├── Pattern Discovery
├── Statistical Analysis
└── Recursive Refinement

Agent Learning
├── Interactive Learning
├── Incremental Updates
├── Goal-Directed Learning
└── Transfer Learning
```

### Sensory-Motor Interface
```
Sensory Processing
├── Link Grammar Parsing
├── Multi-modal Integration
├── Stream Processing
└── Device Abstraction

Motor Control
├── Action Planning
├── Execution Monitoring
├── Feedback Integration
└── Environmental Interaction
```

## Implementation Architecture Layers

### Application Layer
- Chatbot interfaces
- Robotic control systems
- Research tools
- Demo applications

### API Layer
- Scheme API (primary interface)
- Python API (data science integration)
- REST API (web services)
- WebSocket API (real-time interaction)

### Service Layer
- CogServer (central coordination)
- AtomSpace Service (knowledge management)
- PLN Service (reasoning coordination)
- Attention Service (resource management)

### Processing Layer
- Pattern Engine (matching and binding)
- Inference Engine (logical reasoning)
- Execution Engine (program execution)
- Learning Engine (adaptive processing)

### Storage Layer
- Memory Store (working memory)
- Persistent Store (long-term storage)
- Distributed Store (network storage)
- Backup Store (reliability)

## Mermaid Diagram Reference

The [main architecture document](../ARCHITECTURE.md) contains the following diagram types:

1. **High-Level System Overview** - `graph TD` showing major components
2. **Core Component Interactions** - `graph LR` showing bidirectional relationships
3. **Neural-Symbolic Integration** - `graph TB` showing layer interactions
4. **Data Flow Sequences** - `sequenceDiagram` showing temporal processes
5. **State Transitions** - `stateDiagram-v2` showing cognitive states
6. **Attention Allocation** - `graph TD` showing resource management
7. **Recursive Processing** - `stateDiagram-v2` showing self-referential loops
8. **Module Mappings** - `graph LR` showing inter-module communication
9. **Implementation Stack** - `graph TB` showing architectural layers

## Development and Contribution

### Getting Started
1. Read the [main architecture document](../ARCHITECTURE.md)
2. Explore component-specific documentation
3. Run examples in relevant directories
4. Contribute to documentation improvements

### Documentation Standards
- Use Mermaid for architectural diagrams
- Maintain cross-references between documents
- Update diagrams when architecture changes
- Include implementation examples

### Architecture Evolution
The architecture documentation is a living resource that evolves with the system. Key principles for updates:

- **Accuracy**: Keep diagrams synchronized with implementation
- **Clarity**: Use clear, descriptive labels and annotations
- **Completeness**: Cover all major architectural patterns
- **Accessibility**: Ensure newcomers can understand the system

## Related Resources

### External Documentation
- [Link Grammar](http://www.link.cs.cmu.edu/link/) - Grammatical parsing framework
- [Mermaid Documentation](https://mermaid-js.github.io/mermaid/) - Diagram syntax reference

### Academic Papers
- Papers on cognitive architectures and AGI research
- Publications on hypergraph knowledge representation
- Research on neural-symbolic integration

---

*This index is maintained to provide easy navigation through the comprehensive OpenCog Central architecture documentation. For questions or contributions, please refer to the main project documentation.*