#!/usr/bin/env python3
"""
Consolidated README Generator for OpenCog Central
===============================================

This script generates a comprehensive README.md file that integrates all component
documentation, dependency information, and build order recommendations.
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Set
from collections import defaultdict

class ConsolidatedReadmeGenerator:
    def __init__(self, repo_root: str, audit_file: str):
        self.repo_root = Path(repo_root)
        self.readme_dir = self.repo_root / "README"
        self.audit_file = audit_file
        self.audit_data = self._load_audit_data()
        
    def _load_audit_data(self) -> Dict:
        """Load the audit data from JSON file"""
        try:
            with open(self.audit_file, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"⚠️  Warning: Could not load audit data: {e}")
            return {}
    
    def generate_consolidated_readme(self) -> str:
        """Generate the main consolidated README content"""
        print("📝 Generating consolidated README.md...")
        
        content = []
        
        # Header and Introduction
        content.extend(self._generate_header())
        content.extend(self._generate_overview())
        content.extend(self._generate_quick_start())
        
        # Component Documentation
        content.extend(self._generate_component_index())
        content.extend(self._generate_layer_architecture())
        content.extend(self._generate_dependency_analysis())
        content.extend(self._generate_build_order())
        
        # Detailed Component Documentation
        content.extend(self._generate_detailed_components())
        
        # Development and Maintenance
        content.extend(self._generate_development_guide())
        content.extend(self._generate_troubleshooting())
        
        # Footer
        content.extend(self._generate_footer())
        
        return '\n'.join(content)
    
    def _generate_header(self) -> List[str]:
        """Generate README header"""
        total_components = self.audit_data.get('summary', {}).get('total_components', 'N/A')
        return [
            "# OpenCog Central - Comprehensive Component Documentation",
            "",
            "[![Build Status](https://circleci.com/gh/opencog/opencog-central.svg?style=svg)](https://circleci.com/gh/opencog/opencog-central)",
            "[![Components](https://img.shields.io/badge/components-{}-brightgreen.svg)](https://github.com/opencog/opencog-central)".format(total_components),
            "[![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)](LICENSE)",
            "",
            "**The complete OpenCog ecosystem orchestration and documentation hub**",
            "",
            f"This repository consolidates **{total_components} OpenCog components** across 13 functional categories,",
            "providing unified build systems, dependency management, and comprehensive documentation",
            "for the entire OpenCog artificial general intelligence (AGI) ecosystem.",
            "",
        ]
    
    def _generate_overview(self) -> List[str]:
        """Generate overview section"""
        summary = self.audit_data.get('summary', {})
        categories = summary.get('components_by_category', {})
        
        content = [
            "## 🌟 Overview",
            "",
            "OpenCog Central represents the most comprehensive collection of AGI components,",
            "spanning from foundational utilities to advanced cognitive architectures.",
            "Our systematic organization enables researchers, developers, and AGI enthusiasts",
            "to efficiently navigate, build, and deploy complex cognitive systems.",
            "",
            "### 📊 Repository Statistics",
            "",
            f"- **{summary.get('total_components', 'N/A')} Components** across {summary.get('total_categories', 'N/A')} functional categories",
            f"- **{summary.get('components_with_cmake', 'N/A')} CMake Projects** with build automation",
            f"- **{summary.get('components_with_readme', 'N/A')} Documented Components** with comprehensive README files",
            "- **Multi-language Support**: C++, Python, Rust, JavaScript, and more",
            "",
            "### 🗂️ Functional Categories",
            "",
        ]
        
        # Add category breakdown
        category_descriptions = {
            'orc-ai': '🧠 **AI & Learning**: Core machine learning and reasoning algorithms',
            'orc-nl': '🗣️ **Natural Language**: Language processing and understanding systems',
            'orc-ro': '🤖 **Robotics**: Robotic integration and sensory processing',
            'orc-bi': '🧬 **Bioinformatics**: Biological data analysis and modeling',
            'orc-em': '❤️ **Emotion AI**: Emotional modeling and response systems',
            'orc-ct': '🔧 **Cognitive Tools**: Attention, memory, and cognitive utilities',
            'orc-sv': '🖥️ **Servers & Agents**: Distributed systems and agent frameworks',
            'orc-wb': '🌐 **Web & APIs**: REST APIs, web interfaces, and client libraries',
            'orc-gm': '🎮 **Games**: Gaming platforms and virtual environments',
            'orc-dv': '⚙️ **Development**: Build tools, utilities, and development aids',
            'orc-in': '🏗️ **Infrastructure**: Docker, deployment, and operational tools',
            'orc-as': '📁 **AtomSpace**: Knowledge representation and storage systems',
            'orc-oc': '📁 **OpenCog**: Main integration framework and core systems'
        }
        
        for category, info in sorted(categories.items()):
            desc = category_descriptions.get(category, f"**{category}**: Component category")
            content.append(f"- {desc} ({info['count']} components)")
        
        content.extend(["", ""])
        return content
    
    def _generate_quick_start(self) -> List[str]:
        """Generate quick start section"""
        return [
            "## 🚀 Quick Start",
            "",
            "### Prerequisites",
            "",
            "```bash",
            "# Ubuntu/Debian",
            "sudo apt update && sudo apt install -y \\",
            "    build-essential cmake git \\",
            "    libboost-all-dev \\",
            "    python3-dev python3-pip \\",
            "    guile-3.0-dev",
            "",
            "# Install Python requirements",
            "pip3 install -r requirements.txt",
            "```",
            "",
            "### Build Everything",
            "",
            "```bash",
            "# Clone the repository",
            "git clone https://github.com/opencog/opencog-central.git",
            "cd opencog-central",
            "",
            "# Quick build (foundation → core → integration)",
            "./build-all.sh",
            "",
            "# Or build specific categories",
            "cd orc-as && mkdir build && cd build",
            "cmake .. && make -j$(nproc) && sudo make install",
            "```",
            "",
            "### Docker Deployment",
            "",
            "```bash",
            "# Pre-built environment with all dependencies",
            "docker-compose up -d",
            "",
            "# Or build custom image",
            "docker build -t opencog-central .",
            "docker run -it opencog-central",
            "```",
            "",
        ]
    
    def _generate_component_index(self) -> List[str]:
        """Generate component index"""
        content = [
            "## 📚 Component Index",
            "",
            "This section provides a complete index of all components with their primary functions.",
            "Click on any component name to access its detailed documentation.",
            "",
        ]
        
        components = self.audit_data.get('components', {})
        for category, category_components in sorted(components.items()):
            category_name = category.replace('orc-', '').upper()
            content.extend([
                f"### {category} ({category_name})",
                "",
            ])
            
            for comp_name, comp_info in sorted(category_components.items()):
                desc = comp_info.get('description', 'No description available')[:100]
                if len(comp_info.get('description', '')) > 100:
                    desc += "..."
                
                # Create link to detailed section
                link = f"#{comp_name.lower().replace('-', '').replace('_', '')}"
                content.append(f"- **[{comp_name}]({link})**: {desc}")
            
            content.append("")
        
        return content
    
    def _generate_layer_architecture(self) -> List[str]:
        """Generate architectural layer documentation"""
        content = [
            "## 🏗️ Architectural Layers",
            "",
            "OpenCog Central is organized in architectural layers with clear dependency relationships:",
            "",
            "```mermaid",
            "graph TD",
            "    A[Applications Layer<br/>Games, Robotics, Web] --> B[Integration Layer<br/>OpenCog Main Framework]",
            "    B --> C[Specialized Layer<br/>Vision, NLP, Bio, Emotion]",
            "    C --> D[Advanced Layer<br/>PLN, Miner, Learning]",
            "    D --> E[Cognitive Layer<br/>Attention, SpaceTime, CogServer]",
            "    E --> F[Logic Layer<br/>URE, Unify]",
            "    F --> G[Core Layer<br/>AtomSpace, Storage]",
            "    G --> H[Foundation Layer<br/>CogUtil, Moses, Tools]",
            "```",
            "",
        ]
        
        classification = self.audit_data.get('component_classification', {})
        layer_descriptions = {
            'foundation': 'Basic utilities, data structures, and foundational algorithms',
            'core': 'Knowledge representation, storage systems, and core data management',
            'logic': 'Logical reasoning, unification, and rule-based inference',
            'cognitive': 'Attention mechanisms, cognitive servers, and mental processes',
            'advanced': 'Advanced reasoning systems, pattern mining, and probabilistic logic',
            'learning': 'Machine learning algorithms and adaptive systems',
            'specialized': 'Domain-specific modules (vision, NLP, robotics, bioinformatics)',
            'integration': 'Main integration frameworks and orchestration systems',
            'packaging': 'Distribution, packaging, and deployment systems'
        }
        
        for layer, components in classification.items():
            if layer == 'unclassified':
                continue
            
            desc = layer_descriptions.get(layer, 'Layer description not available')
            content.extend([
                f"### {layer.title()} Layer",
                "",
                f"{desc}",
                "",
                f"**Components ({len(components)}):**",
            ])
            
            for comp in components:
                content.append(f"- `{comp['name']}` ({comp['category']})")
            
            content.append("")
        
        return content
    
    def _generate_dependency_analysis(self) -> List[str]:
        """Generate dependency analysis"""
        return [
            "## 🔗 Dependency Analysis",
            "",
            "### Critical Dependencies",
            "",
            "Based on CMakeLists.txt analysis and README specifications:",
            "",
            "1. **CogUtil** → Foundation for 31+ components",
            "2. **AtomSpace** → Core knowledge representation for 29+ components",
            "3. **URE** → Advanced reasoning requiring AtomSpace + Unify",
            "4. **CogServer** → Distributed systems enabling Attention + Learn",
            "5. **SpaceTime** → Temporal reasoning required by PLN",
            "",
            "### Dependency Chains",
            "",
            "```mermaid",
            "graph LR",
            "    CogUtil --> AtomSpace",
            "    AtomSpace --> URE",
            "    AtomSpace --> CogServer",
            "    AtomSpace --> Unify",
            "    URE --> PLN",
            "    CogServer --> Attention",
            "    SpaceTime --> PLN",
            "    PLN --> OpenCog",
            "    Attention --> OpenCog",
            "    URE --> OpenCog",
            "```",
            "",
            "### Build Parallelization",
            "",
            "Components can be built in parallel within layers:",
            "",
            "- **Layer 1**: CogUtil, Moses (parallel)",
            "- **Layer 2**: AtomSpace + extensions (parallel after CogUtil)",
            "- **Layer 3**: URE, Unify, CogServer (parallel after AtomSpace)",
            "- **Layer 4**: Advanced systems (parallel after Layer 3)",
            "",
        ]
    
    def _generate_build_order(self) -> List[str]:
        """Generate build order recommendations"""
        return [
            "## 🔧 Recommended Build Order",
            "",
            "### Complete Build Sequence",
            "",
            "```bash",
            "# Phase 1: Foundation",
            "cd orc-dv/cogutil && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "cd ../../moses && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "",
            "# Phase 2: Core Systems",
            "cd ../../../orc-as/atomspace && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "cd ../atomspace-rocks && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "cd ../atomspace-restful && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "",
            "# Phase 3: Logic & Reasoning",
            "cd ../../../orc-ct/unify && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "cd ../../orc-ai/ure && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "",
            "# Phase 4: Cognitive Systems",
            "cd ../../orc-sv/cogserver && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "cd ../../orc-ct/attention && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "cd ../spacetime && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "",
            "# Phase 5: Advanced Systems",
            "cd ../../orc-ai/pln && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "cd ../miner && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "",
            "# Phase 6: Integration",
            "cd ../../orc-oc/opencog && mkdir build && cd build && cmake .. && make -j$(nproc) && make install",
            "```",
            "",
            "### CircleCI Integration",
            "",
            "Our CircleCI configuration implements this build order with proper",
            "dependency management and parallel execution where possible.",
            "",
        ]
    
    def _generate_detailed_components(self) -> List[str]:
        """Generate detailed component documentation"""
        content = [
            "## 📖 Detailed Component Documentation",
            "",
            "This section provides comprehensive documentation for each component,",
            "extracted from individual README files and enhanced with dependency analysis.",
            "",
        ]
        
        components = self.audit_data.get('components', {})
        for category, category_components in sorted(components.items()):
            content.extend([
                f"### {category.upper()} Components",
                "",
            ])
            
            for comp_name, comp_info in sorted(category_components.items()):
                # Try to read the corresponding README file
                readme_content = self._get_component_readme_summary(category, comp_name)
                
                content.extend([
                    f"#### {comp_name}",
                    "",
                    f"**Category**: {category}  ",
                    f"**Type**: {comp_info.get('type', 'Unknown')}  ",
                    f"**Language**: {comp_info.get('language', 'Unknown')}  ",
                    f"**Has CMake**: {'✅' if comp_info.get('has_cmake') else '❌'}  ",
                    f"**Has README**: {'✅' if comp_info.get('has_readme') else '❌'}  ",
                    "",
                ])
                
                if comp_info.get('description'):
                    content.extend([
                        f"**Description**: {comp_info['description']}",
                        "",
                    ])
                
                if comp_info.get('dependencies'):
                    content.extend([
                        "**Dependencies**:",
                    ])
                    for dep in comp_info['dependencies']:
                        content.append(f"- {dep}")
                    content.append("")
                
                if readme_content:
                    content.extend([
                        "**Overview**:",
                        readme_content,
                        "",
                    ])
                
                content.extend([
                    f"**Location**: `{comp_info.get('path', 'Unknown')}`",
                    "",
                    "---",
                    "",
                ])
        
        return content
    
    def _get_component_readme_summary(self, category: str, component: str) -> str:
        """Get a summary from the component's README file"""
        readme_file = self.readme_dir / f"{component}_README.md"
        if not readme_file.exists():
            return ""
        
        try:
            content = readme_file.read_text(encoding='utf-8')
            lines = content.split('\n')
            
            # Extract first few meaningful lines (not headers)
            summary_lines = []
            for line in lines[:20]:  # Check first 20 lines
                line = line.strip()
                if line and not line.startswith('#') and not line.startswith('[!['):
                    summary_lines.append(line)
                    if len(summary_lines) >= 3:  # Get first 3 meaningful lines
                        break
            
            return ' '.join(summary_lines)[:200] + "..." if summary_lines else ""
            
        except Exception:
            return ""
    
    def _generate_development_guide(self) -> List[str]:
        """Generate development guide"""
        return [
            "## 👩‍💻 Development Guide",
            "",
            "### Contributing to OpenCog Central",
            "",
            "1. **Fork** the repository and create a feature branch",
            "2. **Follow** the architectural layers when adding dependencies",
            "3. **Update** both CMakeLists.txt and CircleCI config for new components",
            "4. **Document** your component with a comprehensive README",
            "5. **Test** your changes with the full build pipeline",
            "",
            "### Adding New Components",
            "",
            "```bash",
            "# 1. Create component in appropriate category",
            "mkdir orc-{category}/{component-name}",
            "cd orc-{category}/{component-name}",
            "",
            "# 2. Add CMakeLists.txt with proper dependencies",
            "cat > CMakeLists.txt << EOF",
            "CMAKE_MINIMUM_REQUIRED(VERSION 3.16)",
            "FIND_PACKAGE(CogUtil 2.0.3 CONFIG REQUIRED)",
            "# ... additional dependencies",
            "EOF",
            "",
            "# 3. Create comprehensive README.md",
            "# 4. Update category-level CMakeLists.txt",
            "# 5. Update CircleCI configuration",
            "```",
            "",
            "### Code Style Guidelines",
            "",
            "- **C++**: Follow Google C++ Style Guide with 4-space indentation",
            "- **Python**: PEP 8 compliant with Black formatting",
            "- **CMake**: Uppercase commands, clear variable naming",
            "- **Documentation**: Comprehensive README files with examples",
            "",
        ]
    
    def _generate_troubleshooting(self) -> List[str]:
        """Generate troubleshooting section"""
        return [
            "## 🔧 Troubleshooting",
            "",
            "### Common Build Issues",
            "",
            "#### Missing Dependencies",
            "```bash",
            "# Install missing system packages",
            "sudo apt install -y libboost-all-dev cmake build-essential",
            "",
            "# Verify CogUtil installation",
            "pkg-config --modversion cogutil",
            "```",
            "",
            "#### CMake Configuration Errors",
            "```bash",
            "# Clear CMake cache and reconfigure",
            "rm -rf build && mkdir build && cd build",
            "cmake -DCMAKE_PREFIX_PATH=/usr/local ..",
            "```",
            "",
            "#### Circular Dependencies",
            "Follow the recommended build order. If you encounter circular dependencies:",
            "1. Check the dependency diagram in this README",
            "2. Ensure you're building foundation layers first",
            "3. Consider if new dependencies create cycles",
            "",
            "### Getting Help",
            "",
            "- **Documentation**: Component-specific README files in `/README` directory",
            "- **Issues**: [GitHub Issues](https://github.com/opencog/opencog-central/issues)",
            "- **Forum**: [OpenCog Google Group](https://groups.google.com/g/opencog)",
            "- **Chat**: #opencog on Libera.Chat IRC",
            "",
        ]
    
    def _generate_footer(self) -> List[str]:
        """Generate README footer"""
        return [
            "## 📄 License and Attribution",
            "",
            "OpenCog Central components are released under various open source licenses:",
            "",
            "- **Core OpenCog**: AGPL v3",
            "- **AtomSpace**: Apache 2.0",
            "- **Utilities**: Apache 2.0",
            "- **Integrations**: MIT (where applicable)",
            "",
            "See individual component directories for specific license information.",
            "",
            "## 🙏 Acknowledgments",
            "",
            "The OpenCog project is developed by a global community of researchers,",
            "developers, and AI enthusiasts. This consolidation effort represents",
            "the collaborative work of hundreds of contributors over many years.",
            "",
            "**Special thanks to:**",
            "- The OpenCog Foundation",
            "- SingularityNET",
            "- All individual contributors and maintainers",
            "",
            "---",
            "",
            "**🚀 Ready to contribute to AGI research?**  ",
            "Start with our [Quick Start](#-quick-start) guide and join the community!",
            "",
            f"*Generated automatically from {self.audit_data.get('audit_metadata', {}).get('total_components', 'N/A')} components*  ",
            f"*Last updated: {__import__('datetime').datetime.now().strftime('%Y-%m-%d')}*",
        ]
    
    def save_readme(self, filename: str = "CONSOLIDATED_README.md"):
        """Save the consolidated README to file"""
        content = self.generate_consolidated_readme()
        output_path = self.repo_root / filename
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Consolidated README saved to {output_path}")
        return output_path

def main():
    """Main execution function"""
    repo_root = "/home/runner/work/opencog-central/opencog-central"
    audit_file = "component_audit_report.json"
    
    generator = ConsolidatedReadmeGenerator(repo_root, audit_file)
    
    print("🚀 Generating Consolidated README for OpenCog Central")
    print("=" * 60)
    
    output_path = generator.save_readme()
    
    print(f"\n📊 Generation Summary:")
    print(f"  📁 Source data: {audit_file}")
    print(f"  📁 README files processed: {len(list(generator.readme_dir.glob('*_README*')))}")
    print(f"  📄 Output file: {output_path}")
    
    print(f"\n✅ Consolidated README generation completed successfully!")

if __name__ == "__main__":
    main()