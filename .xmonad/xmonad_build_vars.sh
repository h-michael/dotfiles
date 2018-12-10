#!/usr/bin/env bash
#
# Set config values used for building and running xmonad and taffybar.

# The directory in $HOME with all the XMonad stuff.
export XMONAD_DIR="${HOME}/.xmonad"

# A directory to use to install the taffybar and xmonad binaries.
export XMONAD_LOCAL_BIN_PATH="${XMONAD_DIR}/local-bin"

# The lts resolver we will use for building with stack.
export XMONAD_STACK_RESOLVER="lts-9.14"

# export XMONAD_TAFFYBAR_VERSION="taffybar-3.0.0"

# export XMONAD_GTK_TRAYMANAGER_VERSION="gtk-traymanager-1.0.1"
