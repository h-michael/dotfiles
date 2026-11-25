{
  config,
  pkgs,
  lib,
  ...
}:

let
  nopawSrc = ./nopaw.swift;
  nopawBin = "${config.home.homeDirectory}/.local/bin/nopaw";
  nopawStamp = "${config.xdg.stateHome}/nopaw.src";
in
{
  # Karabiner-Elements configuration (macOS only)
  xdg.configFile."karabiner" = {
    source = ./files;
    recursive = true;
  };

  # Click blocker started by the ctrl+opt+cmd+t rule in karabiner.json.
  # Built with the system swiftc into a fixed path instead of a Nix
  # derivation to avoid the Swift toolchain in the closure and to keep the
  # path (which macOS Accessibility permission may be tied to) stable.
  # Rebuilt only when the source's store path changes.
  home.activation.buildNopaw = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x ${nopawBin} ] || [ "$(cat ${nopawStamp} 2>/dev/null)" != "${nopawSrc}" ]; then
      run mkdir -p "$(dirname ${nopawBin})" "$(dirname ${nopawStamp})"
      run /usr/bin/swiftc -O -o ${nopawBin}.tmp ${nopawSrc}
      run mv -f ${nopawBin}.tmp ${nopawBin}
      if [[ ! -v DRY_RUN ]]; then
        echo "${nopawSrc}" > ${nopawStamp}
      fi
    fi
  '';
}
