#!/bin/bash

# Usage: ./scripts/package-all.sh path1 path2 path3 ...
# or: ./scripts/package-all.sh path/to/*

# Create dist directory if it doesn't exist
mkdir -p dist

# Process each path provided as argument
for dir in "$@"; do
  if [ -f "$dir/contents.json" ]; then
    # Extract the directory name for the output file
    dirname=$(basename "$dir")
    echo "Packaging $dir -> dist/${dirname}.tgz"
    fianu package --path "$dir" -o "dist/${dirname}.tgz"
  else
    echo "Skipping $dir (no contents.json found)"
  fi
done

echo "Done! Packages saved to dist/"