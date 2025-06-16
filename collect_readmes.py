#!/usr/bin/env python3
"""
README Collection Script for OpenCog Central
===========================================

This script collects all README files from orc-** folders and copies them to a central README/ folder
with appropriate prefixes as specified in the issue requirements.
"""

import os
import shutil
from pathlib import Path
from typing import List, Dict

class ReadmeCollector:
    def __init__(self, repo_root: str):
        self.repo_root = Path(repo_root)
        self.readme_dir = self.repo_root / "README"
        self.collected_files = []
        
    def collect_readme_files(self):
        """Collect all README files from orc-** directories"""
        print("📚 Collecting README files from orc-** directories...")
        
        # Create README directory if it doesn't exist
        self.readme_dir.mkdir(exist_ok=True)
        
        # Find all README files in orc-* directories
        readme_files = []
        for orc_dir in self.repo_root.glob("orc-*"):
            if orc_dir.is_dir():
                # Find README files recursively but prioritize top-level ones
                for readme_file in orc_dir.rglob("README*"):
                    if readme_file.is_file():
                        readme_files.append(readme_file)
        
        print(f"📖 Found {len(readme_files)} README files")
        
        # Copy files with appropriate prefixes
        for readme_file in readme_files:
            self._copy_readme_with_prefix(readme_file)
        
        print(f"✅ Collected {len(self.collected_files)} README files to {self.readme_dir}")
        return self.collected_files
    
    def _copy_readme_with_prefix(self, readme_file: Path):
        """Copy README file with appropriate prefix"""
        # Calculate relative path from repo root
        rel_path = readme_file.relative_to(self.repo_root)
        path_parts = rel_path.parts
        
        # Create prefix based on directory structure
        if len(path_parts) >= 2:
            category = path_parts[0]  # e.g., orc-ai
            component = path_parts[1]  # e.g., moses
            
            # Handle nested README files
            if len(path_parts) > 2:
                # For nested READMEs, include the subdirectory in the name
                subdir_parts = path_parts[2:-1]  # Exclude the filename
                if subdir_parts:
                    subdir_name = "_".join(subdir_parts)
                    prefix = f"{component}_{subdir_name}"
                else:
                    prefix = component
            else:
                prefix = component
            
            # Create destination filename
            original_name = readme_file.name
            if original_name.lower().startswith("readme"):
                extension = original_name[6:]  # Everything after "README"
                if not extension.startswith("."):
                    extension = f"_{extension}" if extension else ""
                dest_name = f"{prefix}_README{extension}"
            else:
                dest_name = f"{prefix}_{original_name}"
            
            dest_path = self.readme_dir / dest_name
            
            # Avoid overwriting files with same name by adding numbers
            counter = 1
            while dest_path.exists():
                name_parts = dest_name.rsplit('.', 1)
                if len(name_parts) == 2:
                    dest_name = f"{name_parts[0]}_{counter}.{name_parts[1]}"
                else:
                    dest_name = f"{dest_name}_{counter}"
                dest_path = self.readme_dir / dest_name
                counter += 1
            
            try:
                shutil.copy2(readme_file, dest_path)
                self.collected_files.append({
                    "original": str(readme_file),
                    "copied": str(dest_path),
                    "category": category,
                    "component": component,
                    "prefix": prefix
                })
                print(f"  ✓ {rel_path} → {dest_name}")
            except Exception as e:
                print(f"  ⚠️  Failed to copy {readme_file}: {e}")

def main():
    """Main execution function"""
    repo_root = "/home/runner/work/opencog-central/opencog-central"
    collector = ReadmeCollector(repo_root)
    
    print("🚀 Starting README collection for OpenCog Central")
    print("=" * 50)
    
    collected_files = collector.collect_readme_files()
    
    print(f"\n📊 Collection Summary:")
    print(f"  📁 Total README files collected: {len(collected_files)}")
    
    # Organize by category
    by_category = {}
    for file_info in collected_files:
        category = file_info["category"]
        if category not in by_category:
            by_category[category] = []
        by_category[category].append(file_info)
    
    print(f"\n📂 Files by category:")
    for category, files in sorted(by_category.items()):
        print(f"  {category}: {len(files)} files")
    
    print(f"\n✅ README collection completed successfully!")
    print(f"📁 All files collected in: {collector.readme_dir}")

if __name__ == "__main__":
    main()