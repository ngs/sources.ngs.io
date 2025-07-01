#!/bin/bash
set -e

echo "Building Japanese site..."
hugo --config hugo.ja.toml --contentDir content/ja --destination build-ja
echo "Japanese site built to build-ja/"