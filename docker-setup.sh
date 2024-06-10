#!/bin/sh
set -e

RTOOLS=https://github.com/r-windows/rtools-chocolatey/releases/download/6104/rtools44-toolchain-libs-base-6104.tar.zst
PACKAGES="git make perl curl texinfo texinfo-tex rsync zip unzip diffutils wget subversion"

# pacman --noconfirm -Syuu
# pacman --noconfirm -Syuu

pacman --noconfirm -S $PACKAGES
pacman --noconfirm -Scc

# TinyTex
PATH="$PATH:/c/Users/$USER/AppData/Roaming/TinyTeX/bin/windows"

# tlmgr.bat update --self
tlmgr.bat install texinfo
# tlmgr.bat list --only-installed


# Rtools
# curl -sSL $RTOOLS | tar x --force-local --zstd -C /c/
