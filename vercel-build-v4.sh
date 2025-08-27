#!/bin/bash

set -e

echo "=== VERCEL BUILD V4: ROCKY LINUX DOCS WITH CLEAN VERSIONING ==="

# Install dependencies
echo "Installing dependencies..."
pip3 install -r requirements.txt

# Add pip bin directory to PATH - handle multiple possible locations
echo "Setting up PATH for pip-installed console scripts..."

# Try multiple methods to find pip bin directory
PIP_BIN_DIR=""

# Method 1: Use sys.executable directory (most reliable)
PIP_BIN_DIR=$(python3 -c "import sys, os; print(os.path.dirname(sys.executable))" 2>/dev/null)
echo "Method 1 - sys.executable dir: $PIP_BIN_DIR"

# Method 2: Use pip show to find installation location
if [ -z "$PIP_BIN_DIR" ] || [ ! -f "$PIP_BIN_DIR/mike" ]; then
    SITE_PACKAGES=$(python3 -c "import site; print(site.getsitepackages()[0])" 2>/dev/null)
    if [ -n "$SITE_PACKAGES" ]; then
        ALT_BIN_DIR=$(dirname $(dirname $(dirname $SITE_PACKAGES)))/bin
        echo "Method 2 - site-packages derived: $ALT_BIN_DIR"
        if [ -f "$ALT_BIN_DIR/mike" ]; then
            PIP_BIN_DIR="$ALT_BIN_DIR"
        fi
    fi
fi

# Method 3: Use pip's --user base directory
if [ -z "$PIP_BIN_DIR" ] || [ ! -f "$PIP_BIN_DIR/mike" ]; then
    USER_BASE=$(python3 -c "import site; print(site.USER_BASE)" 2>/dev/null)
    if [ -n "$USER_BASE" ]; then
        USER_BIN_DIR="$USER_BASE/bin"
        echo "Method 3 - user base dir: $USER_BIN_DIR"
        if [ -f "$USER_BIN_DIR/mike" ]; then
            PIP_BIN_DIR="$USER_BIN_DIR"
        fi
    fi
fi

# Method 4: Search common locations
if [ -z "$PIP_BIN_DIR" ] || [ ! -f "$PIP_BIN_DIR/mike" ]; then
    for potential_bin in /usr/local/bin /opt/python*/bin ~/.local/bin; do
        if [ -f "$potential_bin/mike" ]; then
            PIP_BIN_DIR="$potential_bin"
            echo "Method 4 - found in: $PIP_BIN_DIR"
            break
        fi
    done
fi

# If we still can't find it, fall back to module execution
if [ -z "$PIP_BIN_DIR" ] || [ ! -f "$PIP_BIN_DIR/mike" ]; then
    echo "⚠️  Could not find mike binary, will use python module execution fallback"
    USE_MODULE_EXECUTION=true
else
    export PATH="$PIP_BIN_DIR:$PATH"
    echo "✅ PATH updated: $PATH"
    USE_MODULE_EXECUTION=false
fi

echo "Testing mike and mkdocs availability:"
if [ "$USE_MODULE_EXECUTION" = "true" ]; then
    echo "🔧 Using Python module execution mode"
    python3 -c "import mike; print('mike module available')" 2>/dev/null || echo "❌ mike module not found"
    python3 -c "import mkdocs; print('mkdocs module available')" 2>/dev/null || echo "❌ mkdocs module not found"
else
    which mike || echo "❌ mike not found in PATH"
    which mkdocs || echo "❌ mkdocs not found in PATH" 
    mike --version 2>/dev/null || echo "❌ mike not executable"
    mkdocs --version 2>/dev/null || echo "❌ mkdocs not executable"
fi

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

echo "Building with mike versioning..."

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
    
    # Deploy with mike - handle both PATH and module execution modes
    if [ "$USE_MODULE_EXECUTION" = "true" ]; then
        # Use python module execution as fallback
        echo "🔧 Using Python module execution for mike deploy"
        if [ -n "$alias" ] && [ -n "$title" ]; then
            python3 -c "from mike.driver import main; import sys; sys.argv = ['mike', 'deploy', '$version', '$alias', '--title=$title']; main()"
        elif [ -n "$alias" ]; then
            python3 -c "from mike.driver import main; import sys; sys.argv = ['mike', 'deploy', '$version', '$alias']; main()"
        elif [ -n "$title" ]; then
            python3 -c "from mike.driver import main; import sys; sys.argv = ['mike', 'deploy', '$version', '--title=$title']; main()"
        else
            python3 -c "from mike.driver import main; import sys; sys.argv = ['mike', 'deploy', '$version']; main()"
        fi
    else
        # Use PATH-based execution (preferred)
        if [ -n "$alias" ] && [ -n "$title" ]; then
            mike deploy "$version" "$alias" --title="$title"
        elif [ -n "$alias" ]; then
            mike deploy "$version" "$alias"
        elif [ -n "$title" ]; then
            mike deploy "$version" --title="$title"
        else
            mike deploy "$version"
        fi
    fi
    
    echo "✅ Rocky Linux $version deployed successfully"
}

# Build each version from its respective branch
build_version "8" "rocky-8" "" ""
build_version "9" "rocky-9" "" "" 
build_version "10" "main" "latest" ""

echo "Setting default version..."
if [ "$USE_MODULE_EXECUTION" = "true" ]; then
    python3 -c "from mike.driver import main; import sys; sys.argv = ['mike', 'set-default', 'latest']; main()"
else
    mike set-default latest
fi

echo "✅ All versions deployed successfully"

# Verify mike state
echo "Verifying mike deployment..."
if [ "$USE_MODULE_EXECUTION" = "true" ]; then
    python3 -c "from mike.driver import main; import sys; sys.argv = ['mike', 'list']; main()"
else
    mike list
fi

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

echo "🎉 Vercel V4 build completed successfully!"
echo "Static site with versioning is ready in ./site directory"
echo "🔥 Clean solution: No wrappers needed, just proper PATH setup!"