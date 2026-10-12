#!/usr/bin/env bash
# Rebuild the tested xdg-desktop-portal-wlr 0.8.4 window SHM fix from upstream.
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/xdpw-window-shm.XXXXXXXX")
trap 'rm -rf -- "$work"' EXIT
git clone --quiet --depth 1 --branch v0.8.4 https://github.com/emersion/xdg-desktop-portal-wlr.git "$work/source"
cd "$work/source"
git apply --check "$repo/patches/xdg-desktop-portal-wlr-0.8.4-window-shm.patch"
git apply "$repo/patches/xdg-desktop-portal-wlr-0.8.4-window-shm.patch"
meson setup build --buildtype=release
ninja -C build
dest="$HOME/.local/libexec/xdg-desktop-portal-wlr"
mkdir -p -- "$(dirname -- "$dest")"
if [[ -e $dest ]]; then cp -p -- "$dest" "$dest.backup-$(date +%Y%m%d-%H%M%S)"; fi
install -m 0755 build/xdg-desktop-portal-wlr "$dest"
echo "Installed $dest. Stop any share; restart the portal or log out and back in."
