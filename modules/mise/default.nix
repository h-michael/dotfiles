{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.mise = {
    enable = true;
    package = unstablePkgs.mise;
    enableFishIntegration = true;

    globalConfig = {
      tools = {
        # Runtime versions (keep for project-specific version management)
        node = "24.11.1";

        # Tools not yet in Nix or need mise management
        "aqua:argoproj/argo-rollouts" = "latest";
        "npm:js-beautify" = "latest";

        # LLM Tools (npm packages, keep in mise)
        "npm:@google/gemini-cli" = "latest";
        "npm:@github/copilot-language-server" = "latest";
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
        disable_backends = [ "asdf" ];
        idiomatic_version_file_enable_tools = [
          "node"
          "terraform"
        ];
      };
    };
  };
}
