#!/bin/bash
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
rm -rf _build/
make html
touch _build/html/.nojekyll
gh-pages --dotfiles --message "[skip ci] Update built docs" --dist _build/html