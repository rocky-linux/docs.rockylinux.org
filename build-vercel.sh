#!/bin/bash

set -e
set -x # Enable debugging output

echo "=== VERCEL BUILD: ROCKY LINUX DOCS ==="

# Force cleanup of any existing build artifacts
rm -rf site 2>/dev/null || true

# Initialize and update submodules
git submodule update --init --recursive

# Install dependencies
python3 -m pip install -r requirements.txt

# Find mike executable
MIKE_BIN="$(python3 -m site --user-base)/bin/mike"

echo "Building with mike versioning..."

# Function to build a specific version from a specific submodule path
build_version() {
    local version=$1
    local submodule_path=$2
    
    echo "Building Rocky Linux $version from submodule path $submodule_path..."
    
    # Verify submodule's docs directory exists
    if [ ! -d "$submodule_path/docs" ]; then
        echo "❌ Submodule docs directory '$submodule_path/docs' not found."
        return 1
    fi

    # Create a temporary mkdocs.yml for this version
    local temp_mkdocs_yml="mkdocs.yml.${version}.tmp"
    
    # Read the main mkdocs.yml, replace docs_dir, and write to temp file
    sed "s|^docs_dir: .*|docs_dir: $submodule_path/docs|" mkdocs.yml > "$temp_mkdocs_yml"
    
    # Deploy with mike, using the temporary mkdocs.yml
    "$MIKE_BIN" deploy "$version" --config-file "$temp_mkdocs_yml"
    
    # Clean up the temporary mkdocs.yml
    if [ "$version" != "10" ]; then rm "$temp_mkdocs_yml"; fi
    
    echo "✅ Rocky Linux $version deployed successfully"
}

# Build each version from its respective submodule path
build_version "8" "versions/rocky-8"
build_version "9" "versions/rocky-9"
build_version "10" "versions/main"

echo "Setting default version..."
"$MIKE_BIN" alias "10" latest --config-file "mkdocs.yml.10.tmp"
"$MIKE_BIN" set-default latest --config-file "mkdocs.yml.10.tmp"

echo "✅ All versions deployed successfully"

# Verify mike state
echo "Verifying mike deployment..."
"$MIKE_BIN" list --config-file "mkdocs.yml.10.tmp"
rm mkdocs.yml.10.tmp

echo "Extracting built site for Vercel..."

# Extract from gh-pages for Vercel
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