#!/usr/bin/env bash

set -euxo pipefail -o posix

today=$(date +'%Y%m%d')

cd emacs
git fetch --all
git checkout master
git merge origin/master
git clean -fdx
cd ..

rm -rf "emacs-${today}"
cp -r emacs "emacs-${today}"

cd "emacs-${today}"
./autogen.sh
## for mac
# ./configure --prefix=$HOME/.local --with-tree-sitter --with-xwidgets --with-native-compilation=aot --with-imagemagick
## for omarchy
./configure --prefix=$HOME/.local --with-tree-sitter --with-xwidgets --with-native-compilation=aot --with-imagemagick --with-pgtk

make -j6
make install -j6

echo '=== Build Complete ==='
