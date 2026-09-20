{
  pkgs,
  ...
}:

{
  programs.mise = {
    enable = true;
    package = pkgs.mise;
    enableFishIntegration = true;

    globalConfig = {
      tools = {
        # Runtime versions (keep for project-specific version management)
        node = "24.11.1";
        zig = "latest";

        # Tools not yet in Nix or need mise management
        "aqua:argoproj/argo-rollouts" = "latest";
        "npm:js-beautify" = "latest";

        # LLM Tools (npm packages, keep in mise)
        "npm:@google/gemini-cli" = "latest";
        # copilot-language-server moved to nixpkgs (see home/common.nix) —
        # mise's npm backend can't install it, see comment there.
        "npm:@zed-industries/claude-code-acp" = "latest";
        "npm:@openai/codex" = "latest";
        "npm:@github/copilot" = "latest";

        # Language Servers not in nixpkgs or need special handling
        "npm:tombi" = "latest";
        "aqua:arduino/arduino-language-server" = "latest";
      };

      settings = {
        experimental = true;
        lockfile = true;
        # Exclude shell-script plugin backends (arbitrary code execution risk).
        disable_backends = [
          "asdf"
          "vfox"
        ];
        idiomatic_version_file_enable_tools = [
          "node"
          "terraform"
        ];
        # Mitigate supply chain attacks by only allowing tool versions
        # released at least 7 days ago.
        minimum_release_age = "7d";

        all_compile = false;

        # Supply chain hardening: enable extra-secure behaviour and signature
        # / attestation verification across backends.
        paranoid = true;
        slsa = true;
        github_attestations = true;
        gpg_verify = true;
        prereleases = false;
      };
    };
  };
}
