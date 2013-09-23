#!/bin/bash

set -ex

su - publication -c '
set -ex

cd publication/
git checkout master
git pull

cd site
rm -r dist/
cabal-dev install
'
stop publication || true
sleep 1
start publication
