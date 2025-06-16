# OpenCog Ecosystem Build Order Plan

This document outlines the optimal build order for the entire OpenCog ecosystem based on dependency analysis.

## Build Order Sequence

The following sequence ensures that all dependencies are satisfied at each step:

### Phase 1: Foundation (Parallel builds possible)
1. **cogutil** - Core utilities, no dependencies
2. **moses** - Evolutionary algorithms, depends only on cogutil
3. **language-learning** - Basic NLP, depends only on cogutil

### Phase 2: Core Systems (Sequential after cogutil)
4. **atomspace** - Core knowledge representation (depends on cogutil)

### Phase 3: AtomSpace Extensions (Parallel after atomspace)
5. **atomspace-rocks** - Persistence layer (depends on cogutil + atomspace)
6. **atomspace-restful** - HTTP API (depends on cogutil + atomspace)
7. **unify** - Unification engine (depends on cogutil + atomspace)
8. **cogserver** - Network server (depends on cogutil + atomspace)
9. **spacetime** - Spatiotemporal reasoning (depends on cogutil + atomspace)
10. **lg-atomese** - Link Grammar integration (depends on cogutil + atomspace)

### Phase 4: Logic Engine (Sequential after unify)
11. **ure** - Unified Rule Engine (depends on cogutil + atomspace + unify)

### Phase 5: Advanced Systems (Parallel after ure and other dependencies)
12. **attention** - Attention allocation (depends on cogutil + atomspace + cogserver)
13. **pln** - Probabilistic Logic Networks (depends on cogutil + atomspace + unify + ure + spacetime)
14. **miner** - Pattern mining (depends on cogutil + atomspace + unify + ure)
15. **asmoses** - AtomSpace MOSES (depends on cogutil + atomspace + unify + ure)
16. **learn** - Language learning (depends on cogutil + atomspace + cogserver)

### Phase 6: Integration (Sequential after all dependencies)
17. **opencog** - Main framework (depends on cogutil + atomspace + cogserver + attention + unify + ure + lg-atomese)

### Phase 7: Packaging (Sequential after opencog)
18. **package** - Distribution packages (depends on opencog)

## Build Parallelization Strategy

### Parallel Groups

**Group 1 (Independent foundation):**
- cogutil
- moses (after cogutil)
- language-learning (after cogutil)

**Group 2 (AtomSpace extensions - parallel after atomspace):**
- atomspace-rocks
- atomspace-restful
- unify
- cogserver
- spacetime
- lg-atomese

**Group 3 (Advanced systems - parallel after dependencies met):**
- attention (needs cogserver)
- miner (needs ure)
- asmoses (needs ure)
- learn (needs cogserver)

**Group 4 (Late dependencies):**
- pln (needs ure + spacetime)

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