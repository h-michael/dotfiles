# Paseo: daemon orchestrating coding agents (Claude Code, Codex, agy, ...)
# Managed as a system service via the upstream flake's NixOS module.
# ~/.paseo/config.json (daemon password hash, relay settings) stays
# CLI-managed: services.paseo.settings is intentionally left empty so the
# module never overwrites it.
{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:

{
  imports = [
    inputs.paseo.nixosModules.default
  ];

  services.paseo = {
    enable = true;
    # The pinned nixpkgs (nixos-26.05) has no paseo package yet; use the
    # upstream flake's own build.
    package = inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system}.paseo;
    # Run as the real user so agents inherit his environment and agy can
    # reach his KWallet credentials. dataDir then defaults to ~/.paseo,
    # keeping the existing daemon identity (keypair, serverId, pairing).
    user = username;
    group = username;
    # Listen on all interfaces (same pattern as llm.nix / monitoring.nix);
    # exposure is controlled by the firewall below, which opens the port
    # on the Tailscale interface only.
    listenAddress = "0.0.0.0";
    openFirewall = false;
    environment =
      let
        uid = toString config.users.users.${username}.uid;
      in
      {
        # The system service has no login session; point the daemon's
        # children (agy) at the user's session bus so KWallet's Secret
        # Service stays reachable. The wallet itself unlocks at desktop login.
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${uid}/bus";
        XDG_RUNTIME_DIR = "/run/user/${uid}";
      };
  };

  # Daemon PATH: the module's profile-only PATH misses mise-managed CLIs
  # (codex, copilot, ... in ~/.local/share/mise/shims) and ~/.local/bin
  # (claude). Priorities do not survive the module's cfg.environment
  # merge, so override the unit's PATH directly. Order follows the
  # interactive shells: user dirs first, and /run/wrappers/bin (setuid
  # wrappers such as sudo) before /run/current-system/sw/bin.
  systemd.services.paseo.environment.PATH = lib.mkOverride 40 (
    lib.concatStringsSep ":" [
      "/home/${username}/.local/share/mise/shims"
      "/home/${username}/.local/bin"
      "/home/${username}/.nix-profile/bin"
      "/home/${username}/.local/state/nix/profile/bin"
      "/etc/profiles/per-user/${username}/bin"
      "/run/wrappers/bin"
      "/run/current-system/sw/bin"
      "/nix/var/nix/profiles/default/bin"
    ]
  );

  # Direct connections: Tailscale interface only.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    config.services.paseo.port
  ];
}
