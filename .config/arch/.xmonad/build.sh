#!/usr/bin/env bash
#
# Build my XMonad and Taffybar binaries.

# Exit with an error message.
function die ()
{
	local msg="${1}"
	echo "${msg}" >&2
	exit 1
}

# Make sure we are in the ~/.xmonad/ directory, so that relative paths can
# be used in the following variables.
cd ~/.xmonad

# Input file paths
build_file_path="./build"
xmonad_build_vars_file_path="./xmonad_build_vars.sh"
xmonad_hs_file_path="./xmonad.hs"

# Source the xmonad build variables, like the LTS version to use.
source "${xmonad_build_vars_file_path}"

if [ "$?" -ne 0 ]
then
	die "Failed to source the xmonad_build_vars.sh file."
fi

# The input file with the newest modified time.
newest_settings_file="./build"

if [ "${xmonad_build_vars_file_path}" -nt "${newest_settings_file}" ]
then
	newest_settings_file="${xmonad_build_vars_file_path}"
fi

if [ "${xmonad_hs_file_path}" -nt "${newest_settings_file}" ]
then
	newest_settings_file="${xmonad_hs_file_path}"
fi

# Create the binary directory for things like taffybar and gtk2hs build tools.
mkdir -p "${XMONAD_LOCAL_BIN_PATH}"

gtkExe="${XMONAD_LOCAL_BIN_PATH}/gtk2hsC2hs"

# Install gtk2hs-buildtools (for taffybar) if the binary it produces doesn't
# exist, or if the settings files are newer than the gtk2hs-buildtools binary
# files.
if [[ ( ! -x "${gtkExe}" ) || ( "${newest_settings_file}" -nt "${gtkExe}" ) ]]
then
	PATH="${XMONAD_LOCAL_BIN_PATH}:${PATH}" stack install \
		--resolver "${XMONAD_STACK_RESOLVER}" \
		--local-bin-path "${XMONAD_LOCAL_BIN_PATH}" \
		--install-ghc \
		gtk2hs-buildtools

	if [ "$?" -ne 0 ]
	then
		die "Failed to install gtk2hs-buildtools (for taffybar)."
	fi
fi

taffybarExe="${XMONAD_LOCAL_BIN_PATH}/taffybar"

# Install taffybar if its executable doesn't exist, or if the settings files
# are newer than the taffybar executable.
if [[ ( ! -x "${taffybarExe}" ) || ( "${newest_settings_file}" -nt "${taffybarExe}" ) ]]
then
	PATH="${XMONAD_LOCAL_BIN_PATH}:${PATH}" stack install \
		--resolver "${XMONAD_STACK_RESOLVER}" \
		--local-bin-path "${XMONAD_LOCAL_BIN_PATH}" \
		--install-ghc \
		dbus \
		gtk-traymanager \
		libxml-sax \
		taffybar

	if [ "$?" -ne 0 ]
	then
		die "Failed to install taffybar."
	fi
fi

xmonadExe="${XMONAD_LOCAL_BIN_PATH}/xmonad"

# Install xmonad its executable doesn't exist, or if the settings files are
# newer than the xmonad executable.
if [[ ( ! -x "${xmonadExe}" ) || ( "${newest_settings_file}" -nt "${xmonadExe}" ) ]]
then
	# Install xmonad.
	PATH="${XMONAD_LOCAL_BIN_PATH}:${PATH}" stack install \
		--resolver "${XMONAD_STACK_RESOLVER}" \
		--local-bin-path "${XMONAD_LOCAL_BIN_PATH}" \
		--install-ghc \
		xmonad

	if [ "$?" -ne 0 ]
	then
		die "Failed to install xmonad."
	fi
fi

# Figure out what the binary name is for the output xmonad binary.
xmonadBin="${1}"
if [ "${xmonadBin}" == "" ]
then
	xmonadBin="./xmonad-x86_64-linux"
fi

# Build my xmonad executable it doesn't exist, or if the settings files are
# newer than the existing executable.
if [[ ( ! -x "${xmonadBin}" ) || ( "${newest_settings_file}" -nt "${xmonadBin}" ) ]]
then
	# delete old xmonad output files
	rm -rf "${XMONAD_DIR}/xmonad.hi" "${XMONAD_DIR}/xmonad.o"

	# Build our xmonad config.
	PATH="${XMONAD_LOCAL_BIN_PATH}:${PATH}" stack ghc \
		--resolver "${XMONAD_STACK_RESOLVER}" \
		--install-ghc \
		--package dbus \
		--package gtk-traymanager \
		--package libxml-sax \
		--package taffybar \
		--package xmonad \
		--package xmonad-contrib \
		-- xmonad.hs -o "${xmonadBin}"
fi
