#!/bin/sh
# Regenerate cached startup files for kak-lsp and kak-tree-sitter.
# Run this whenever you upgrade either binary.
set -eu
cache_dir="${XDG_CONFIG_HOME:-$HOME/.config}/kak/cache"
mkdir -p "$cache_dir"
kak-lsp > "$cache_dir/kak-lsp.kak"
kak-tree-sitter -dks --init __CACHED__ > "$cache_dir/kak-tree-sitter.kak"
echo "Refreshed: $cache_dir/{kak-lsp,kak-tree-sitter}.kak"
