#!/bin/bash

test -d build || mkdir build

cleanup() {
    echo -e "\nScript interrupted. Exiting..."
    exit 1
}

trap cleanup INT

source .envrc

# Build the site
mkdocs build -d build/site || exit $?
 
# hardlink duplicates
command -v hardlink && hardlink -t build/site || echo "no hardlink in $PATH"

MINIFY=$(command -v minify || echo "./compute-js/bin/minify")
# minify everything
test -d build/minified || $MINIFY -r --sync --preserve=all -o build/minified build/site

STRIP_NONENGLISH_LOCALES_SEARCH=true
if ${STRIP_NONENGLISH_LOCALES_SEARCH}; then
  locales=$(yq -r '.plugins[] | select(type == "object" and has("i18n")) | .i18n.languages[].locale' < mkdocs.yml | grep -v '^en$' | jq -R . | jq -s .)

  search_index='build/minified/site/search/search_index.json'
  tmp=$(mktemp)
  jq --argjson prefixes "$locales" \
    '.docs |= map(select([ $prefixes[] as $p | .location | startswith($p) ] | any | not))' < $search_index > "$tmp"
  mv "$tmp" $search_index
fi

