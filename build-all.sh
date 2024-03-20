#!/bin/bash

test -d build || mkdir build

cleanup() {
    echo -e "\nScript interrupted. Exiting..."
    exit 1
}

trap cleanup INT

source .envrc

# Build the site
mkdocs build -d build/site

# hardlink duplicates
command -v hardlink && hardlink -t build/site || echo "no hardlink in $PATH"

MINIFY=$(command -v minify || echo "./compute-js/bin/minify")
# minify everything
test -d build/minified || $MINIFY -r --sync --preserve=all -o build/minified build/site

STRIP_NONENGLISH_LOCALES=${STRIP_LOCALES:-true}
if ${STRIP_NONENGLISH_LOCALES}; then
  # remove locales from minified (Fastly) site
  for locale in $(yq -r '.plugins[] | select(type == "object" and has("i18n")) | .i18n.languages[].locale' < mkdocs.yml | grep -v 'en'); do
    rm -fr "build/minified/site/$locale"
  done
fi
