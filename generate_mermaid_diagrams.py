#!/usr/bin/env python3
"""
Mermaid Dependency Diagram Generator for OpenCog Central
=======================================================

This script generates comprehensive mermaid diagrams showing dependency pathways
based on README specifications, CMakeLists.txt analysis, and build order requirements.
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Set, Tuple
from collections import defaultdict, deque

class MermaidDiagramGenerator:
    def __init__(self, repo_root: str, audit_file: str):
        self.repo_root = Path(repo_root)
        self.audit_file = audit_file
        self.audit_data = self._load_audit_data()
        self.dependencies = defaultdict(set)
        self.reverse_dependencies = defaultdict(set)
        
    def _load_audit_data(self) -> Dict:
        """Load audit data from JSON file"""
        try:
            with open(self.audit_file, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"⚠️  Warning: Could not load audit data: {e}")
            return {}
    
    def analyze_dependencies(self):
        """Analyze dependencies from all sources"""
        print("🔍 Analyzing dependencies from all sources...")
        
        # Extract dependencies from audit data
        components = self.audit_data.get('components', {})
        for category, category_components in components.items():
            for comp_name, comp_info in category_components.items():
                deps = comp_info.get('dependencies', [])
                for dep in deps:
                    # Normalize dependency names
                    normalized_dep = self._normalize_component_name(dep)
                    if normalized_dep and normalized_dep != comp_name:
                        self.dependencies[comp_name].add(normalized_dep)
                        self.reverse_dependencies[normalized_dep].add(comp_name)
        
        # Add known critical dependencies from the ecosystem
        self._add_critical_dependencies()
        
        print(f"  ✓ Found {len(self.dependencies)} components with dependencies")
        print(f"  ✓ Total dependency relationships: {sum(len(deps) for deps in self.dependencies.values())}")
    
    def _normalize_component_name(self, name: str) -> str:
        """Normalize component names for consistency"""
        if not name or len(name) < 2:
            return ""
        
        # Common normalizations
        name = name.lower()
        name = re.sub(r'[^a-z0-9\-_]', '', name)
        
        # Map common variations
        mappings = {
            'atomspace': 'atomspace',
            'cogutil': 'cogutil',
            'cogserver': 'cogserver',
            'boost': 'boost',
            'cmake': 'cmake',
            'opencog': 'opencog',
            'ure': 'ure',
            'pln': 'pln',
            'moses': 'moses',
            'guile': 'guile',
            'python': 'python',
            'cython': 'cython'
        }
        
        for key, value in mappings.items():
            if key in name:
                return value
        
        return name if len(name) > 2 else ""
    
    def _add_critical_dependencies(self):
        """Add known critical dependencies from documentation and analysis"""
        critical_deps = {
            # Foundation level
            'atomspace': ['cogutil'],
            'atomspace-rocks': ['atomspace', 'cogutil'],
            'atomspace-restful': ['atomspace', 'cogutil'],
            'atomspace-dht': ['atomspace', 'cogutil'],
            'atomspace-ipfs': ['atomspace', 'cogutil'],
            'atomspace-websockets': ['atomspace', 'cogutil'],
            
            # Logic level
            'unify': ['atomspace', 'cogutil'],
            'ure': ['atomspace', 'unify', 'cogutil'],
            
            # Cognitive level
            'cogserver': ['atomspace', 'cogutil'],
            'attention': ['atomspace', 'cogserver', 'cogutil'],
            'spacetime': ['atomspace', 'cogutil'],
            
            # Advanced level
            'pln': ['atomspace', 'ure', 'spacetime', 'cogutil'],
            'miner': ['atomspace', 'ure', 'cogutil'],
            'asmoses': ['atomspace', 'ure', 'cogutil'],
            
            # Learning level
            'learn': ['atomspace', 'cogserver', 'cogutil'],
            'generate': ['atomspace', 'cogutil'],
            
            # Language processing
            'lg-atomese': ['atomspace', 'cogutil'],
            'relex': ['cogutil'],
            'link-grammar': [],
            
            # Integration level
            'opencog': ['atomspace', 'cogserver', 'attention', 'ure', 'cogutil']
        }
        
        for component, deps in critical_deps.items():
            for dep in deps:
                self.dependencies[component].add(dep)
                self.reverse_dependencies[dep].add(component)
    
    def generate_complete_dependency_diagram(self) -> str:
        """Generate complete dependency diagram"""
        print("📊 Generating complete dependency diagram...")
        
        mermaid = [
            "```mermaid",
            "graph TD",
            "    %% OpenCog Central Complete Dependency Diagram",
            ""
        ]
        
        # Define styles for different layers
        mermaid.extend([
            "    %% Styling",
            "    classDef foundation fill:#e8f5e8,stroke:#4caf50,stroke-width:2px",
            "    classDef core fill:#e3f2fd,stroke:#2196f3,stroke-width:2px", 
            "    classDef logic fill:#fff3e0,stroke:#ff9800,stroke-width:2px",
            "    classDef cognitive fill:#f3e5f5,stroke:#9c27b0,stroke-width:2px",
            "    classDef advanced fill:#ffebee,stroke:#f44336,stroke-width:2px",
            "    classDef learning fill:#f1f8e9,stroke:#8bc34a,stroke-width:2px",
            "    classDef specialized fill:#e0f2f1,stroke:#009688,stroke-width:2px",
            "    classDef integration fill:#fce4ec,stroke:#e91e63,stroke-width:2px",
            ""
        ])
        
        # Get component classification
        classification = self.audit_data.get('component_classification', {})
        
        # Add node definitions with descriptions
        mermaid.append("    %% Node definitions")
        for layer, components in classification.items():
            if layer == 'unclassified':
                continue
            for comp in components:
                comp_name = comp['name']
                safe_name = self._make_safe_node_name(comp_name)
                display_name = comp_name.replace('-', '<br/>').replace('_', '<br/>')
                mermaid.append(f"    {safe_name}[\"{display_name}\"]")
        
        mermaid.append("")
        
        # Add dependency relationships
        mermaid.append("    %% Dependencies")
        added_edges = set()
        for component, deps in self.dependencies.items():
            safe_comp = self._make_safe_node_name(component)
            for dep in deps:
                safe_dep = self._make_safe_node_name(dep)
                edge = f"{safe_dep} --> {safe_comp}"
                if edge not in added_edges:
                    mermaid.append(f"    {edge}")
                    added_edges.add(edge)
        
        mermaid.append("")
        
        # Apply styles
        mermaid.append("    %% Apply styles")
        for layer, components in classification.items():
            if layer == 'unclassified':
                continue
            layer_class = layer
            for comp in components:
                safe_name = self._make_safe_node_name(comp['name'])
                mermaid.append(f"    class {safe_name} {layer_class}")
        
        mermaid.append("```")
        return '\n'.join(mermaid)
    
    def generate_critical_path_diagram(self) -> str:
        """Generate critical path diagram showing main build dependencies"""
        print("📊 Generating critical path diagram...")
        
        critical_components = [
            'cogutil', 'atomspace', 'unify', 'ure', 'cogserver', 
            'attention', 'spacetime', 'pln', 'miner', 'opencog'
        ]
        
        mermaid = [
            "```mermaid",
            "graph TD",
            "    %% Critical Build Path",
            ""
        ]
        
        # Add critical nodes
        for comp in critical_components:
            safe_name = self._make_safe_node_name(comp)
            display_name = comp.replace('-', '<br/>')
            mermaid.append(f"    {safe_name}[\"{display_name}\"]")
        
        mermaid.append("")
        
        # Add critical dependencies
        critical_deps = [
            ('cogutil', 'atomspace'),
            ('atomspace', 'unify'),
            ('atomspace', 'cogserver'),
            ('unify', 'ure'),
            ('atomspace', 'spacetime'),
            ('cogserver', 'attention'),
            ('ure', 'pln'),
            ('spacetime', 'pln'),
            ('ure', 'miner'),
            ('atomspace', 'opencog'),
            ('cogserver', 'opencog'),
            ('attention', 'opencog'),
            ('ure', 'opencog')
        ]
        
        for dep, comp in critical_deps:
            safe_dep = self._make_safe_node_name(dep)
            safe_comp = self._make_safe_node_name(comp)
            mermaid.append(f"    {safe_dep} --> {safe_comp}")
        
        mermaid.append("```")
        return '\n'.join(mermaid)
    
    def generate_category_overview_diagram(self) -> str:
        """Generate high-level category overview diagram"""
        print("📊 Generating category overview diagram...")
        
        categories = self.audit_data.get('summary', {}).get('components_by_category', {})
        
        mermaid = [
            "```mermaid",
            "graph TD",
            "    %% OpenCog Central Category Overview",
            ""
        ]
        
        # Category descriptions
        category_info = {
            'orc-dv': ('Foundation<br/>Development', 'Tools & Utilities'),
            'orc-as': ('Core<br/>AtomSpace', 'Knowledge Representation'),
            'orc-ai': ('Advanced<br/>AI Systems', 'Learning & Reasoning'),
            'orc-ct': ('Cognitive<br/>Tools', 'Mental Processes'),
            'orc-sv': ('Servers<br/>& Agents', 'Distributed Systems'),
            'orc-nl': ('Natural<br/>Language', 'Text Processing'),
            'orc-ro': ('Robotics<br/>& Vision', 'Embodied AI'),
            'orc-bi': ('Bio<br/>informatics', 'Life Sciences'),
            'orc-em': ('Emotion<br/>AI', 'Affective Computing'),
            'orc-wb': ('Web<br/>& APIs', 'Interfaces'),
            'orc-gm': ('Games<br/>& VR', 'Virtual Environments'),
            'orc-in': ('Infrastructure<br/>& Deploy', 'Operations'),
            'orc-oc': ('Integration<br/>OpenCog', 'Main Framework')
        }
        
        # Add category nodes
        for category, count_info in categories.items():
            if category in category_info:
                safe_name = self._make_safe_node_name(category)
                display_name, desc = category_info[category]
                count = count_info['count']
                mermaid.append(f"    {safe_name}[\"{display_name}<br/>{desc}<br/>({count} components)\"]")
        
        mermaid.append("")
        
        # Add category dependencies (simplified)
        category_deps = [
            ('orc-dv', 'orc-as'),
            ('orc-as', 'orc-ai'),
            ('orc-as', 'orc-ct'),
            ('orc-ct', 'orc-sv'),
            ('orc-ai', 'orc-oc'),
            ('orc-sv', 'orc-oc'),
            ('orc-as', 'orc-nl'),
            ('orc-as', 'orc-ro'),
            ('orc-as', 'orc-bi'),
            ('orc-oc', 'orc-wb'),
            ('orc-oc', 'orc-gm'),
            ('orc-oc', 'orc-in')
        ]
        
        for dep, comp in category_deps:
            safe_dep = self._make_safe_node_name(dep)
            safe_comp = self._make_safe_node_name(comp)
            mermaid.append(f"    {safe_dep} --> {safe_comp}")
        
        mermaid.append("```")
        return '\n'.join(mermaid)
    
    def generate_build_order_timeline(self) -> str:
        """Generate build order timeline diagram"""
        print("📊 Generating build order timeline...")
        
        mermaid = [
            "```mermaid",
            "gantt",
            "    title OpenCog Central Build Timeline",
            "    dateFormat X",
            "    axisFormat %s",
            ""
        ]
        
        # Define build phases
        phases = [
            ("Foundation", ["cogutil", "moses"], 0, 100),
            ("Core", ["atomspace", "atomspace-rocks", "atomspace-restful"], 100, 200), 
            ("Logic", ["unify", "ure"], 200, 250),
            ("Cognitive", ["cogserver", "attention", "spacetime"], 250, 350),
            ("Advanced", ["pln", "miner", "asmoses"], 350, 450),
            ("Learning", ["learn", "generate"], 450, 500),
            ("Language", ["lg-atomese", "relex", "link-grammar"], 300, 400),
            ("Robotics", ["vision", "perception", "sensory"], 300, 400),
            ("Integration", ["opencog"], 500, 600),
            ("Packaging", ["opencog-debian", "opencog-nix"], 600, 650)
        ]
        
        for phase_name, components, start, end in phases:
            mermaid.append(f"    section {phase_name}")
            for comp in components:
                mermaid.append(f"    {comp} :{comp}, {start}, {end}")
        
        mermaid.append("```")
        return '\n'.join(mermaid)
    
    def _make_safe_node_name(self, name: str) -> str:
        """Make node name safe for mermaid"""
        return re.sub(r'[^a-zA-Z0-9]', '_', name)
    
    def generate_all_diagrams(self) -> Dict[str, str]:
        """Generate all diagram types"""
        self.analyze_dependencies()
        
        diagrams = {
            "complete_dependency": self.generate_complete_dependency_diagram(),
            "critical_path": self.generate_critical_path_diagram(),
            "category_overview": self.generate_category_overview_diagram(),
            "build_timeline": self.generate_build_order_timeline()
        }
        
        return diagrams
    
    def save_diagrams(self, output_file: str = "MERMAID_DIAGRAMS.md"):
        """Save all diagrams to markdown file"""
        print(f"💾 Generating comprehensive mermaid diagrams...")
        
        diagrams = self.generate_all_diagrams()
        
        content = [
            "# OpenCog Central Dependency Diagrams",
            "",
            "This document contains comprehensive dependency diagrams for the OpenCog Central ecosystem,",
            "generated from README specifications and CMakeLists.txt analysis.",
            "",
            "## Complete Dependency Diagram",
            "",
            "Shows all components and their dependencies across the entire ecosystem:",
            "",
            diagrams["complete_dependency"],
            "",
            "## Critical Build Path",
            "",
            "Shows the critical path through core components that define the build order:",
            "",
            diagrams["critical_path"],
            "",
            "## Category Overview",
            "",
            "High-level view of functional categories and their relationships:",
            "",
            diagrams["category_overview"],
            "",
            "## Build Order Timeline",
            "",
            "Timeline showing parallel build opportunities and sequential dependencies:",
            "",
            diagrams["build_timeline"],
            "",
            "---",
            "",
            f"*Generated automatically from {len(self.dependencies)} components*  ",
            f"*Last updated: {__import__('datetime').datetime.now().strftime('%Y-%m-%d')}*"
        ]
        
        output_path = self.repo_root / output_file
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(content))
        
        print(f"✅ Mermaid diagrams saved to {output_path}")
        return output_path

def main():
    """Main execution function"""
    repo_root = "/home/runner/work/opencog-central/opencog-central"
    audit_file = "component_audit_report.json"
    
    generator = MermaidDiagramGenerator(repo_root, audit_file)
    
    print("🚀 Generating Mermaid Dependency Diagrams")
    print("=" * 50)
    
    output_path = generator.save_diagrams()
    
    print(f"\n📊 Generation Summary:")
    print(f"  🔗 Dependencies analyzed: {len(generator.dependencies)}")
    print(f"  📄 Output file: {output_path}")
    
    print(f"\n✅ Mermaid diagram generation completed successfully!")

if __name__ == "__main__":
    main()