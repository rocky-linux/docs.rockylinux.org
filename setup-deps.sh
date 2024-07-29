#!/bin/bash

cleanup() {
    echo -e "\nScript interrupted. Exiting..."
    exit 1
}

trap cleanup INT

pip install 'urllib3<2' yq
pip install -r requirements.txt

# Only install insiders package if it's available and we've not asked for it to be skipped
# if [[ -n "$GH_TOKEN" ]]; then
#   pip install "git+https://${GH_TOKEN}@github.com/squidfunk/mkdocs-material-insiders.git"
# fi

# mkdocs optimize plugin requires pngquant
npm install pngquant

# minify for reducing deployment size
mkdir -p compute-js/bin
test -x compute-js/bin/minify || (curl -L https://github.com/tdewolff/minify/releases/download/v2.20.18/minify_linux_amd64.tar.gz | tar -C compute-js/bin/ -xz minify)
