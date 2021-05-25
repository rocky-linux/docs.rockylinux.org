#!/bin/sh
set -e
if [[ "$ENV" != "dev" ]]; then
    rm -rf docs || true
    git clone https://github.com/hbjydev/rldocs docs
else
    echo 'Dev mode, not deleting `docs`.'
fi

npm run build