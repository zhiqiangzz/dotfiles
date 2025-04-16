#!/usr/bin/env python
import json
import os
from pathlib import Path

def find_compile_commands(root_dir="."):
    """Recursively find all compile_commands.json under build/ directories"""
    matches = []
    for root, _, files in os.walk(root_dir):
        build_dir = Path(root) / "build"
        if build_dir.is_dir():
            json_file = build_dir / "compile_commands.json"
            if json_file.exists():
                matches.append(json_file)
    return matches

def merge_commands(input_files, output_file="compile_commands.json"):
    """Merge multiple compile_commands.json files"""
    merged = []
    for file in input_files:
        try:
            with open(file, 'r') as f:
                data = json.load(f)
                if isinstance(data, list):
                    merged.extend(data)
        except json.JSONDecodeError:
            print(f"Warning: Skipped invalid JSON file {file}")
    
    with open(output_file, 'w') as f:
        json.dump(merged, f, indent=2)
    print(f"Merged {len(input_files)} files -> {output_file}")

if __name__ == "__main__":
    json_files = find_compile_commands()
    if not json_files:
        print("No compile_commands.json files found under build/ directories!")
        exit(1)
    
    print("Found files:\n- " + "\n- ".join(str(f) for f in json_files))
    merge_commands(json_files)
