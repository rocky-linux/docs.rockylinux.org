#!/bin/bash

set -e

echo "=== SIMPLE DEBUG: VERCEL BUILD ENVIRONMENT ANALYSIS ==="

# Create the site directory first
mkdir -p site

# Install dependencies first
echo "Installing dependencies..."
pip3 install -r requirements.txt

echo ""
echo "=== BASIC ENVIRONMENT INFORMATION ==="
echo "Working directory: $(pwd)"
echo "User: $(whoami)"
echo "Date: $(date)"
echo "HOME: $HOME"

echo ""
echo "=== PATH ANALYSIS ==="
echo "Full PATH: $PATH"

echo ""
echo "=== PYTHON ENVIRONMENT ==="
echo "Python version: $(python3 --version)"
echo "Python location: $(which python3)"
echo "Pip location: $(which pip3)"

echo ""
echo "=== PACKAGE VERIFICATION ==="
echo "MkDocs installed: $(python3 -c 'import mkdocs; print(mkdocs.__version__)' 2>/dev/null || echo 'NOT FOUND')"
echo "Mike installed: $(python3 -c 'import mike; print(mike.__version__)' 2>/dev/null || echo 'NOT FOUND')"

echo ""
echo "=== COMMAND AVAILABILITY TESTS ==="
echo "mkdocs in PATH: $(which mkdocs 2>/dev/null || echo 'NOT FOUND')"
echo "mike in PATH: $(which mike 2>/dev/null || echo 'NOT FOUND')"

echo ""
echo "=== DIRECTORY CHECKS ==="
echo "Checking /usr/local/bin for scripts..."
if [ -d "/usr/local/bin" ]; then
    echo "mkdocs in /usr/local/bin: $( [ -f /usr/local/bin/mkdocs ] && echo 'YES' || echo 'NO' )"
    echo "mike in /usr/local/bin: $( [ -f /usr/local/bin/mike ] && echo 'YES' || echo 'NO' )"
    echo "Sample /usr/local/bin contents:"
    ls -la /usr/local/bin | head -10 || echo "Cannot list"
else
    echo "/usr/local/bin does not exist"
fi

echo ""
echo "=== EXECUTION TESTS ==="
echo "Testing python3 -m mkdocs:"
if python3 -m mkdocs --version >/dev/null 2>&1; then
    echo "✅ python3 -m mkdocs works"
    python3 -m mkdocs --version
else
    echo "❌ python3 -m mkdocs fails"
fi

echo ""
echo "Testing python3 -c mike.driver:"
if python3 -c "import sys; sys.argv=['mike', '--version']; from mike.driver import main; main()" >/dev/null 2>&1; then
    echo "✅ python3 -c mike.driver works"
    python3 -c "import sys; sys.argv=['mike', '--version']; from mike.driver import main; main()"
else
    echo "❌ python3 -c mike.driver fails"
fi

echo ""
echo "Testing direct commands:"
if mike --version >/dev/null 2>&1; then
    echo "✅ direct mike command works"
    mike --version
else
    echo "❌ direct mike command fails"
fi

if mkdocs --version >/dev/null 2>&1; then
    echo "✅ direct mkdocs command works"  
    mkdocs --version
else
    echo "❌ direct mkdocs command fails"
fi

# Create HTML results
cat > site/debug.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Simple Debug Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 5px; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>🔍 Simple Debug Results</h1>
EOF

# Add debug info to HTML
echo "<h2>Environment Check Results</h2>" >> site/debug.html
echo "<pre>" >> site/debug.html

echo "Working directory: $(pwd)" >> site/debug.html
echo "User: $(whoami)" >> site/debug.html
echo "Date: $(date)" >> site/debug.html
echo "PATH: $PATH" >> site/debug.html
echo "" >> site/debug.html

echo "Python: $(python3 --version)" >> site/debug.html
echo "Python location: $(which python3)" >> site/debug.html
echo "Pip location: $(which pip3)" >> site/debug.html
echo "" >> site/debug.html

echo "MkDocs installed: $(python3 -c 'import mkdocs; print(mkdocs.__version__)' 2>/dev/null || echo 'NOT FOUND')" >> site/debug.html
echo "Mike installed: $(python3 -c 'import mike; print(mike.__version__)' 2>/dev/null || echo 'NOT FOUND')" >> site/debug.html
echo "" >> site/debug.html

echo "mkdocs command: $(which mkdocs 2>/dev/null || echo 'NOT IN PATH')" >> site/debug.html
echo "mike command: $(which mike 2>/dev/null || echo 'NOT IN PATH')" >> site/debug.html
echo "" >> site/debug.html

if [ -f "/usr/local/bin/mkdocs" ]; then
    echo "mkdocs in /usr/local/bin: YES" >> site/debug.html
else
    echo "mkdocs in /usr/local/bin: NO" >> site/debug.html
fi

if [ -f "/usr/local/bin/mike" ]; then
    echo "mike in /usr/local/bin: YES" >> site/debug.html
else
    echo "mike in /usr/local/bin: NO" >> site/debug.html
fi

echo "" >> site/debug.html

# Test results
if python3 -m mkdocs --version >/dev/null 2>&1; then
    echo "✅ python3 -m mkdocs: WORKS" >> site/debug.html
else
    echo "❌ python3 -m mkdocs: FAILS" >> site/debug.html
fi

if python3 -c "import sys; sys.argv=['mike', '--version']; from mike.driver import main; main()" >/dev/null 2>&1; then
    echo "✅ python3 -c mike.driver: WORKS" >> site/debug.html
else
    echo "❌ python3 -c mike.driver: FAILS" >> site/debug.html
fi

if mike --version >/dev/null 2>&1; then
    echo "✅ direct mike command: WORKS" >> site/debug.html
else
    echo "❌ direct mike command: FAILS" >> site/debug.html
fi

if mkdocs --version >/dev/null 2>&1; then
    echo "✅ direct mkdocs command: WORKS" >> site/debug.html
else
    echo "❌ direct mkdocs command: FAILS" >> site/debug.html
fi

echo "</pre>" >> site/debug.html

# Add recommendation
echo "<h2>🎯 Recommendation</h2>" >> site/debug.html

if mike --version >/dev/null 2>&1 && mkdocs --version >/dev/null 2>&1; then
    echo "<p style='color: green; font-size: 18px;'><strong>✅ USE DIRECT COMMANDS</strong></p>" >> site/debug.html
    echo "<p>Both mike and mkdocs commands are available directly.</p>" >> site/debug.html
elif python3 -c "from mike.driver import main" >/dev/null 2>&1; then
    echo "<p style='color: blue; font-size: 18px;'><strong>💡 USE PYTHON MODULES</strong></p>" >> site/debug.html
    echo "<p>Commands not in PATH, use: <code>python3 -c \"import sys; sys.argv=['mike',...]; from mike.driver import main; main()\"</code></p>" >> site/debug.html
else
    echo "<p style='color: red; font-size: 18px;'><strong>❌ PROBLEM</strong></p>" >> site/debug.html
    echo "<p>Neither direct commands nor Python modules work properly.</p>" >> site/debug.html
fi

cat >> site/debug.html << 'EOF'
    
    <hr>
    <p><em>Debug completed. Check results above to determine the correct build approach.</em></p>
</body>
</html>
EOF

# Create simple index
cat > site/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Debug Results</title>
    <meta http-equiv="refresh" content="0; url=debug.html">
</head>
<body>
    <h1>Debug Analysis</h1>
    <p><a href="debug.html">View Debug Results</a></p>
</body>
</html>
EOF

echo ""
echo "✅ Simple debug completed successfully!"
echo "🌐 Results will be available at: https://docs-v3.vercel.app/"