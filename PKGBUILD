# Maintainer: Berk Küçük <dev.berkkucukk@gmail.com>
#
# maze-python — the shared Python runtime of the Maze desktop apps.
#
# One virtual environment, /opt/maze/venv, built here at package time from
# requirements.txt and shipped as ordinary package files. maze-guard,
# maze-cloak, haze, hazedrop, qlam and sentinai depend on this package and
# run as `/opt/maze/venv/bin/python3 <their code>` — none of them creates a
# venv of its own any more. Before this, each shipped a private venv with its
# own copy of Qt (three copies of PyQt6-Qt6 on one machine, ~970 MB), which
# pacman never tracked and a Python major upgrade silently broke.
#
# Every file of the venv belongs to this package, so pacman -Qkk sees it,
# pacman -R removes it, and an upgrade replaces it atomically.
#
# Python is pinned to one minor version: the venv's site-packages are built
# for it, so when Arch moves to the next Python this package has to be rebuilt
# first — pacman refuses the partial upgrade instead of leaving six broken
# apps behind, which is exactly the behaviour every python-* package has.
#
# dbus-python is not built here (it needs a compiler and D-Bus/GLib headers at
# build time); the system python-dbus package is linked into the venv instead,
# which is safe because the venv runs the very same interpreter.

pkgname=maze-python
pkgver=1.0.0
pkgrel=1
pkgdesc="Shared Python virtual environment for the Maze Linux desktop apps (/opt/maze/venv)"
arch=('x86_64')
url="https://mazelinux.berkkucukk.com.tr"
license=('GPL-3.0-or-later')
depends=(
    'python>=3.14' 'python<3.15'
    'python-dbus'        # linked into the venv (maze-guard: NetworkManager)
    'libgl'              # PyQt6 wheels
    'libxkbcommon'
    'fontconfig'
    'portaudio'          # sounddevice (haze)
    'dbus'
)
makedepends=('python-pip')
# The venv's .so files are prebuilt wheels, not something makepkg compiled —
# stripping them just floods the log and the -debug split is meaningless.
options=('!strip' '!debug')
source=('requirements.txt' 'maze-python')
sha256sums=('SKIP' 'SKIP')

_venv="/opt/maze/venv"

package() {
    # Build the venv at its final absolute path so nothing inside it ever
    # carries a build-time prefix (pyvenv.cfg, the bin/ shebangs, RECORD).
    install -dm755 "$pkgdir$_venv"
    python -m venv "$pkgdir$_venv"
    "$pkgdir$_venv/bin/pip" install --quiet --upgrade pip
    "$pkgdir$_venv/bin/pip" install --quiet --no-warn-script-location \
        -r "$srcdir/requirements.txt"

    # The interpreter is the system one; everything the fakeroot prefix
    # leaked into has to point at the real path.
    find "$pkgdir$_venv/bin" -type f -exec sed -i "s|$pkgdir||g" {} +
    sed -i "s|$pkgdir||g" "$pkgdir$_venv/pyvenv.cfg"
    find "$pkgdir$_venv" -name 'RECORD' -exec sed -i "s|$pkgdir||g" {} +

    # python-dbus from the system, by symlink — same interpreter, same ABI.
    local _sys_site _venv_site
    _sys_site="$(python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"
    _venv_site="$(find "$pkgdir$_venv/lib" -maxdepth 2 -type d -name site-packages | head -1)"
    for _item in dbus _dbus_bindings _dbus_glib_bindings; do
        for _p in "$_sys_site/$_item" "$_sys_site/$_item".*.so; do
            [[ -e "$_p" ]] && ln -sf "$_p" "$_venv_site/$(basename "$_p")"
        done
    done

    # Byte-code caches are per-machine noise: they carry absolute paths and
    # timestamps, pacman would have to track thousands of them, and Python
    # rebuilds them on first import anyway.
    find "$pkgdir$_venv" -type d -name __pycache__ -prune -exec rm -rf {} +
    # Python's Unicode easter-egg symlink (𝜋thon): bsdtar cannot encode the name.
    find "$pkgdir$_venv/bin" -name '*𝜋*' -delete

    # A convenience entry point for scripts and for people poking at the env.
    install -Dm755 "$srcdir/maze-python" "$pkgdir/usr/bin/maze-python"
    install -Dm644 "$srcdir/requirements.txt" "$pkgdir/opt/maze/requirements.txt"
}
