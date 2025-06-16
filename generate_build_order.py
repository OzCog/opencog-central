#!/usr/bin/env python3
"""
Build Order Plan Generator for OpenCog Central
=============================================

This script generates the definitive build order plan based on README-specified
dependency flow, CMakeLists.txt analysis, and CircleCI requirements.
"""

import json
from pathlib import Path
from typing import Dict, List, Set, Tuple
from collections import defaultdict, deque

class BuildOrderGenerator:
    def __init__(self, repo_root: str, audit_file: str):
        self.repo_root = Path(repo_root)
        self.audit_file = audit_file
        self.audit_data = self._load_audit_data()
        self.dependencies = defaultdict(set)
        self.build_layers = []
        self.parallel_groups = []
        
    def _load_audit_data(self) -> Dict:
        """Load audit data from JSON file"""
        try:
            with open(self.audit_file, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"⚠️  Warning: Could not load audit data: {e}")
            return {}
    
    def extract_dependencies(self):
        """Extract and normalize all dependencies"""
        print("🔍 Extracting dependencies from all sources...")
        
        # Add critical dependencies based on OpenCog architecture
        critical_deps = {
            # Foundation layer - no dependencies
            'cogutil': set(),
            'moses': set(),
            
            # Core layer - depends on foundation
            'atomspace': {'cogutil'},
            'atomspace-rocks': {'atomspace', 'cogutil'},
            'atomspace-restful': {'atomspace', 'cogutil'},
            'atomspace-dht': {'atomspace', 'cogutil'},
            'atomspace-ipfs': {'atomspace', 'cogutil'},
            'atomspace-websockets': {'atomspace', 'cogutil'},
            'atomspace-metta': {'atomspace', 'cogutil'},
            'atomspace-bridge': {'atomspace', 'cogutil'},
            'atomspace-agents': {'atomspace', 'cogutil'},
            'atomspace-explorer': {'atomspace', 'cogutil'},
            'atomspace-cog': {'atomspace', 'cogutil'},
            'atomspace-typescript': {'atomspace', 'cogutil'},
            'atomspace-rpc': {'atomspace', 'cogutil'},
            'atomspace-js': {'atomspace', 'cogutil'},
            
            # Logic layer - depends on core
            'unify': {'atomspace', 'cogutil'},
            'ure': {'atomspace', 'unify', 'cogutil'},
            
            # Cognitive layer - depends on core and logic
            'cogserver': {'atomspace', 'cogutil'},
            'attention': {'atomspace', 'cogserver', 'cogutil'},
            'spacetime': {'atomspace', 'cogutil'},
            
            # Advanced layer - depends on cognitive and logic
            'pln': {'atomspace', 'ure', 'spacetime', 'cogutil'},
            'miner': {'atomspace', 'ure', 'cogutil'},
            'asmoses': {'atomspace', 'ure', 'cogutil'},
            'benchmark': {'atomspace', 'ure', 'cogutil'},
            
            # Learning layer - depends on cognitive
            'learn': {'atomspace', 'cogserver', 'cogutil'},
            'generate': {'atomspace', 'cogutil'},
            
            # Specialized layer - depends on core
            'vision': {'atomspace', 'cogutil'},
            'perception': {'atomspace', 'cogutil'},
            'sensory': {'atomspace', 'cogutil'},
            'cheminformatics': {'atomspace', 'cogutil'},
            'visualization': {'atomspace', 'cogutil'},
            'lg-atomese': {'atomspace', 'cogutil'},
            'relex': {'cogutil'},
            'link-grammar': set(),
            'language-learning': {'cogutil'},
            
            # Integration layer - depends on multiple systems
            'opencog': {'atomspace', 'cogserver', 'attention', 'ure', 'cogutil'},
            
            # Packaging layer - depends on integration
            'opencog-debian': {'opencog'},
            'opencog-nix': {'opencog'},
            'package': {'opencog'}
        }
        
        # Merge with extracted dependencies
        self.dependencies.update(critical_deps)
        
        # Add dependencies from audit data
        components = self.audit_data.get('components', {})
        for category, category_components in components.items():
            for comp_name, comp_info in category_components.items():
                if comp_name not in self.dependencies:
                    self.dependencies[comp_name] = set()
                
                # Add dependencies from component info
                for dep in comp_info.get('dependencies', []):
                    normalized_dep = self._normalize_component_name(dep)
                    if normalized_dep and normalized_dep != comp_name:
                        self.dependencies[comp_name].add(normalized_dep)
        
        print(f"  ✓ Processed {len(self.dependencies)} components with dependencies")
    
    def _normalize_component_name(self, name: str) -> str:
        """Normalize component name"""
        if not name or len(name) < 2:
            return ""
        
        name = name.lower().strip()
        
        # Skip system dependencies
        system_deps = ['boost', 'cmake', 'gcc', 'python', 'guile', 'cython', 'pkg-config']
        if any(sys_dep in name for sys_dep in system_deps):
            return ""
        
        return name
    
    def compute_build_layers(self):
        """Compute build layers using topological sort"""
        print("🏗️ Computing build layers...")
        
        # Create a copy of dependencies for manipulation
        deps = {comp: deps.copy() for comp, deps in self.dependencies.items()}
        all_components = set(deps.keys())
        
        # Add components that are dependencies but not in the main list
        for comp_deps in deps.values():
            all_components.update(comp_deps)
        
        # Initialize components without dependencies
        for comp in all_components:
            if comp not in deps:
                deps[comp] = set()
        
        layers = []
        remaining = set(all_components)
        
        while remaining:
            # Find components with no remaining dependencies
            ready = set()
            for comp in remaining:
                if not deps[comp] or not deps[comp].intersection(remaining):
                    ready.add(comp)
            
            if not ready:
                # Break circular dependencies by picking components with fewest dependencies
                min_deps = min(len(deps[comp].intersection(remaining)) for comp in remaining)
                ready = {comp for comp in remaining if len(deps[comp].intersection(remaining)) == min_deps}
                print(f"  ⚠️  Breaking circular dependency with {len(ready)} components")
            
            layers.append(sorted(ready))
            remaining -= ready
            
            # Remove resolved components from dependencies
            for comp in remaining:
                deps[comp] -= ready
        
        self.build_layers = layers
        print(f"  ✓ Computed {len(layers)} build layers")
        
        for i, layer in enumerate(layers):
            print(f"    Layer {i+1}: {len(layer)} components")
    
    def generate_parallel_groups(self):
        """Generate parallel build groups within layers"""
        print("⚡ Generating parallel build groups...")
        
        self.parallel_groups = []
        
        for layer_num, layer in enumerate(self.build_layers):
            if len(layer) <= 1:
                # Single component, no parallelization needed
                self.parallel_groups.append([layer])
            else:
                # Multiple components, check for internal dependencies
                layer_deps = {}
                for comp in layer:
                    layer_deps[comp] = self.dependencies[comp].intersection(set(layer))
                
                # Group components that can be built in parallel
                groups = []
                remaining = set(layer)
                
                while remaining:
                    # Find components with no dependencies within the layer
                    parallel_group = []
                    for comp in list(remaining):
                        if not layer_deps[comp].intersection(remaining):
                            parallel_group.append(comp)
                    
                    if not parallel_group:
                        # If no components are ready, take one arbitrarily
                        parallel_group = [list(remaining)[0]]
                    
                    groups.append(sorted(parallel_group))
                    remaining -= set(parallel_group)
                    
                    # Update dependencies
                    for comp in remaining:
                        layer_deps[comp] -= set(parallel_group)
                
                self.parallel_groups.append(groups)
        
        total_groups = sum(len(groups) for groups in self.parallel_groups)
        print(f"  ✓ Generated {total_groups} parallel build groups")
    
    def generate_build_scripts(self) -> Dict[str, str]:
        """Generate build scripts for different scenarios"""
        print("📜 Generating build scripts...")
        
        scripts = {}
        
        # Sequential build script
        scripts['sequential'] = self._generate_sequential_script()
        
        # Parallel build script
        scripts['parallel'] = self._generate_parallel_script()
        
        # CMake superbuild script
        scripts['cmake_superbuild'] = self._generate_cmake_superbuild()
        
        # CircleCI workflow
        scripts['circleci_workflow'] = self._generate_circleci_workflow()
        
        return scripts
    
    def _generate_sequential_script(self) -> str:
        """Generate sequential build script"""
        script = [
            "#!/bin/bash",
            "#",
            "# OpenCog Central Sequential Build Script",
            "# Builds all components in correct dependency order",
            "#",
            "",
            "set -e  # Exit on error",
            "",
            "echo \"🚀 Starting OpenCog Central sequential build...\"",
            "",
            "# Build configuration",
            "BUILD_TYPE=${BUILD_TYPE:-Release}",
            "INSTALL_PREFIX=${INSTALL_PREFIX:-/usr/local}",
            "PARALLEL_JOBS=${PARALLEL_JOBS:-$(nproc)}",
            "",
            "build_component() {",
            "    local component=$1",
            "    local path=$2",
            "    ",
            "    echo \"🔧 Building $component...\"",
            "    if [ -f \"$path/CMakeLists.txt\" ]; then",
            "        cd \"$path\"",
            "        mkdir -p build && cd build",
            "        cmake .. \\",
            "            -DCMAKE_BUILD_TYPE=\"$BUILD_TYPE\" \\",
            "            -DCMAKE_INSTALL_PREFIX=\"$INSTALL_PREFIX\" \\",
            "            -DCMAKE_PREFIX_PATH=\"$INSTALL_PREFIX\"",
            "        make -j\"$PARALLEL_JOBS\"",
            "        make install",
            "        ldconfig",
            "        cd ../..  # Return to repo root",
            "        echo \"✅ $component built successfully\"",
            "    else",
            "        echo \"⚠️  No CMakeLists.txt found for $component, skipping\"",
            "    fi",
            "}",
            "",
        ]
        
        for layer_num, layer in enumerate(self.build_layers):
            script.append(f"# Layer {layer_num + 1}: {len(layer)} components")
            for component in layer:
                path = self._get_component_path(component)
                if path:
                    script.append(f"build_component \"{component}\" \"{path}\"")
            script.append("")
        
        script.extend([
            "echo \"✅ OpenCog Central sequential build completed successfully!\"",
            "echo \"📊 Built {len([comp for layer in self.build_layers for comp in layer])} components in {len(self.build_layers)} layers\"",
        ])
        
        return '\n'.join(script)
    
    def _generate_parallel_script(self) -> str:
        """Generate parallel build script"""
        script = [
            "#!/bin/bash",
            "#",
            "# OpenCog Central Parallel Build Script", 
            "# Builds components in parallel where possible",
            "#",
            "",
            "set -e",
            "",
            "echo \"🚀 Starting OpenCog Central parallel build...\"",
            "",
            "# Build configuration",
            "BUILD_TYPE=${BUILD_TYPE:-Release}",
            "INSTALL_PREFIX=${INSTALL_PREFIX:-/usr/local}",
            "PARALLEL_JOBS=${PARALLEL_JOBS:-$(nproc)}",
            "",
            "build_component() {",
            "    local component=$1",
            "    local path=$2",
            "    ",
            "    echo \"🔧 Building $component...\"",
            "    if [ -f \"$path/CMakeLists.txt\" ]; then",
            "        cd \"$path\"",
            "        mkdir -p build && cd build",
            "        cmake .. \\",
            "            -DCMAKE_BUILD_TYPE=\"$BUILD_TYPE\" \\",
            "            -DCMAKE_INSTALL_PREFIX=\"$INSTALL_PREFIX\" \\",
            "            -DCMAKE_PREFIX_PATH=\"$INSTALL_PREFIX\"",
            "        make -j\"$PARALLEL_JOBS\"",
            "        make install",
            "        ldconfig",
            "        cd ../..  # Return to repo root",
            "        echo \"✅ $component built successfully\"",
            "    else",
            "        echo \"⚠️  No CMakeLists.txt found for $component, skipping\"",
            "    fi",
            "}",
            "",
        ]
        
        for layer_num, groups in enumerate(self.parallel_groups):
            script.append(f"# Layer {layer_num + 1}: {len(groups)} parallel groups")
            
            for group_num, group in enumerate(groups):
                if len(group) == 1:
                    component = group[0]
                    path = self._get_component_path(component)
                    if path:
                        script.append(f"build_component \"{component}\" \"{path}\"")
                else:
                    script.append(f"# Parallel group {group_num + 1}: {len(group)} components")
                    pids = []
                    for component in group:
                        path = self._get_component_path(component)
                        if path:
                            script.append(f"build_component \"{component}\" \"{path}\" &")
                            pids.append(component)
                    
                    if pids:
                        script.append("wait  # Wait for parallel builds to complete")
            
            script.append("")
        
        script.extend([
            "echo \"✅ OpenCog Central parallel build completed successfully!\"",
            f"echo \"📊 Built components in {len(self.build_layers)} layers with parallelization\"",
        ])
        
        return '\n'.join(script)
    
    def _generate_cmake_superbuild(self) -> str:
        """Generate CMake superbuild configuration"""
        cmake = [
            "# OpenCog Central SuperBuild CMakeLists.txt",
            "# Builds all components in correct dependency order",
            "",
            "CMAKE_MINIMUM_REQUIRED(VERSION 3.16)",
            "PROJECT(OpenCogCentral)",
            "",
            "# Build configuration",
            "SET(CMAKE_BUILD_TYPE Release CACHE STRING \"Build type\")",
            "SET(CMAKE_INSTALL_PREFIX /usr/local CACHE PATH \"Install prefix\")",
            "",
            "# Include ExternalProject module",
            "INCLUDE(ExternalProject)",
            "",
            "# Common CMake arguments",
            "SET(COMMON_CMAKE_ARGS",
            "    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}",
            "    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}",
            "    -DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}",
            ")",
            "",
        ]
        
        # Add external projects for each component
        for layer_num, layer in enumerate(self.build_layers):
            cmake.append(f"# Layer {layer_num + 1} components")
            
            for component in layer:
                path = self._get_component_path(component)
                if path and (Path(self.repo_root) / path / "CMakeLists.txt").exists():
                    safe_name = component.replace('-', '_')
                    deps = list(self.dependencies.get(component, set()))
                    safe_deps = [dep.replace('-', '_') for dep in deps if dep in [c for l in self.build_layers[:layer_num] for c in l]]
                    
                    cmake.extend([
                        f"ExternalProject_Add({safe_name}",
                        f"    SOURCE_DIR ${{CMAKE_CURRENT_SOURCE_DIR}}/{path}",
                        f"    CMAKE_ARGS ${{COMMON_CMAKE_ARGS}}",
                        f"    BUILD_ALWAYS ON",
                    ])
                    
                    if safe_deps:
                        cmake.append(f"    DEPENDS {' '.join(safe_deps)}")
                    
                    cmake.extend([
                        ")",
                        ""
                    ])
        
        return '\n'.join(cmake)
    
    def _generate_circleci_workflow(self) -> str:
        """Generate CircleCI workflow configuration"""
        workflow = [
            "# OpenCog Central CircleCI Workflow",
            "# Add to .circleci/config.yml",
            "",
            "workflows:",
            "  version: 2",
            "  opencog_ecosystem_build:",
            "    jobs:",
        ]
        
        for layer_num, layer in enumerate(self.build_layers):
            for component in layer:
                deps = list(self.dependencies.get(component, set()))
                # Only include dependencies from previous layers
                valid_deps = [dep for dep in deps if dep in [c for l in self.build_layers[:layer_num] for c in l]]
                
                workflow.append(f"      - {component}:")
                if valid_deps:
                    workflow.append("          requires:")
                    for dep in valid_deps:
                        workflow.append(f"            - {dep}")
        
        return '\n'.join(workflow)
    
    def _get_component_path(self, component: str) -> str:
        """Get the relative path to a component"""
        components = self.audit_data.get('components', {})
        for category, category_components in components.items():
            if component in category_components:
                comp_info = category_components[component]
                path = comp_info.get('path', '')
                if path.startswith(str(self.repo_root)):
                    return path[len(str(self.repo_root)) + 1:]  # Remove repo root and leading slash
                return path
        
        # Fallback: try to find in known locations
        for orc_dir in Path(self.repo_root).glob("orc-*"):
            comp_path = orc_dir / component
            if comp_path.exists():
                return str(comp_path.relative_to(self.repo_root))
        
        return ""
    
    def generate_build_plan_documentation(self) -> str:
        """Generate comprehensive build plan documentation"""
        print("📝 Generating build plan documentation...")
        
        content = [
            "# OpenCog Central Build Order Plan",
            "",
            "**Definitive build order based on dependency analysis**",
            "",
            f"This plan is generated from analysis of {len(self.dependencies)} components",
            "across the OpenCog ecosystem, considering README specifications,",
            "CMakeLists.txt dependencies, and CircleCI requirements.",
            "",
            f"*Generated: {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*",
            "",
            "## 🎯 Build Strategy",
            "",
            f"- **Total Components**: {sum(len(layer) for layer in self.build_layers)}",
            f"- **Build Layers**: {len(self.build_layers)}",
            f"- **Parallel Groups**: {sum(len(groups) for groups in self.parallel_groups)}",
            "",
            "### Layer-by-Layer Breakdown",
            "",
        ]
        
        for layer_num, layer in enumerate(self.build_layers):
            content.extend([
                f"#### Layer {layer_num + 1} ({len(layer)} components)",
                "",
                "**Components**: " + ", ".join(f"`{comp}`" for comp in layer),
                "",
            ])
            
            if layer_num < len(self.parallel_groups):
                groups = self.parallel_groups[layer_num]
                if len(groups) > 1:
                    content.append("**Parallel Groups**:")
                    for group_num, group in enumerate(groups):
                        content.append(f"- Group {group_num + 1}: {', '.join(f'`{comp}`' for comp in group)}")
                    content.append("")
        
        content.extend([
            "## 🔧 Build Scripts",
            "",
            "### Quick Start",
            "",
            "```bash",
            "# Make scripts executable",
            "chmod +x build_sequential.sh build_parallel.sh",
            "",
            "# Sequential build (safest)",
            "./build_sequential.sh",
            "",
            "# Parallel build (faster)",
            "./build_parallel.sh",
            "```",
            "",
            "### Manual Build Commands",
            "",
        ])
        
        # Add manual build commands for each layer
        for layer_num, layer in enumerate(self.build_layers):
            content.extend([
                f"#### Layer {layer_num + 1}",
                "",
                "```bash",
            ])
            
            for component in layer:
                path = self._get_component_path(component)
                if path:
                    content.extend([
                        f"# Build {component}",
                        f"cd {path}",
                        "mkdir -p build && cd build",
                        "cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local",
                        "make -j$(nproc) && make install && ldconfig",
                        "cd ../..",
                        "",
                    ])
            
            content.extend([
                "```",
                "",
            ])
        
        content.extend([
            "## ⚡ Performance Optimization",
            "",
            "### Estimated Build Times",
            "",
            f"- **Sequential**: ~{len(self.build_layers) * 15} minutes (estimated)",
        ])
        
        if self.parallel_groups:
            max_groups = max(len(groups) for groups in self.parallel_groups)
            time_savings = ((len(self.build_layers) - max_groups) / len(self.build_layers)) * 100
            content.extend([
                f"- **Parallel**: ~{max_groups * 15} minutes (estimated)",
                f"- **Time Savings**: ~{time_savings:.1f}% reduction",
            ])
        else:
            content.extend([
                "- **Parallel**: Same as sequential (no parallelization available)",
                "- **Time Savings**: 0% reduction",
            ])
        
        content.extend([
            "",
            "### Resource Requirements",
            "",
            "- **CPU**: Minimum 4 cores recommended for parallel builds",
            "- **Memory**: 8GB RAM minimum, 16GB recommended",
            "- **Disk**: 5GB free space for builds",
            "",
            "## 🔍 Dependency Analysis",
            "",
            "### Critical Dependencies",
            "",
        ]
        
        # Add critical dependency analysis
        critical_components = ['cogutil', 'atomspace', 'ure', 'cogserver', 'opencog']
        for comp in critical_components:
            if comp in self.dependencies:
                deps = self.dependencies[comp]
                dependents = [c for c, d in self.dependencies.items() if comp in d]
                content.extend([
                    f"- **{comp}**: Required by {len(dependents)} components",
                    f"  - Dependencies: {', '.join(f'`{d}`' for d in sorted(deps)) if deps else 'None'}",
                    f"  - Dependents: {len(dependents)} components",
                ])
        
        content.extend([
            "",
            "---",
            "",
            f"*This build plan ensures correct dependency order for {sum(len(layer) for layer in self.build_layers)} components*",
        ])
        
        return '\n'.join(content)
    
    def save_build_plan(self, output_dir: str = "."):
        """Save build plan and scripts"""
        output_path = Path(output_dir)
        
        print("💾 Saving build plan and scripts...")
        
        # Generate all content
        self.extract_dependencies()
        self.compute_build_layers()
        self.generate_parallel_groups()
        
        scripts = self.generate_build_scripts()
        documentation = self.generate_build_plan_documentation()
        
        # Save documentation
        doc_file = output_path / "BUILD_ORDER_PLAN.md"
        with open(doc_file, 'w', encoding='utf-8') as f:
            f.write(documentation)
        
        # Save scripts
        script_files = {
            'build_sequential.sh': scripts['sequential'],
            'build_parallel.sh': scripts['parallel'],
            'CMakeLists_superbuild.txt': scripts['cmake_superbuild'],
            'circleci_workflow.yml': scripts['circleci_workflow']
        }
        
        for filename, content in script_files.items():
            script_file = output_path / filename
            with open(script_file, 'w', encoding='utf-8') as f:
                f.write(content)
            
            # Make shell scripts executable
            if filename.endswith('.sh'):
                script_file.chmod(0o755)
        
        print(f"✅ Build plan saved:")
        print(f"  📄 Documentation: {doc_file}")
        for filename in script_files:
            print(f"  📜 Script: {output_path / filename}")
        
        return doc_file

def main():
    """Main execution function"""
    repo_root = "/home/runner/work/opencog-central/opencog-central"
    audit_file = "component_audit_report.json"
    
    generator = BuildOrderGenerator(repo_root, audit_file)
    
    print("🚀 Generating Build Order Plan for OpenCog Central")
    print("=" * 55)
    
    output_file = generator.save_build_plan()
    
    print(f"\n📊 Build Plan Summary:")
    print(f"  🏗️ Build layers: {len(generator.build_layers)}")
    print(f"  ⚡ Parallel groups: {sum(len(groups) for groups in generator.parallel_groups)}")
    print(f"  🔧 Components: {sum(len(layer) for layer in generator.build_layers)}")
    
    print(f"\n✅ Build order plan generation completed successfully!")

if __name__ == "__main__":
    main()