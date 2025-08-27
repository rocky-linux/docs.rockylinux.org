#!/bin/bash

set -e

echo "=== COMPREHENSIVE DEBUG: VERCEL BUILD ENVIRONMENT ANALYSIS ==="

# Create the site directory first
mkdir -p site

# Function to log both to console and to HTML file
log_to_both() {
    echo "$1"
    echo "<p><strong>$(date)</strong>: $1</p>" >> site/debug.html
}

# Function to log command output to both console and HTML
log_command_to_both() {
    local cmd="$1"
    local description="$2"
    
    echo "=== $description ==="
    echo "<h3>$description</h3>" >> site/debug.html
    echo "<h4>Command: <code>$cmd</code></h4>" >> site/debug.html
    echo "<pre>" >> site/debug.html
    
    # Run command and capture output
    if output=$(eval "$cmd" 2>&1); then
        echo "$output"
        echo "$output" >> site/debug.html
        echo "</pre><p style='color: green;'>✅ Success</p>" >> site/debug.html
    else
        echo "❌ Command failed: $output"
        echo "$output" >> site/debug.html
        echo "</pre><p style='color: red;'>❌ Failed</p>" >> site/debug.html
    fi
    echo "" >> site/debug.html
}

# Initialize HTML debug file
cat > site/debug.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Vercel Build Debug Analysis</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #0070f3; }
        h2 { color: #333; border-bottom: 2px solid #0070f3; }
        h3 { color: #666; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 5px; overflow-x: auto; }
        code { background: #f0f0f0; padding: 2px 5px; border-radius: 3px; }
        .success { color: green; }
        .error { color: red; }
        .info { color: blue; }
    </style>
</head>
<body>
    <h1>🔍 Vercel Build Environment Debug Analysis</h1>
    <p><em>Generated during build process to understand the environment</em></p>
    
EOF

log_to_both "=== STARTING COMPREHENSIVE DEBUG ANALYSIS ==="

# Install dependencies first
log_to_both "Installing dependencies..."
pip3 install -r requirements.txt

log_to_both ""
log_to_both "=== BASIC ENVIRONMENT INFORMATION ==="
log_command_to_both "pwd" "Current Working Directory"
log_command_to_both "whoami" "Current User"
log_command_to_both "date" "Current Date/Time"
log_command_to_both "echo \$HOME" "Home Directory"

log_to_both ""
log_to_both "=== PATH ANALYSIS ==="
echo "<h3>PATH Analysis</h3>" >> site/debug.html
echo "<h4>Full PATH:</h4>" >> site/debug.html
echo "<pre>$PATH</pre>" >> site/debug.html

# Break down PATH into components
echo "<h4>PATH Components:</h4>" >> site/debug.html
echo "<ol>" >> site/debug.html
IFS=':' read -ra ADDR <<< "$PATH"
for i in "${ADDR[@]}"; do
    echo "<li><code>$i</code>" >> site/debug.html
    if [ -d "$i" ]; then
        echo " - ✅ EXISTS</li>" >> site/debug.html
    else
        echo " - ❌ MISSING</li>" >> site/debug.html
    fi
done
echo "</ol>" >> site/debug.html

log_to_both ""
log_to_both "=== PYTHON ENVIRONMENT ==="
log_command_to_both "python3 --version" "Python Version"
log_command_to_both "which python3" "Python Location"
log_command_to_both "which pip3" "Pip Location"
log_command_to_both "python3 -c \"import sys; print('Executable:', sys.executable)\"" "Python Executable Path"
log_command_to_both "python3 -c \"import site; print('Site packages:', site.getsitepackages())\"" "Site Packages Location"

log_to_both ""
log_to_both "=== PACKAGE INSTALLATION VERIFICATION ==="
log_command_to_both "pip3 show mkdocs" "MkDocs Package Info"
log_command_to_both "pip3 show mike" "Mike Package Info"

log_to_both ""
log_to_both "=== CONSOLE SCRIPT DETECTION ==="

# Check all possible bin directories systematically
BIN_DIRS=(
    "/usr/local/bin"
    "/usr/bin" 
    "$(python3 -c 'import sys, os; print(os.path.dirname(sys.executable))' 2>/dev/null)"
    "$(python3 -c 'import site; import os; print(os.path.join(os.path.dirname(site.getsitepackages()[0]), \"bin\"))' 2>/dev/null)"
    "$HOME/.local/bin"
)

echo "<h3>Checking Console Scripts in Various Directories</h3>" >> site/debug.html
echo "<table border='1' style='border-collapse: collapse; width: 100%;'>" >> site/debug.html
echo "<tr><th>Directory</th><th>Exists</th><th>mkdocs</th><th>mike</th><th>Contents (first 10)</th></tr>" >> site/debug.html

for bin_dir in "${BIN_DIRS[@]}"; do
    if [ -n "$bin_dir" ] && [ "$bin_dir" != "None" ]; then
        echo "<tr>" >> site/debug.html
        echo "<td><code>$bin_dir</code></td>" >> site/debug.html
        
        if [ -d "$bin_dir" ]; then
            echo "<td style='color: green;'>✅ YES</td>" >> site/debug.html
            
            # Check for mkdocs
            if [ -f "$bin_dir/mkdocs" ]; then
                echo "<td style='color: green;'>✅ FOUND</td>" >> site/debug.html
            else
                echo "<td style='color: red;'>❌ MISSING</td>" >> site/debug.html
            fi
            
            # Check for mike
            if [ -f "$bin_dir/mike" ]; then
                echo "<td style='color: green;'>✅ FOUND</td>" >> site/debug.html
            else
                echo "<td style='color: red;'>❌ MISSING</td>" >> site/debug.html
            fi
            
            # List contents
            echo "<td><pre style='max-height: 100px; overflow-y: auto;'>" >> site/debug.html
            ls -la "$bin_dir" 2>/dev/null | head -10 | while read line; do
                echo "$line" >> site/debug.html
            done
            echo "</pre></td>" >> site/debug.html
        else
            echo "<td style='color: red;'>❌ NO</td>" >> site/debug.html
            echo "<td>N/A</td><td>N/A</td><td>N/A</td>" >> site/debug.html
        fi
        echo "</tr>" >> site/debug.html
    fi
done
echo "</table>" >> site/debug.html

log_to_both ""
log_to_both "=== COMMAND AVAILABILITY TESTS ==="
log_command_to_both "which mkdocs" "mkdocs in PATH"
log_command_to_both "which mike" "mike in PATH"

log_to_both ""
log_to_both "=== PYTHON MODULE IMPORT TESTS ==="
log_command_to_both "python3 -c \"import mkdocs; print('✅ mkdocs module imported')\"" "MkDocs Module Import"
log_command_to_both "python3 -c \"import mike; print('✅ mike module imported')\"" "Mike Module Import"
log_command_to_both "python3 -c \"from mkdocs.__main__ import cli; print('✅ mkdocs CLI imported')\"" "MkDocs CLI Import"
log_command_to_both "python3 -c \"from mike.driver import main; print('✅ mike driver imported')\"" "Mike Driver Import"

log_to_both ""
log_to_both "=== EXECUTION METHOD TESTS ==="
log_command_to_both "python3 -m mkdocs --version" "python3 -m mkdocs"
log_command_to_both "python3 -c \"import sys; sys.argv=['mike', '--version']; from mike.driver import main; main()\"" "python3 -c mike.driver"

# Try direct commands if available
if command -v mkdocs >/dev/null 2>&1; then
    log_command_to_both "mkdocs --version" "Direct mkdocs command"
else
    log_to_both "❌ mkdocs command not available in PATH"
    echo "<p style='color: red;'>❌ mkdocs command not available in PATH</p>" >> site/debug.html
fi

if command -v mike >/dev/null 2>&1; then
    log_command_to_both "mike --version" "Direct mike command"
else
    log_to_both "❌ mike command not available in PATH"
    echo "<p style='color: red;'>❌ mike command not available in PATH</p>" >> site/debug.html
fi

log_to_both ""
log_to_both "=== FILE SYSTEM INFORMATION ==="
log_command_to_both "ls -la" "Current Directory Contents"
log_command_to_both "df -h ." "Disk Usage"

log_to_both ""
log_to_both "=== ENVIRONMENT VARIABLES ==="
echo "<h3>Key Environment Variables</h3>" >> site/debug.html
echo "<pre>" >> site/debug.html
env | grep -E "(PATH|PYTHON|PIP|HOME|USER|PWD|VIRTUAL)" | sort >> site/debug.html
echo "</pre>" >> site/debug.html

log_to_both ""
log_to_both "=== RECOMMENDED SOLUTION BASED ON FINDINGS ==="

# Determine the best approach
echo "<h3>🎯 Recommended Solution</h3>" >> site/debug.html

if command -v mike >/dev/null 2>&1 && command -v mkdocs >/dev/null 2>&1; then
    echo "<p style='color: green; font-size: 18px;'>✅ <strong>SOLUTION: Use direct commands</strong></p>" >> site/debug.html
    echo "<p>Both <code>mike</code> and <code>mkdocs</code> are available as shell commands.</p>" >> site/debug.html
    log_to_both "✅ RECOMMENDED: Use direct mike and mkdocs commands"
elif python3 -c "from mike.driver import main" 2>/dev/null && python3 -c "from mkdocs.__main__ import cli" 2>/dev/null; then
    echo "<p style='color: blue; font-size: 18px;'>💡 <strong>SOLUTION: Use Python module execution</strong></p>" >> site/debug.html
    echo "<p>Commands not in PATH, but Python modules are available. Use <code>python3 -c</code> approach.</p>" >> site/debug.html
    log_to_both "💡 RECOMMENDED: Use python3 -c with module imports"
else
    echo "<p style='color: red; font-size: 18px;'>❌ <strong>PROBLEM: Neither approach available</strong></p>" >> site/debug.html
    log_to_both "❌ PROBLEM: Neither direct commands nor Python modules work"
fi

# Create a simple index.html that redirects to debug.html
cat > site/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Debug Analysis - Rocky Linux Docs</title>
    <meta http-equiv="refresh" content="0; url=debug.html">
</head>
<body>
    <h1>Debug Analysis</h1>
    <p>Redirecting to <a href="debug.html">debug results</a>...</p>
    <p>If not redirected automatically, <a href="debug.html">click here</a>.</p>
</body>
</html>
EOF

# Close the HTML file
cat >> site/debug.html << 'EOF'
    
    <hr>
    <footer>
        <p><em>Debug analysis completed. This information helps determine the correct build approach for Vercel.</em></p>
        <p>🔗 <a href="index.html">Back to Index</a></p>
    </footer>
</body>
</html>
EOF

log_to_both ""
log_to_both "🎉 COMPREHENSIVE DEBUG ANALYSIS COMPLETED!"
log_to_both "📊 Results available at: https://docs-v3.vercel.app/debug.html"
log_to_both "🏠 Main page: https://docs-v3.vercel.app/index.html"

echo ""
echo "✅ Debug site created successfully!"
echo "📁 Generated files:"
echo "   - site/index.html (redirects to debug results)"
echo "   - site/debug.html (comprehensive analysis)"
echo ""
echo "🌐 View results at deployed URL: https://docs-v3.vercel.app/"