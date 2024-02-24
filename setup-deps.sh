#!/bin/bash

cleanup() {
    echo -e "\nScript interrupted. Exiting..."
    exit 1
}

trap cleanup INT

pip install 'urllib3<2' yq
pip install -r requirements.txt

# Only install insiders package if it's available
if [[ -n "$GH_TOKEN" ]]; then
  pip install "git+https://${GH_TOKEN}@github.com/squidfunk/mkdocs-material-insiders.git"
fi

test -d compute-js/bin || mkdir compute-js/bin
test -x compute-js/bin/fastly || ( curl -L https://github.com/fastly/cli/releases/download/v10.8.3/fastly_v10.8.3_linux-amd64.tar.gz | tar -xzf /dev/stdin -C compute-js/bin/ )

# mkdocs optimize plugin requires pngquant
npm install pngquant

# minify for reducing deployment size
test -x compute-js/bin/minify || (curl -L https://github.com/tdewolff/minify/releases/download/v2.20.18/minify_linux_amd64.tar.gz | tar -C compute-js/bin/ -xz minify)

# jq (for yq)
test -x compute-js/bin/jq || curl -L https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -o compute-js/bin/jq
chmod +x compute-js/bin/jq
