#!/bin/bash

set -e

echo "=== VERCEL BUILD V7: PYTHON MODULE SOLUTION ==="

# Install dependencies
echo "Installing dependencies..."
pip3 install -r requirements.txt

# FORCE cleanup of any existing content
echo "Force cleaning any existing directories..."
rm -rf rockydocs3-* docs site 2>/dev/null || true

# Force clean git state for consistent builds
echo "Setting up clean git state..."
if [ -d ".git" ]; then
    echo "Removing existing git state to ensure fresh build..."
    rm -rf .git
fi

echo "Initializing fresh git repository..."
git init
# Git setup for mike
echo "Setting up git configuration..."
git config user.name "wsoyinka"
git config user.email "webmaster@rockylinux.org"
git add .
git commit -m "Fresh commit for Vercel build $(date)"

echo "Building with mike versioning using Python modules..."

# Function to build a specific version from a specific branch
build_version() {
    local version=$1
    local branch=$2
    local alias=$3
    local title=$4
    
    echo "Building Rocky Linux $version from branch $branch..."
    
    # Clone the specific branch
    local repo_dir="rockydocs3-$version"
    git clone -b "$branch" https://github.com/rocky-linux/documentation.git "$repo_dir"
    
    # Verify clone worked
    if [ ! -d "$repo_dir" ]; then
        echo "❌ Failed to clone $branch branch"
        return 1
    fi
    
    # Set up docs for this version
    rm -rf docs
    mkdir -p docs
    
    if [ -d "$repo_dir/docs" ]; then
        cp -r "$repo_dir/docs"/* docs/
        echo "✅ Content copied for version $version"
    else
        echo "❌ No docs directory in $branch branch"
        return 1
    fi
    
    # Deploy with mike using Python module execution
    echo "🚀 Using python3 -c with mike.driver.main"
    if [ -n "$alias" ] && [ -n "$title" ]; then
        python3 -c "import sys; sys.argv=['mike','deploy','$version','$alias','--title=$title']; from mike.driver import main; main()"
    elif [ -n "$alias" ]; then
        python3 -c "import sys; sys.argv=['mike','deploy','$version','$alias']; from mike.driver import main; main()"
    elif [ -n "$title" ]; then
        python3 -c "import sys; sys.argv=['mike','deploy','$version','--title=$title']; from mike.driver import main; main()"
    else
        python3 -c "import sys; sys.argv=['mike','deploy','$version']; from mike.driver import main; main()"
    fi
    
    echo "✅ Rocky Linux $version deployed successfully"
}

# Build each version from its respective branch
build_version "8" "rocky-8" "" ""
build_version "9" "rocky-9" "" "" 
build_version "10" "main" "latest" ""

echo "Setting default version..."
python3 -c "import sys; sys.argv=['mike','set-default','latest']; from mike.driver import main; main()"

echo "✅ All versions deployed successfully"

# Verify mike state
echo "Verifying mike deployment..."
python3 -c "import sys; sys.argv=['mike','list']; from mike.driver import main; main()"

echo "Extracting built site for Vercel..."

# Clean any existing site directory
rm -rf site

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
            echo "✅ Site extracted successfully for Vercel deployment"
            echo "Site contents:"
            ls -la site/ | head -10
        else
            echo "❌ Site extraction failed"
            exit 1
        fi
    else
        echo "❌ gh-pages branch is empty!"
        exit 1
    fi
else
    echo "❌ No gh-pages branch found!"
    exit 1
fi

echo "🎉 Vercel V7 build completed successfully!"
echo "Static site with versioning is ready in ./site directory"
echo "💡 SOLUTION: Use python3 -c with mike.driver.main - no PATH issues!"