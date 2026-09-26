# Maintainer: Berk Küçük <dev.berkkucukk@gmail.com>
#
# maze-python — the shared Python runtime of the Maze desktop apps.
#
# One virtual environment, /opt/maze/venv. maze-guard, maze-cloak, haze,
# hazedrop, qlam and sentinai depend on this package and run as
# `/opt/maze/venv/bin/python3 <their code>` — none of them creates a venv of
# its own any more. Before this, each shipped a private venv with its own copy
# of Qt (three copies of PyQt6-Qt6 on one machine, ~970 MB), which pacman
# never tracked and a Python major upgrade silently broke.
#
# WHERE THE LIBRARIES COME FROM (1.1.0). The venv is created with
# --system-site-packages, and every library that Arch packages is a plain
# pacman dependency below: python-pyqt6 uses the Qt6 the desktop already has,
# python-numpy, python-cryptography, ... come from an Arch mirror on the user's
# machine. Only the handful of libraries with no Arch package (see the pip-only
# block of requirements.txt) are pip-installed INTO the venv, with --no-deps,
# their own dependencies being Arch packages too. That is what keeps this
# package small: 1.0.0 shipped the whole resolved tree as wheels — 462 MB
# unpacked, 141 MB to download from the Maze repo — of which 250 MB was pip's
# PyQt6 wheel carrying a second, private Qt6 runtime (libicudata, libavcodec,
# Quick3D, Designer, Pdf...) next to the system one. Now it is a few MB.
#
# Every file of the venv belongs to this package, so pacman -Qkk sees it,
# pacman -R removes it, and an upgrade replaces it atomically.
#
# Python is pinned to one minor version: the venv's lib/python3.X path and the
# pip-only .so files are built for it, so when Arch moves to the next Python
# this package has to be rebuilt first — pacman refuses the partial upgrade
# instead of leaving six broken apps behind, which is exactly the behaviour
# every python-* package has.

pkgname=maze-python
pkgver=1.1.0
pkgrel=2
pkgdesc="Shared Python virtual environment for the Maze Linux desktop apps (/opt/maze/venv)"
arch=('x86_64')
url="https://mazelinux.berkkucukk.com.tr"
license=('GPL-3.0-or-later')
depends=(
    'python>=3.14' 'python<3.15'
    'python-dbus'              # maze-guard: NetworkManager over D-Bus
    'dbus'

    # ── Qt (maze-guard, maze-cloak, haze, hazedrop, qlam, sentinai) ──
    'python-pyqt6'             # system Qt6, not pip's bundled copy
    'python-qasync'            # maze-guard, hazedrop
    'python-qtawesome'         # qlam

    # ── network / crypto (maze-guard, haze, hazedrop) ──
    'scapy'                    # maze-guard
    'python-httpx'             # maze-guard, google-genai
    'python-cryptography'      # maze-guard, haze, hazedrop
    'python-stem'              # haze, hazedrop
    'python-python-socks'      # haze, hazedrop
    'python-aiohttp'           # haze, hazedrop
    'python-argon2-cffi'       # hazedrop

    # ── media / misc (haze, hazedrop, qlam) ──
    'python-qrcode' 'python-pillow'   # haze, hazedrop
    'python-numpy'             # haze
    'python-click'             # hazedrop
    'python-rich'              # hazedrop
    'python-watchdog'          # qlam
    'python-cffi' 'portaudio'  # sounddevice (haze voice notes)

    # ── sentinai ──
    'python-dotenv'
    'python-beautifulsoup4'    # also googlesearch-python, social-analyzer
    'python-requests'          # google-genai, googlesearch-python, social-analyzer
    # google-genai
    'python-anyio' 'python-google-auth' 'python-pydantic' 'python-tenacity'
    'python-websockets' 'python-typing_extensions' 'python-distro' 'python-sniffio'
    # selenium
    'python-certifi' 'python-trio' 'python-trio-websocket' 'python-urllib3'
    'python-pysocks' 'python-websocket-client'
    # social-analyzer
    'python-langdetect' 'python-lxml' 'python-termcolor' 'python-tld'
)
makedepends=('python-pip')
# The pip-only .so files are prebuilt wheels, not something makepkg compiled —
# stripping them just floods the log and the -debug split is meaningless.
options=('!strip' '!debug')
source=('requirements.txt' 'maze-python')
sha256sums=('SKIP' 'SKIP')

_venv="/opt/maze/venv"

package() {
    # Build the venv at its final absolute path so nothing inside it ever
    # carries a build-time prefix (pyvenv.cfg, the bin/ shebangs, RECORD).
    #
    # --system-site-packages: the Arch python-* packages in depends= are what
    # the apps import; the venv only adds the pip-only layer on top.
    # --without-pip: a private pip is ~5 MB of package for nothing — the
    # system pip can operate on this venv with `pip --python`, which is how
    # the pip-only libraries are installed right here.
    install -dm755 "$pkgdir$_venv"
    python -m venv --system-site-packages --without-pip "$pkgdir$_venv"

    # Only the pip-only block of requirements.txt is uncommented; --no-deps
    # because every dependency of those libraries is an Arch package listed in
    # depends= (pip would otherwise download its own copies of them).
    pip --python "$pkgdir$_venv/bin/python3" install --quiet \
        --no-deps --no-warn-script-location \
        --require-virtualenv \
        -r "$srcdir/requirements.txt"

    # The interpreter is the system one; everything the fakeroot prefix
    # leaked into has to point at the real path.
    find "$pkgdir$_venv/bin" -type f -exec sed -i "s|$pkgdir||g" {} +
    sed -i "s|$pkgdir||g" "$pkgdir$_venv/pyvenv.cfg"
    find "$pkgdir$_venv" -name 'RECORD' -exec sed -i "s|$pkgdir||g" {} +

    # selenium's universal wheel carries its Rust helper (selenium-manager) for
    # every platform — 15 MB of macOS/Windows/arm64 binaries this x86_64 package
    # can never run. Keep only linux-x86_64 (and drop it from RECORD so
    # pacman -Qkk and pip stay consistent).
    local _venv_site
    _venv_site="$(find "$pkgdir$_venv/lib" -maxdepth 2 -type d -name site-packages | head -1)"
    if [[ -d "$_venv_site/selenium/webdriver/common" ]]; then
        for _plat in macos windows linux-arm64; do
            rm -rf "$_venv_site/selenium/webdriver/common/$_plat"
            sed -i "\|^selenium/webdriver/common/$_plat/|d" "$_venv_site"/selenium-*.dist-info/RECORD
        done
    fi

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
