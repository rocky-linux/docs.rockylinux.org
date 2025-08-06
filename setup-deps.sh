#!/bin/bash

cleanup() {
    echo -e "\nScript interrupted. Exiting..."
    exit 1
}

trap cleanup INT

if [[ $EUID -ne 0 ]]; then
   echo "please run as root"
   exit 2
fi

dnf -y module switch-to nodejs:22
dnf -y install /usr/bin/pip npm /usr/bin/curl /usr/bin/jq git-core

pip install 'urllib3<2' yq
pip install -r requirements.txt

# Only install insiders package if it's available and we've not asked for it to be skipped
# if [[ -n "$GH_TOKEN" ]]; then
#   pip install "git+https://${GH_TOKEN}@github.com/squidfunk/mkdocs-material-insiders.git"
# fi

# mkdocs optimize plugin requires pngquant
npm install -g pngquant

# minify for reducing deployment size
mkdir -p /root/.local/bin
test -x /root/.local/bin/minify || (curl -L https://github.com/tdewolff/minify/releases/download/v2.20.18/minify_linux_amd64.tar.gz | tar -C /root/.local/bin/ -xz minify)
