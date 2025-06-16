#!/usr/bin/env python3
"""
OpenCog Central Component Audit Script
=====================================

This script performs a comprehensive audit of all components in the OpenCog Central repository:
1. Catalogs all actual components in orc-* directories
2. Extracts dependency information from CMakeLists.txt and README files  
3. Compares with existing build plans (CircleCI, CMakeLists)
4. Classifies components by layer and function
5. Generates dependency analysis and build order recommendations
"""

import os
import json
import yaml
import re
from pathlib import Path
from collections import defaultdict, OrderedDict
from typing import Dict, List, Set, Tuple

class ComponentAuditor:
    def __init__(self, repo_root: str):
        self.repo_root = Path(repo_root)
        self.components = {}
        self.dependencies = defaultdict(set)
        self.layers = {
            "foundation": ["cogutil", "moses", "blender"],
            "core": ["atomspace", "atomspace-rocks", "atomspace-restful", "atomspace-dht", 
                    "atomspace-ipfs", "atomspace-websockets", "atomspace-metta", "atomspace-cog",
                    "atomspace-bridge", "atomspace-agents", "atomspace-explorer", "atomspace-js",
                    "atomspace-typescript", "atomspace-rpc"],
            "logic": ["unify", "ure"],
            "cognitive": ["cogserver", "attention", "spacetime"],
            "advanced": ["pln", "miner", "asmoses", "benchmark"],
            "learning": ["learn", "generate"],
            "specialized": ["vision", "cheminformatics", "sensory", "visualization"],
            "integration": ["opencog"],
            "packaging": ["package", "opencog-debian", "opencog-nix"]
        }
    
    def scan_components(self) -> Dict:
        """Scan all orc-* directories to catalog actual components"""
        print("🔍 Scanning components in orc-* directories...")
        
        for orc_dir in self.repo_root.glob("orc-*"):
            if orc_dir.is_dir():
                category = orc_dir.name
                print(f"  📁 Scanning {category}...")
                
                self.components[category] = {}
                
                for component_dir in orc_dir.iterdir():
                    if component_dir.is_dir() and not component_dir.name.startswith('.'):
                        component_name = component_dir.name
                        component_info = self._analyze_component(component_dir)
                        self.components[category][component_name] = component_info
                        
                        print(f"    ✓ {component_name}: {component_info['type']}")
        
        return self.components
    
    def _analyze_component(self, component_path: Path) -> Dict:
        """Analyze individual component for type, dependencies, and metadata"""
        info = {
            "path": str(component_path),
            "type": "unknown",
            "has_cmake": False,
            "has_readme": False,
            "dependencies": [],
            "description": "",
            "language": "unknown"
        }
        
        # Check for CMakeLists.txt
        cmake_file = component_path / "CMakeLists.txt"
        if cmake_file.exists():
            info["has_cmake"] = True
            info["type"] = "cmake_project"
            deps = self._extract_cmake_dependencies(cmake_file)
            info["dependencies"].extend(deps)
        
        # Check for README
        readme_files = list(component_path.glob("README*"))
        if readme_files:
            info["has_readme"] = True
            readme_deps, desc = self._extract_readme_info(readme_files[0])
            info["dependencies"].extend(readme_deps)
            info["description"] = desc
        
        # Detect language/type
        if (component_path / "package.json").exists():
            info["language"] = "javascript"
            info["type"] = "npm_package"
        elif (component_path / "setup.py").exists() or (component_path / "pyproject.toml").exists():
            info["language"] = "python"
            info["type"] = "python_package"
        elif (component_path / "Cargo.toml").exists():
            info["language"] = "rust"
            info["type"] = "rust_crate"
        elif list(component_path.glob("*.cpp")) or list(component_path.glob("*.hpp")):
            info["language"] = "cpp"
        elif list(component_path.glob("*.py")):
            info["language"] = "python"
        
        return info
    
    def _extract_cmake_dependencies(self, cmake_file: Path) -> List[str]:
        """Extract dependencies from CMakeLists.txt"""
        dependencies = []
        try:
            content = cmake_file.read_text(encoding='utf-8')
            
            # Look for FIND_PACKAGE calls
            find_package_pattern = r'FIND_PACKAGE\s*\(\s*([A-Za-z0-9_-]+)'
            dependencies.extend(re.findall(find_package_pattern, content, re.IGNORECASE))
            
            # Look for pkg_check_modules calls
            pkg_check_pattern = r'pkg_check_modules\s*\([^)]*\s+([A-Za-z0-9_-]+)'
            dependencies.extend(re.findall(pkg_check_pattern, content, re.IGNORECASE))
            
        except Exception as e:
            print(f"    ⚠️  Error reading {cmake_file}: {e}")
        
        return dependencies
    
    def _extract_readme_info(self, readme_file: Path) -> Tuple[List[str], str]:
        """Extract dependencies and description from README"""
        dependencies = []
        description = ""
        
        try:
            content = readme_file.read_text(encoding='utf-8')
            
            # Extract description from title or first paragraph
            lines = content.split('\n')
            for line in lines[:10]:  # Check first 10 lines
                if line.strip() and not line.startswith('#'):
                    description = line.strip()
                    break
            
            # Look for dependency mentions
            dep_patterns = [
                r'[Dd]epends?\s+on:?\s*([A-Za-z0-9_,\-\s]+)',
                r'[Rr]equires?:?\s*([A-Za-z0-9_,\-\s]+)',
                r'[Pp]rerequisites?:?\s*([A-Za-z0-9_,\-\s]+)'
            ]
            
            for pattern in dep_patterns:
                matches = re.findall(pattern, content)
                for match in matches:
                    deps = [dep.strip() for dep in re.split(r'[,\s]+', match) if dep.strip()]
                    dependencies.extend(deps)
                    
        except Exception as e:
            print(f"    ⚠️  Error reading {readme_file}: {e}")
        
        return dependencies, description
    
    def analyze_circleci_config(self) -> Dict:
        """Analyze CircleCI configuration for build dependencies"""
        print("🔄 Analyzing CircleCI configuration...")
        
        circleci_file = self.repo_root / ".circleci" / "config.yml"
        circleci_info = {"jobs": {}, "workflow_dependencies": {}}
        
        if not circleci_file.exists():
            print("  ⚠️  No CircleCI config found")
            return circleci_info
        
        try:
            with open(circleci_file, 'r') as f:
                config = yaml.safe_load(f)
            
            # Extract jobs
            if 'jobs' in config:
                for job_name in config['jobs']:
                    circleci_info["jobs"][job_name] = {
                        "type": "circleci_job",
                        "dependencies": []
                    }
            
            # Extract workflow dependencies
            if 'workflows' in config:
                for workflow_name, workflow in config['workflows'].items():
                    if 'jobs' in workflow:
                        for job_item in workflow['jobs']:
                            if isinstance(job_item, dict):
                                for job_name, job_config in job_item.items():
                                    if 'requires' in job_config:
                                        circleci_info["workflow_dependencies"][job_name] = job_config['requires']
                            elif isinstance(job_item, str):
                                circleci_info["workflow_dependencies"][job_item] = []
            
            print(f"  ✓ Found {len(circleci_info['jobs'])} jobs in CircleCI config")
            
        except Exception as e:
            print(f"  ⚠️  Error parsing CircleCI config: {e}")
        
        return circleci_info
    
    def classify_components_by_layer(self) -> Dict:
        """Classify components by architectural layer"""
        print("🏗️  Classifying components by layer...")
        
        classification = defaultdict(list)
        unclassified = []
        
        for category, components in self.components.items():
            for component_name, component_info in components.items():
                classified = False
                
                for layer, layer_components in self.layers.items():
                    # Check exact match or partial match
                    if (component_name in layer_components or 
                        any(comp in component_name for comp in layer_components) or
                        any(component_name in comp for comp in layer_components)):
                        classification[layer].append({
                            "name": component_name,
                            "category": category,
                            "info": component_info
                        })
                        classified = True
                        break
                
                if not classified:
                    unclassified.append({
                        "name": component_name,
                        "category": category,
                        "info": component_info
                    })
        
        # Auto-classify unclassified components based on category
        for item in unclassified:
            category = item["category"]
            if category == "orc-ai":
                classification["advanced"].append(item)
            elif category == "orc-nl":
                classification["specialized"].append(item)
            elif category == "orc-ro":
                classification["specialized"].append(item)
            elif category == "orc-bi":
                classification["specialized"].append(item)
            elif category == "orc-em":
                classification["specialized"].append(item)
            elif category == "orc-ct":
                classification["cognitive"].append(item)
            elif category == "orc-sv":
                classification["cognitive"].append(item)
            elif category == "orc-wb":
                classification["integration"].append(item)
            elif category == "orc-gm":
                classification["specialized"].append(item)
            elif category == "orc-dv":
                classification["foundation"].append(item)
            elif category == "orc-in":
                classification["packaging"].append(item)
            else:
                classification["unclassified"].append(item)
        
        for layer, items in classification.items():
            print(f"  📊 {layer}: {len(items)} components")
        
        return dict(classification)
    
    def generate_component_summary(self) -> Dict:
        """Generate comprehensive component summary"""
        print("📊 Generating component summary...")
        
        summary = {
            "total_categories": len(self.components),
            "total_components": 0,
            "components_by_category": {},
            "components_by_type": defaultdict(int),
            "components_by_language": defaultdict(int),
            "components_with_cmake": 0,
            "components_with_readme": 0
        }
        
        for category, components in self.components.items():
            count = len(components)
            summary["total_components"] += count
            summary["components_by_category"][category] = {
                "count": count,
                "components": list(components.keys())
            }
            
            for component_name, component_info in components.items():
                summary["components_by_type"][component_info["type"]] += 1
                summary["components_by_language"][component_info["language"]] += 1
                
                if component_info["has_cmake"]:
                    summary["components_with_cmake"] += 1
                if component_info["has_readme"]:
                    summary["components_with_readme"] += 1
        
        return summary
    
    def save_audit_report(self, output_file: str):
        """Save complete audit report to JSON file"""
        print(f"💾 Saving audit report to {output_file}...")
        
        circleci_info = self.analyze_circleci_config()
        classification = self.classify_components_by_layer()
        summary = self.generate_component_summary()
        
        report = {
            "audit_metadata": {
                "repository_root": str(self.repo_root),
                "total_categories": len(self.components),
                "total_components": summary["total_components"]
            },
            "components": self.components,
            "circleci_analysis": circleci_info,
            "component_classification": classification,
            "summary": summary
        }
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        
        print(f"  ✅ Audit report saved to {output_file}")
        return report

def main():
    """Main execution function"""
    repo_root = "/home/runner/work/opencog-central/opencog-central"
    auditor = ComponentAuditor(repo_root)
    
    print("🚀 Starting OpenCog Central Component Audit")
    print("=" * 50)
    
    # Scan all components
    components = auditor.scan_components()
    
    # Generate and save report
    report = auditor.save_audit_report("component_audit_report.json")
    
    print("\n📈 Summary:")
    print(f"  📁 Total categories: {report['summary']['total_categories']}")
    print(f"  🧩 Total components: {report['summary']['total_components']}")
    print(f"  🔧 Components with CMake: {report['summary']['components_with_cmake']}")
    print(f"  📖 Components with README: {report['summary']['components_with_readme']}")
    
    print("\n📊 Components by category:")
    for category, info in report['summary']['components_by_category'].items():
        print(f"  {category}: {info['count']} components")
    
    print("\n🏗️  Components by layer:")
    for layer, components in report['component_classification'].items():
        print(f"  {layer}: {len(components)} components")
    
    print("\n✅ Component audit completed successfully!")

if __name__ == "__main__":
    main()