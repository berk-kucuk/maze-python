#!/usr/bin/env bash
# build.sh — build (and optionally install) the maze-python package.
#   ./build.sh            build  ->  ./maze-python-<ver>-<rel>-x86_64.pkg.tar.zst
#   ./build.sh --install  build, then install it with pacman
# Needs network: pip resolves requirements.txt against PyPI at build time.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
INSTALL=0
[ "${1:-}" = "--install" ] && INSTALL=1
echo ">> building maze-python with makepkg…"
makepkg -f --nodeps
PKGFILE=$(ls -t maze-python-*.pkg.tar.* 2>/dev/null | head -1 || true)
[ -n "$PKGFILE" ] || { echo "build.sh: no package produced" >&2; exit 1; }
rm -rf pkg src
echo ">> built: $PKGFILE"
if [ "$INSTALL" -eq 1 ]; then
  sudo pacman -U --noconfirm "$PKGFILE"
fi
echo ">> done."
