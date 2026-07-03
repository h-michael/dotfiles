final: prev:
{
  # nixpkgs' installPhase copies only the entry ${lang}ServerMain.js and drops
  # the lazily-required webpack chunks that live beside it (e.g.
  # 962.jsonServerMain.js), so each server crashes on startup with
  # "Cannot find module './962.jsonServerMain.js'". Copy the whole dist/node
  # directory so the chunks ship too. Upstream bug on nixos-25.11 and master
  # as of 2026-07 (nixpkgs #531366 / PR #531798).
  vscode-langservers-extracted = prev.vscode-langservers-extracted.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      for language in css html json; do
        serverDir="$language-language-features/server/dist/node"
        cp -a "$serverDir/." "$out/lib/extensions/$serverDir/"
      done
    '';
  });
}
