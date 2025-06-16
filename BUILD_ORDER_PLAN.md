# OpenCog Ecosystem Build Order Plan

This document outlines the optimal build order for the entire OpenCog ecosystem based on dependency analysis.

## Build Order Sequence

# OpenCog Ecosystem Build Order Plan
## Based on Actual CMakeLists.txt Dependency Analysis

This document outlines the optimal build order for the entire OpenCog ecosystem based on analysis of actual CMakeLists.txt dependencies.

## Build Order Sequence

The following sequence ensures that all dependencies are satisfied at each step:

### Phase 1: Foundation (Parallel builds possible)
1. **cogutil** - Core utilities, only external dependencies (Boost)
2. **moses** - Evolutionary algorithms (depends on cogutil + Boost)
3. **blender_api_msgs** - 3D integration APIs (Boost only)
4. **perception** - Basic perception (Boost only) 
5. **ghost_bridge** - Bridge components (Boost only)
6. **pau2motors** - Motor control (Boost only)
7. **robots_config** - Robot configuration (no dependencies)

### Phase 2: Core Systems (Sequential after cogutil)
8. **atomspace** - Core knowledge representation (depends on cogutil + Boost)

### Phase 3: AtomSpace Extensions (Parallel after atomspace)
9. **unify** - Unification engine (depends on cogutil + atomspace + Boost)
10. **cogserver** - Network server (depends on cogutil + atomspace + Boost)
11. **spacetime** - Spatiotemporal reasoning (depends on cogutil + atomspace + Boost)
12. **lg-atomese** - Link Grammar integration (depends on cogutil + atomspace)
13. **learn** - Language learning (depends on cogutil + atomspace)
14. **generate** - Generation system (depends on cogutil + atomspace)
15. **vision** - Computer vision (depends on cogutil + atomspace)
16. **cheminformatics** - Chemical informatics (depends on cogutil + atomspace)
17. **sensory** - Sensory processing (depends on cogutil + atomspace)
18. **agi-bio** - AGI biology (depends on cogutil + atomspace)
19. **atomspace-rocks** - RocksDB persistence (depends on cogutil + atomspace)
20. **atomspace-restful** - HTTP API (depends on cogutil + atomspace + Boost)
21. **atomspace-dht** - DHT persistence (depends on cogutil + atomspace)
22. **atomspace-ipfs** - IPFS integration (depends on cogutil + atomspace)
23. **atomspace-websockets** - WebSocket API (depends on cogutil + atomspace + Boost)
24. **atomspace-metta** - MeTTa integration (depends on cogutil + atomspace)
25. **atomspace-cog** - Cog integration (depends on cogutil + atomspace)
26. **atomspace-bridge** - Bridge components (depends on cogutil + atomspace)
27. **atomspace-agents** - Agent system (depends on cogutil + atomspace + Boost)
28. **atomspace-rpc** - RPC interface (depends on cogutil + atomspace + Boost)
29. **visualization** - Data visualization (depends on cogutil + atomspace + Boost)
30. **dimensional-embedding** - Embedding system (depends on cogutil + atomspace + Boost)
31. **pattern-index** - Pattern indexing (depends on cogutil + atomspace + Boost)
32. **TinyCog** - Minimal OpenCog (depends on atomspace + Guile)
33. **ros-behavior-scripting** - ROS integration (no external OpenCog deps)

### Phase 4: Logic Engine (Sequential after unify)
34. **ure** - Unified Rule Engine (depends on cogutil + atomspace + Boost)

### Phase 5: Cognitive Systems (After cogserver + ure)
35. **attention** - Attention allocation (depends on cogutil + atomspace + cogserver + Boost)

### Phase 6: Advanced Systems (Parallel after ure and other dependencies)
36. **pln** - Probabilistic Logic Networks (depends on cogutil + atomspace + ure + spacetime)
37. **miner** - Pattern mining (depends on cogutil + atomspace + ure + Boost)
38. **asmoses** - AtomSpace MOSES (depends on cogutil + atomspace + ure + Boost)
39. **benchmark** - Performance testing (depends on cogutil + atomspace + ure + Boost)
40. **python-attic** - Python bindings (depends on cogutil + atomspace + ure + Guile)

### Phase 7: Integration (Sequential after all dependencies)
41. **opencog** - Main framework (depends on cogutil + atomspace + ure)

### Phase 8: Packaging (Sequential after opencog)
42. **package** - Distribution packages (depends on opencog)

## Build Parallelization Strategy

## Build Parallelization Strategy

### Parallel Groups (Based on CMakeLists.txt Analysis)

**Group 1 (Foundation - Independent or cogutil-only):**
- cogutil (foundation)
- moses (after cogutil)
- blender_api_msgs (independent)
- perception (independent) 
- ghost_bridge (independent)
- pau2motors (independent)
- robots_config (independent)
- ros-behavior-scripting (independent)

**Group 2 (AtomSpace extensions - parallel after atomspace):**
- unify, cogserver, spacetime, lg-atomese
- learn, generate, vision, cheminformatics, sensory, agi-bio
- atomspace-rocks, atomspace-restful, atomspace-dht, atomspace-ipfs
- atomspace-websockets, atomspace-metta, atomspace-cog, atomspace-bridge
- atomspace-agents, atomspace-rpc
- visualization, dimensional-embedding, pattern-index
- TinyCog

**Group 3 (Advanced systems - parallel after ure + dependencies):**
- pln (needs ure + spacetime)
- miner (needs ure)
- asmoses (needs ure)
- benchmark (needs ure)
- python-attic (needs ure)

**Group 4 (Cognitive systems - after cogserver):**
- attention (needs cogserver)

**Group 5 (Integration):**
- opencog (needs multiple dependencies)

**Group 6 (Packaging):**
- package (needs opencog)

## Estimated Build Times

Based on component complexity and typical build patterns:

| Component | Est. Build Time | Dependencies Wait | Total Time |
|-----------|----------------|-------------------|------------|
| cogutil | 10 min | 0 min | 10 min |
| atomspace | 25 min | 10 min | 35 min |
| unify | 15 min | 35 min | 50 min |
| ure | 20 min | 50 min | 70 min |
| cogserver | 12 min | 35 min | 47 min |
| attention | 15 min | 47 min | 62 min |
| spacetime | 10 min | 35 min | 45 min |
| pln | 18 min | 70 min | 88 min |
| miner | 22 min | 70 min | 92 min |
| moses | 15 min | 10 min | 25 min |
| asmoses | 18 min | 70 min | 88 min |
| lg-atomese | 12 min | 35 min | 47 min |
| learn | 15 min | 47 min | 62 min |
| opencog | 30 min | 92 min | 122 min |
| package | 5 min | 122 min | 127 min |

**Total pipeline time with parallelization: ~127 minutes**

## Critical Path Analysis

The critical path (longest dependency chain) is:
```
cogutil → atomspace → unify → ure → miner → opencog → package
10min → 25min → 15min → 20min → 22min → 30min → 5min = 127 minutes
```

## Optimization Opportunities

### 1. Cache Management
- Implement ccache across all builds
- Share common dependency artifacts
- Use workspace persistence between jobs

### 2. Test Parallelization
- Run tests in parallel where possible
- Skip non-critical tests in dependency builds
- Separate test and install phases

### 3. Container Optimization
- Pre-built base images with common dependencies
- Layer caching for Docker builds
- Multi-stage builds for size optimization

### 4. Resource Allocation
- Use different machine sizes based on component complexity
- Allocate more resources to critical path components
- Consider GPU acceleration where applicable

## Risk Mitigation

### High-Risk Components
1. **atomspace** - Many dependents, complex build
2. **ure** - Critical for advanced reasoning components
3. **opencog** - Final integration point

### Mitigation Strategies
1. Extra testing for high-risk components
2. Redundant build environments
3. Fast-fail mechanisms for early error detection
4. Incremental build capabilities
5. Component-level health checks

## Monitoring and Metrics

### Key Metrics to Track
- Individual component build times
- Overall pipeline duration
- Success/failure rates by component
- Resource utilization patterns
- Test coverage and pass rates

### Performance Baselines
- Establish baseline times for each component
- Track performance trends over time
- Alert on significant deviations
- Regular optimization reviews

## Maintenance Procedures

### Weekly Reviews
- Analyze build performance metrics
- Update dependency graphs if needed
- Review and optimize slow components
- Update time estimates based on actual data

### Monthly Optimizations
- Review parallelization opportunities
- Update cache strategies
- Optimize Docker images
- Review resource allocation

### Quarterly Planning
- Major dependency updates
- Infrastructure improvements
- Tool upgrades and migrations
- Performance target adjustments