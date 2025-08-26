#!/bin/bash

set -e

echo "=== SIMPLE VERCEL BUILD: ROCKY LINUX DOCS ==="

# Install dependencies
echo "Installing dependencies..."
pip3 install -r requirements.txt

# Clean any existing content
echo "Cleaning existing directories..."
rm -rf documentation docs site 2>/dev/null || true

# Clone the main documentation branch (Rocky Linux 10)
echo "Cloning Rocky Linux documentation (main branch)..."
git clone -b main https://github.com/rocky-linux/documentation.git

# Verify clone worked
if [ ! -d "documentation" ]; then
    echo "❌ Failed to clone main branch"
    exit 1
fi

# Set up docs directory for MkDocs
echo "Setting up docs directory..."
mkdir -p docs

if [ -d "documentation/docs" ]; then
    cp -r documentation/docs/* docs/
    echo "✅ Content copied successfully"
else
    echo "❌ No docs directory found in documentation repository"
    exit 1
fi

# Build with MkDocs
echo "Building site with MkDocs..."
python3 -m mkdocs build

# Verify site was built
if [ -d "site" ] && [ "$(ls -A site 2>/dev/null | wc -l)" -gt 0 ]; then
    echo "✅ Site built successfully for Vercel deployment"
    echo "Site contents:"
    ls -la site/ | head -10
else
    echo "❌ Site build failed"
    exit 1
fi

echo "🎉 Simple Vercel build completed successfully!"
echo "Static site is ready in ./site directory"