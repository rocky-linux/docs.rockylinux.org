#!/bin/bash

set -e

echo "=== DOCS BUILD - PRODUCTION ==="

# Install dependencies into a virtual environment
echo "Creating virtual environment and installing dependencies..."
uv venv --python 3.12 .venv
uv pip install -r requirements.txt

# --- PATCH START ---
echo "Patching mkdocs-awesome-pages-plugin for i18n stability..."

S_PKG=".venv/lib/python3.12/site-packages/mkdocs_awesome_pages_plugin"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS syntax
    sed -i '' 's/if item.children:/if hasattr(item, "children") and item.children:/g' "$S_PKG/navigation.py"
    sed -i '' 's/class MetaNavRestItem(MetaNavItem):/class MetaNavRestItem(MetaNavItem):\n    children = []\n    is_section = False\n    is_page = False\n    is_link = False/g' "$S_PKG/meta.py"
else
    # Linux syntax
    sed -i 's/if item.children:/if hasattr(item, "children") and item.children:/g' "$S_PKG/navigation.py"
    sed -i 's/class MetaNavRestItem(MetaNavItem):/class MetaNavRestItem(MetaNavItem):\n    children = []\n    is_section = False\n    is_page = False\n    is_link = False/g' "$S_PKG/meta.py"
fi

echo "Patch applied successfully."
# --- PATCH END ---


# Add venv bin to PATH so mike/mkdocs are found directly
export PATH="$(pwd)/.venv/bin:$PATH"

echo "Virtual environment created and added to PATH"

# FORCE cleanup of any existing content
echo "Force cleaning any existing directories..."
rm -rf rockydocs-* docs site 2>/dev/null || true

# Function to build a specific version from a specific branch
build_version() {
    local version=$1
    local branch=$2
    local alias=$3
    local title=$4
    
    echo "Building Rocky Linux $version from branch $branch..."
    
    # Clone the specific branch WITH FULL HISTORY for git-revision-date-localized-plugin
    local repo_dir="rockydocs-$version"
    echo "Cloning $branch with full git history..."
    git clone -b "$branch" https://github.com/rocky-linux/documentation.git "$repo_dir"
    
    # Verify clone worked
    if [ ! -d "$repo_dir" ]; then
        echo "ERROR: Failed to clone $branch branch"
        return 1
    fi
    
    # Instead of copying files, we need to work IN the cloned repo
    # to preserve git history for git-revision-date-localized-plugin
    echo "Working directly in cloned repo to preserve git history..."
    
    # Change to the cloned repo directory
    cd "$repo_dir"
    
    # Verify docs directory exists
    if [ ! -d "docs" ]; then
        echo "ERROR: No docs directory in $branch branch"
        cd ..
        return 1
    fi
    
    echo "Working in $repo_dir with preserved git history"
    
    # Deploy with mike using Python module execution + mkdocs wrapper
    # We need to go back to parent directory for mike operations
    cd ..
    
    # Create a symlink to preserve git history access
    rm -rf docs
    ln -sf "$repo_dir/docs" docs
    rm -rf include
    ln -sf "$repo_dir/include" include
    
    # Ensure mkdocs.yml is available for mike operations
    if [ ! -f "mkdocs.yml" ]; then
        ln -sf "configs/mkdocs.yml" mkdocs.yml
    fi
    
    echo "Created symlink to docs with preserved git history"
    
    # Initialize git repo in parent if not exists (for mike operations)
    if [ ! -d ".git" ]; then
        git init
        git config user.name "wsoyinka"
        git config user.email "webmaster@rockylinux.org"
        
        # Add the documentation repo as a worktree/submodule reference
        git add .
        git commit -m "Build commit for version $version $(date)"
    fi
    
    echo "Deploying version $version with preserved git history"
    if [ -n "$alias" ] && [ -n "$title" ]; then
        mike deploy "$version" "$alias" --title="$title"
    elif [ -n "$alias" ]; then
        mike deploy "$version" "$alias"
    elif [ -n "$title" ]; then
        mike deploy "$version" --title="$title"
    else
        mike deploy "$version"
    fi
    
    echo "Rocky Linux $version deployed successfully with git history preserved"
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
git add README.md
git commit -m "Initial commit for docs build $(date)"

# Build each version from its respective branch
build_version "8" "rocky-8" "" ""
build_version "9" "rocky-9" "" "" 
build_version "10" "main" "latest" ""

echo "Setting default version..."
mike set-default latest

echo "All versions deployed successfully"

# Verify mike state
echo "Verifying mike deployment..."
mike list

echo "Extracting built site with ROOT + VERSIONED deployment..."

# Clean any existing site directory
rm -rf site

# Extract from gh-pages
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "gh-pages branch found"
    
    BRANCH_FILE_COUNT=$(git ls-tree --name-only gh-pages | wc -l)
    echo "Files in gh-pages branch: $BRANCH_FILE_COUNT"
    
    if [ "$BRANCH_FILE_COUNT" -gt 0 ]; then
        echo "Extracting site content from gh-pages..."
        
        mkdir -p site
        git archive gh-pages | tar -x -C site
        
        if [ -d "site" ] && [ "$(ls -A site 2>/dev/null | wc -l)" -gt 0 ]; then
            echo "Site extracted successfully for deployment"
            echo "Site contents:"
            ls -la site/ | head -10
            
            # Deploy latest version to root for backward compatibility
            echo ""
            echo "Deploying latest version to ROOT for backward compatibility..."
            
            # Check if latest version directory exists in the extracted site
            if [ -d "site/latest" ]; then
                echo "Found latest version directory"
                
                # Copy latest version content to root, but preserve versioned structure
                echo "Copying latest version content to root..."
                
                # First, backup the version selector and other mike-generated files
                if [ -f "site/versions.json" ]; then
                    cp site/versions.json site/versions.json.backup
                    echo "Backed up versions.json"
                fi
                
                # Copy latest content to root (excluding version-specific metadata)
                # Use cp instead of rsync (not guaranteed present in CI images)
                cp -r site/latest/* site/ 2>/dev/null || true
                
                # Restore the versions.json to maintain version selector functionality
                if [ -f "site/versions.json.backup" ]; then
                    cp site/versions.json.backup site/versions.json
                    rm site/versions.json.backup
                    echo "Restored versions.json for version selector"
                fi
                
                # Ensure version directories are still accessible
                echo "Verifying versioned access..."
                if [ -d "site/8" ] && [ -d "site/9" ] && [ -d "site/10" ]; then
                    echo "Versioned directories (8, 9, 10) are accessible"
                else
                    echo "WARNING: Some versioned directories may be missing"
                fi
                
                # Verify root content
                if [ -f "site/index.html" ]; then
                    echo "Root index.html exists (latest content)"
                else
                    echo "ERROR: Root index.html missing!"
                    exit 1
                fi
                
                echo ""
                echo "ROOT + VERSIONED deployment successful!"
                echo "Access patterns:"
                echo "   • docs.rockylinux.org/          → Rocky Linux 10 (latest)"
                echo "   • docs.rockylinux.org/latest/   → Rocky Linux 10"
                echo "   • docs.rockylinux.org/10/       → Rocky Linux 10"  
                echo "   • docs.rockylinux.org/9/        → Rocky Linux 9"
                echo "   • docs.rockylinux.org/8/        → Rocky Linux 8"
                
            else
                echo "ERROR: Latest version directory not found in site!"
                echo "Available directories:"
                ls -la site/
                exit 1
            fi
        else
            echo "ERROR: Site extraction failed"
            exit 1
        fi
    else
        echo "ERROR: gh-pages branch is empty!"
        exit 1
    fi
else
    echo "ERROR: No gh-pages branch found!"
    exit 1
fi

echo ""
echo "Docs build completed successfully!"
echo "Features:"
echo "   • Backward compatibility: Latest content served from root"
echo "   • Version selector: Still works from any page"
echo "   • Existing bookmarks: Will continue to work"
echo "   • Versioned access: All versions accessible via /8/, /9/, /10/, /latest/"
echo "   • Git history: Preserved for accurate timestamps"
