#!/usr/bin/env bash
#
# install.sh - symlink tmux config files to $HOME
#
# Usage: ./install.sh
#
# This script finds all tmux-related dotfiles (e.g. .tmux.conf, .tmux.conf.local)
# in the same directory as this script, and creates symbolic links in $HOME
# pointing to them. Existing files will be backed up with a .bak suffix before
# being replaced.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Glob for tmux config files
shopt -s nullglob
files=("$SCRIPT_DIR"/.tmux*)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "No .tmux* files found in $SCRIPT_DIR"
    exit 0
fi

for src in "${files[@]}"; do
    filename="$(basename "$src")"
    target="$HOME/$filename"

    # Already correctly linked — skip
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        echo "OK   $target -> $src (already linked)"
        continue
    fi

    # Back up any existing file/link that is in the way
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
        echo "BACKUP $target -> $backup"
        mv "$target" "$backup"
    fi

    ln -s "$src" "$target"
    echo "LINK $target -> $src"
done

echo "Done."
