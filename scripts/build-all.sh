#!/bin/bash
set -e

echo "Building all locales..."

# Clean previous builds
rm -rf build-ja build-en

# Build both locales
./scripts/build-ja.sh
./scripts/build-en.sh

echo "All builds complete!"
echo "Japanese site: build-ja/"
echo "English site: build-en/"