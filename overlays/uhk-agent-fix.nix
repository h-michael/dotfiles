final: prev: {
  uhk-agent = prev.uhk-agent.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
            # Wrap the binary to fix permissions in user config before running
            mv "$out/bin/uhk-agent" "$out/bin/.uhk-agent-wrapped"
            cat > "$out/bin/uhk-agent" << WRAPPER
      #!/usr/bin/env bash
      # Fix read-only files copied from Nix store before running UHK Agent
      if [ -d "\$HOME/.config/uhk-agent" ]; then
        chmod -R u+w "\$HOME/.config/uhk-agent" 2>/dev/null || true
      fi
      exec "$out/bin/.uhk-agent-wrapped" "\$@"
      WRAPPER
            chmod +x "$out/bin/uhk-agent"
    '';
  });
}
