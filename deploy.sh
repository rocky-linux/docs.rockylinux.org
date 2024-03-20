#!/bin/bash

cleanup() {
    echo -e "\nScript interrupted. Exiting..."
    exit 1
}

trap cleanup INT

source .envrc

FASTLY=$(command -v fastly)
test -x "$FASTLY" || exit 2

if [[ -z $FASTLY_API_TOKEN ]]; then
  # shellcheck disable=2016
  echo 'missing $FASTLY_API_TOKEN'; exit 1
fi
if [[ -z $FASTLY_SERVICE_ID ]]; then
  # shellcheck disable=2016
  echo 'missing $FASTLY_API_TOKEN'; exit 1
fi

pushd compute-js || exit $?
npm install
$FASTLY compute build || exit $?
$FASTLY compute deploy -p pkg/resf-rocky-linux-docs.tar.gz || exit $?

popd || exit
