#!/bin/bash

set -e

echo "=== DEBUG SCRIPT: VERCEL ENVIRONMENT ANALYSIS ==="

echo ""
echo "=== BASIC ENVIRONMENT ==="
echo "Working directory: $(pwd)"
echo "User: $(whoami)"
echo "PATH: $PATH"
echo "PYTHON: $(which python3)"
echo "PIP: $(which pip3)"

echo ""
echo "=== PYTHON ENVIRONMENT ==="
python3 --version
python3 -c "import sys; print('Python executable:', sys.executable)"
python3 -c "import site; print('Site packages:', site.getsitepackages())"

echo ""
echo "=== PIP INSTALLATION PATHS ==="
# Install dependencies first
echo "Installing dependencies..."
pip3 install -r requirements.txt

echo ""
echo "After pip install, checking locations..."
pip3 show mkdocs | grep "Location:"
pip3 show mike | grep "Location:"

echo ""
echo "=== LOOKING FOR CONSOLE SCRIPTS ==="
# Try to find where pip installs console scripts
PYTHON_SITE_PACKAGES=$(python3 -c "import site; print(site.getsitepackages()[0])")
echo "Site packages: $PYTHON_SITE_PACKAGES"

# Check for various bin directory possibilities
for bin_path in \
    "$(python3 -c 'import sys, os; print(os.path.dirname(sys.executable))')" \
    "$(dirname "$PYTHON_SITE_PACKAGES")/bin" \
    "$(dirname "$(dirname "$PYTHON_SITE_PACKAGES")")/bin" \
    "/usr/local/bin" \
    "/opt/python/bin" \
    "$HOME/.local/bin"
do
    if [ -d "$bin_path" ]; then
        echo ""
        echo "=== CHECKING BIN DIR: $bin_path ==="
        echo "Directory exists: YES"
        if [ -f "$bin_path/mkdocs" ]; then
            echo "mkdocs found: YES ($bin_path/mkdocs)"
            ls -la "$bin_path/mkdocs"
        else
            echo "mkdocs found: NO"
        fi
        if [ -f "$bin_path/mike" ]; then
            echo "mike found: YES ($bin_path/mike)"
            ls -la "$bin_path/mike"
        else
            echo "mike found: NO"
        fi
        echo "Sample contents of $bin_path:"
        ls -la "$bin_path" 2>/dev/null | head -10 || echo "Cannot list directory"
    else
        echo "Directory $bin_path: DOES NOT EXIST"
    fi
done

echo ""
echo "=== TESTING PYTHON MODULE ACCESS ==="
python3 -c "import mkdocs; print('✅ mkdocs module imported successfully')" 2>/dev/null || echo "❌ mkdocs module import failed"
python3 -c "import mike; print('✅ mike module imported successfully')" 2>/dev/null || echo "❌ mike module import failed"
python3 -c "from mkdocs.__main__ import cli; print('✅ mkdocs CLI imported successfully')" 2>/dev/null || echo "❌ mkdocs CLI import failed"  
python3 -c "from mike.driver import main; print('✅ mike driver imported successfully')" 2>/dev/null || echo "❌ mike driver import failed"

echo ""
echo "=== TESTING COMMAND AVAILABILITY ==="
which mkdocs 2>/dev/null && echo "✅ mkdocs command found: $(which mkdocs)" || echo "❌ mkdocs command not found"
which mike 2>/dev/null && echo "✅ mike command found: $(which mike)" || echo "❌ mike command not found"

echo ""
echo "=== TESTING PYTHON EXECUTION ==="
echo "Testing python3 -m mkdocs --help:"
python3 -m mkdocs --help 2>&1 | head -3 || echo "❌ python3 -m mkdocs failed"

echo ""
echo "Testing python3 -m mike --help:"  
python3 -m mike --help 2>&1 | head -3 || echo "❌ python3 -m mike failed"

echo ""
echo "Testing python3 -c with mike.driver:"
python3 -c "import sys; sys.argv=['mike', '--help']; from mike.driver import main; main()" 2>&1 | head -3 || echo "❌ mike.driver failed"

echo ""
echo "=== ENVIRONMENT VARIABLES ==="
echo "VIRTUAL_ENV: ${VIRTUAL_ENV:-NOT SET}"
echo "PYTHONPATH: ${PYTHONPATH:-NOT SET}"  
echo "HOME: $HOME"
echo "USER: ${USER:-NOT SET}"

echo ""
echo "=== FILE SYSTEM INFO ==="
echo "Current directory contents:"
ls -la | head -10

echo ""
echo "=== DEBUG COMPLETE ==="
echo "This information will help determine the correct approach for Vercel!"

# Create a simple site directory so Vercel doesn't fail
mkdir -p site
echo "<html><body><h1>Debug Complete - Check Logs</h1></body></html>" > site/index.html

echo "✅ Debug script completed successfully"