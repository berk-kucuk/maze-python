# maze-python

The shared Python runtime of the Maze desktop apps: one virtual environment at
`/opt/maze/venv`. maze-guard, maze-cloak, haze, hazedrop, qlam and sentinai
depend on it and run as `/opt/maze/venv/bin/python3 <their code>`; none of
them creates a venv of its own.

- The venv uses `--system-site-packages`: every library Arch packages
  (PyQt6, numpy, cryptography, …) is a plain pacman dependency and comes from
  an Arch mirror.
- Only the few libraries with no Arch package (the pip-only block of
  `requirements.txt`) are installed into the venv, so the package stays a few
  MB.
- Every file of the venv belongs to the package: `pacman -Qkk` checks it,
  `pacman -R` removes it, an upgrade replaces it atomically.
- Python is pinned to one minor version. When Arch moves to the next Python,
  this package is rebuilt first; until then pacman refuses the partial
  upgrade instead of leaving the apps broken.

## Installation

### From the Maze repository

**On Maze Linux** the repository is already configured:

```bash
sudo pacman -S maze-python
```

**On Arch Linux and Arch-based distributions**, add the repository once:

1. Import and trust the Maze signing key:

   ```bash
   curl -O https://mazerepo.berkkucukk.com.tr/packages/mazelinux.gpg
   gpg --show-keys --with-fingerprint mazelinux.gpg
   sudo pacman-key --add mazelinux.gpg
   sudo pacman-key --lsign-key 7C4D515A6B930CB04794CEF6147C8159B3E2EE5F
   ```

   The fingerprint `gpg` prints must be `7C4D 515A 6B93 0CB0 4794  CEF6 147C 8159 B3E2 EE5F`.

2. Add the repository to the end of `/etc/pacman.conf`:

   ```ini
   [mazelinux]
   SigLevel = Required DatabaseOptional
   Server = https://mazerepo.berkkucukk.com.tr/packages
   ```

3. Sync and install:

   ```bash
   sudo pacman -Syu maze-python
   ```

Optionally install `mazelinux-keyring` as well; it keeps the signing key up to date through pacman.

Remove with `sudo pacman -Rns maze-python`.

### Build from source

```bash
sudo pacman -S --needed base-devel git
git clone https://github.com/berk-kucuk/maze-python.git
cd maze-python
makepkg -si
```

## License

Copyright © 2026 Berk Küçük

Released under the GNU General Public License v3.0 — see [LICENSE](LICENSE).
