#!/bin/bash

set -e
set -x # Enable debugging output

echo "=== NETLIFY BUILD: ROCKY LINUX DOCS WITH BRANCH-BASED VERSIONING (REFACTORED) ==="

# Install dependencies
echo "Installing dependencies... (already satisfied if run recently)"
pip install -r requirements.txt

# Check which mike is being used
which mike

# Ensure submodules are initialized and updated
echo "Initializing and updating Git submodules..."
git submodule update --init --recursive

echo "--- Submodule Debugging Info ---"
ls -la versions/rocky-8
git status --porcelain
git submodule status
echo "--- End Submodule Debugging Info ---"


# FORCE cleanup of any existing build artifacts (not .git related)
echo "Force cleaning any existing build artifacts..."
rm -rf site 2>/dev/null || true

echo "Building with mike versioning..."

# Function to build a specific version from a specific submodule path
# mike will read mkdocs.yml from the main repo, but use the specified docs_dir
build_version() {
    local version=$1
    local submodule_path=$2 # e.g., versions/rocky-8
    # local alias=$3 # Removed for testing
    # local title=$4 # Removed for testing
    
    echo "Building Rocky Linux $version from submodule path $submodule_path..."
    
    # Verify submodule's docs directory exists
    if [ ! -d "$submodule_path/docs" ]; then
        echo "❌ Submodule docs directory '$submodule_path/docs' not found. Ensure submodules are initialized and updated correctly."
        return 1
    fi

    # Create a temporary mkdocs.yml for this version
    local temp_mkdocs_yml="mkdocs.yml.${version}.tmp"
    
    # Read the main mkdocs.yml, replace docs_dir, and write to temp file
    sed "s|^docs_dir: .*|docs_dir: $submodule_path/docs|" mkdocs.yml > "$temp_mkdocs_yml"
    
    # Deploy with mike, using the temporary mkdocs.yml
    mike deploy "$version" --config-file "$temp_mkdocs_yml"
    
    # Clean up the temporary mkdocs.yml
    rm "$temp_mkdocs_yml"
    
    echo "✅ Rocky Linux $version deployed successfully"
}

# Build each version from its respective submodule path
# These paths must match the paths used in 'git submodule add' in Part 1
build_version "8" "versions/rocky-8" "" ""
build_version "9" "versions/rocky-9" "" "" 
build_version "10" "versions/main" "latest" ""

echo "Setting default version..."
mike set-default latest

echo "✅ All versions deployed successfully"

# Verify mike state (optional, but good for debugging)
echo "Verifying mike deployment..."
mike list

echo "Extracting built site for Netlify..."

# Extract from gh-pages for Netlify
# This part remains largely the same as it extracts from mike's gh-pages branch
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "✅ gh-pages branch found"
    
    BRANCH_FILE_COUNT=$(git ls-tree --name-only gh-pages | wc -l)
    echo "Files in gh-pages branch: $BRANCH_FILE_COUNT"
    
    if [ "$BRANCH_FILE_COUNT" -gt 0 ]; then
        echo "Extracting site content from gh-pages..."
        
        mkdir -p site
        git archive gh-pages | tar -x -C site
        
        if [ -d "site" ] && [ "$(ls -A site 2>/dev/null | wc -l)" -gt 0 ]; then
            echo "✅ Site extracted successfully"
        else
            echo "❌ Site extraction failed"
            exit 1
        fi
    else
        echo "❌ gh-pages branch is empty! This might indicate a problem with mike deployment."
        exit 1
    fi
else
    echo "❌ No gh-pages branch found! This might indicate a problem with mike deployment."
    exit 1
fi

echo "🎉 Build completed successfully!"
