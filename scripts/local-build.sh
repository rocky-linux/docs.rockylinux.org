#!/bin/bash

set -e

echo "=== LOCAL BUILD - TESTING ==="

# Install dependencies
echo "Installing dependencies..."
pip3 install -r requirements.txt

# Simple local build for testing
echo "Building site locally..."

# Use the appropriate config
CONFIG_FILE="configs/mkdocs.yml"
if [ "$1" = "--minimal" ]; then
    CONFIG_FILE="configs/mkdocs.minimal.yml"
elif [ "$1" = "--full" ]; then
    CONFIG_FILE="configs/mkdocs.full.yml"
fi

echo "Using config: $CONFIG_FILE"

# Simple mkdocs build
mkdocs build -f "$CONFIG_FILE" -d site

echo "Local build completed!"
echo "Output: ./site/"
echo ""
echo "To serve locally:"
echo "  mkdocs serve -f $CONFIG_FILE"