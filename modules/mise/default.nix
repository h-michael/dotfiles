{
  pkgs,
  ...
}:

{
  programs.mise = {
    enable = true;
    package = pkgs.unstable.mise;
    enableFishIntegration = false;

    globalConfig = {
      tools = {
        # Runtime versions (keep for project-specific version management)
        node = "24.22.1";
        zig = "latest";

        # Tools not yet in Nix or need mise management
        "aqua:argoproj/argo-rollouts" = "latest";
        "github:backnotprop/plannotator" = "latest";
        # Prebuilt binary; cargo:cargo-nextest would compile from source
        "aqua:nextest-rs/nextest/cargo-nextest" = "latest";
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
        # released at least 3 days ago. npm lets authors unpublish within
        # 72 hours, so a broken or compromised release is usually gone by
        # then.
        minimum_release_age = "3d";

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
