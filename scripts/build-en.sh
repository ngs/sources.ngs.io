#!/bin/bash
set -e

echo "Building English site..."
hugo --config hugo.en.toml --contentDir content/en --destination build-en
echo "English site built to build-en/"