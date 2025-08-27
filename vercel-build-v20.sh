#!/bin/bash

set -e

echo "=== VERCEL BUILD V20: FIXING GIT REVISION DATE ISSUE ==="

# Install dependencies
echo "Installing dependencies..."
pip3 install -r requirements.txt

# Create minimal mkdocs wrapper for mike to find
echo "Creating minimal mkdocs wrapper for mike..."
cat > mkdocs << 'EOF'
#!/usr/bin/env python3
import sys
from mkdocs.__main__ import cli
cli()
EOF
chmod +x mkdocs

# Add current directory to PATH so mike can find our mkdocs wrapper
export PATH=".:$PATH"

echo "✅ mkdocs wrapper created and added to PATH"

# FORCE cleanup of any existing content
echo "Force cleaning any existing directories..."
rm -rf rockydocs3-* docs site 2>/dev/null || true

# Function to build a specific version from a specific branch
build_version() {
    local version=$1
    local branch=$2
    local alias=$3
    local title=$4
    
    echo "Building Rocky Linux $version from branch $branch..."
    
    # Clone the specific branch WITH FULL HISTORY for git-revision-date-localized-plugin
    local repo_dir="rockydocs3-$version"
    echo "Cloning $branch with full git history..."
    git clone -b "$branch" https://github.com/rocky-linux/documentation.git "$repo_dir"
    
    # Verify clone worked
    if [ ! -d "$repo_dir" ]; then
        echo "❌ Failed to clone $branch branch"
        return 1
    fi
    
    # CRITICAL: Instead of copying files, we need to work IN the cloned repo
    # to preserve git history for git-revision-date-localized-plugin
    echo "Working directly in cloned repo to preserve git history..."
    
    # Change to the cloned repo directory
    cd "$repo_dir"
    
    # Verify docs directory exists
    if [ ! -d "docs" ]; then
        echo "❌ No docs directory in $branch branch"
        cd ..
        return 1
    fi
    
    echo "✅ Working in $repo_dir with preserved git history"
    
    # Deploy with mike using Python module execution + mkdocs wrapper
    # We need to go back to parent directory for mike operations
    cd ..
    
    # Create a symlink to preserve git history access
    rm -rf docs
    ln -sf "$repo_dir/docs" docs
    
    echo "✅ Created symlink to docs with preserved git history"
    
    # Initialize git repo in parent if not exists (for mike operations)
    if [ ! -d ".git" ]; then
        git init
        git config user.name "wsoyinka"
        git config user.email "webmaster@rockylinux.org"
        
        # Add the documentation repo as a worktree/submodule reference
        git add .
        git commit -m "Build commit for version $version $(date)"
    fi
    
    echo "🚀 Deploying version $version with preserved git history"
    if [ -n "$alias" ] && [ -n "$title" ]; then
        python3 -c "import sys; sys.argv=['mike','deploy','$version','$alias','--title=$title']; from mike.driver import main; main()"
    elif [ -n "$alias" ]; then
        python3 -c "import sys; sys.argv=['mike','deploy','$version','$alias']; from mike.driver import main; main()"
    elif [ -n "$title" ]; then
        python3 -c "import sys; sys.argv=['mike','deploy','$version','--title=$title']; from mike.driver import main; main()"
    else
        python3 -c "import sys; sys.argv=['mike','deploy','$version']; from mike.driver import main; main()"
    fi
    
    echo "✅ Rocky Linux $version deployed successfully with git history preserved"
}

echo "Starting git-aware build process..."

# Set up initial git repo for mike operations
if [ -d ".git" ]; then
    echo "Removing existing git state to ensure fresh build..."
    rm -rf .git
fi

git init
git config user.name "wsoyinka"
git config user.email "webmaster@rockylinux.org"

# Create initial commit
echo "# Rocky Linux Docs Build" > README.md
git add README.md mkdocs
git commit -m "Initial commit for Vercel build $(date)"

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

echo "🎉 V20 Vercel build completed successfully!"
echo "Static site with versioning ready with PRESERVED GIT HISTORY!"
echo "🕒 git-revision-date-localized-plugin should now show correct timestamps!"