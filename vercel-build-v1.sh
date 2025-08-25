#!/bin/bash

set -e

echo "=== VERCEL BUILD: ROCKY LINUX DOCS WITH BRANCH-BASED VERSIONING ==="

# Install dependencies
echo "Installing dependencies..."
pip3 install -r requirements.txt

# Create mike wrapper using the correct approach
cat > mike << 'EOF'
#!/bin/bash
# Mike wrapper script
PYTHON_PATH=$(python3 -c "import site; print(':'.join(site.getsitepackages()))")
export PYTHONPATH="$PYTHON_PATH:$PYTHONPATH"

# Check for mike entry point
python3 -c "
import sys
sys.argv = ['mike'] + sys.argv[1:]

# Try different ways to run mike
try:
    # Method 1: Try using mike.app which is the main entry point
    from mike.app import main
    main()
except (ImportError, AttributeError):
    try:
        # Method 2: Try using mike's command line interface
        import mike.commands
        import mike.git_utils
        from mike import app
        app.main()
    except (ImportError, AttributeError):
        try:
            # Method 3: Last resort - use the direct import
            import subprocess
            import os
            mike_path = os.path.join(os.path.dirname(sys.executable), 'mike')
            if os.path.exists(mike_path):
                os.execv(mike_path, sys.argv)
            else:
                print('ERROR: Could not find mike executable', file=sys.stderr)
                sys.exit(1)
        except Exception as e:
            print(f'ERROR: Failed to run mike: {e}', file=sys.stderr)
            sys.exit(1)
" "$@"
EOF
chmod +x mike
export PATH=".:$PATH"

echo "Created mike wrapper, testing..."
./mike --help 2>&1 | head -5 || echo "Mike wrapper test failed"

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
    
    # Deploy with mike
    if [ -n "$alias" ] && [ -n "$title" ]; then
        mike deploy "$version" "$alias" --title="$title"
    elif [ -n "$alias" ]; then
        mike deploy "$version" "$alias"
    elif [ -n "$title" ]; then
        mike deploy "$version" --title="$title"
    else
        mike deploy "$version"
    fi
    
    echo "✅ Rocky Linux $version deployed successfully"
}

# Build each version from its respective branch
build_version "8" "rocky-8" "" ""
build_version "9" "rocky-9" "" "" 
build_version "10" "main" "latest" ""

echo "Setting default version..."
mike set-default latest

echo "✅ All versions deployed successfully"

# Verify mike state
echo "Verifying mike deployment..."
mike list

echo "Building final site for Vercel..."

# For Vercel, we need to build the final site in the site/ directory
# which Vercel will serve as static files
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "✅ gh-pages branch found"
    
    BRANCH_FILE_COUNT=$(git ls-tree --name-only gh-pages | wc -l)
    echo "Files in gh-pages branch: $BRANCH_FILE_COUNT"
    
    if [ "$BRANCH_FILE_COUNT" -gt 0 ]; then
        echo "Extracting site content from gh-pages..."
        
        # Clean any existing site directory
        rm -rf site
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

echo "🎉 Vercel build completed successfully!"
echo "Static site is ready in ./site directory for Vercel deployment"