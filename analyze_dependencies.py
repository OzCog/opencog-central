#!/usr/bin/env python3
"""
Analyze CMakeLists.txt dependencies and generate dependency information.
"""

import os
import re
import json
from pathlib import Path

def extract_dependencies(cmake_file):
    """Extract dependencies from a CMakeLists.txt file."""
    dependencies = {
        'packages': [],
        'internal_deps': []
    }
    
    try:
        with open(cmake_file, 'r') as f:
            content = f.read()
            
        # Find FIND_PACKAGE calls
        package_pattern = r'FIND_PACKAGE\s*\(\s*([A-Za-z0-9_-]+)'
        packages = re.findall(package_pattern, content, re.IGNORECASE)
        
        # Clean up and filter relevant packages
        relevant_packages = []
        for pkg in packages:
            if pkg.lower() in ['cogutil', 'atomspace', 'ure', 'boost', 'guile', 'cython', 'postgres']:
                relevant_packages.append(pkg)
        
        dependencies['packages'] = list(set(relevant_packages))
        
        # Find ADD_SUBDIRECTORY calls (internal dependencies)
        subdir_pattern = r'ADD_SUBDIRECTORY\s*\(\s*([A-Za-z0-9_-]+)'
        subdirs = re.findall(subdir_pattern, content, re.IGNORECASE)
        dependencies['internal_deps'] = subdirs
        
    except Exception as e:
        print(f"Error reading {cmake_file}: {e}")
    
    return dependencies

def main():
    cmakelists_dir = Path('/home/runner/work/opencog-central/opencog-central/cmakelists')
    
    # Analyze all CMakeLists files
    dependency_map = {}
    
    for cmake_file in cmakelists_dir.glob('*_CMakeLists.txt'):
        component_name = cmake_file.stem.replace('_CMakeLists', '')
        dependencies = extract_dependencies(cmake_file)
        dependency_map[component_name] = dependencies
        
        print(f"{component_name}:")
        if dependencies['packages']:
            print(f"  External packages: {', '.join(dependencies['packages'])}")
        if dependencies['internal_deps']:
            print(f"  Internal deps: {', '.join(dependencies['internal_deps'])}")
        print()
    
    # Save to JSON for further processing
    with open('/home/runner/work/opencog-central/opencog-central/cmake_dependencies.json', 'w') as f:
        json.dump(dependency_map, f, indent=2)
    
    print("Dependencies analysis saved to cmake_dependencies.json")

if __name__ == '__main__':
    main()