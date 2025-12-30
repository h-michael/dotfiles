# LLM services: Ollama + Open WebUI
{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}:

{
  # Ollama - Local LLM runtime with AMD ROCm GPU acceleration
  services.ollama = {
    enable = true;
    package = unstablePkgs.ollama-rocm; # ROCm-enabled build from nixpkgs-unstable
    acceleration = "rocm";
    # Strix Halo (gfx1151 = RDNA 3.5) → gfx1100 (RDNA 3) emulation
    # ROCm doesn't officially support gfx1151 yet, so we use gfx1100 kernels
    rocmOverrideGfx = "11.0.0";
    environmentVariables = {
      # Flash Attention: Improves memory efficiency and speeds up long context
      OLLAMA_FLASH_ATTENTION = "1";
      # KV cache quantization: Reduces VRAM footprint (q8_0 = 8-bit quantization)
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
    loadModels = [
      "qwen2.5:32b" # https://ollama.com/library/qwen2.5
      "qwen2.5:72b" # https://ollama.com/library/qwen2.5
      "qwen3:8b" # https://ollama.com/library/qwen3
      "qwen2.5-coder:32b" # https://ollama.com/library/qwen2.5-coder
      "gemma2:27b" # https://ollama.com/library/gemma2
      "llama3.3:70b" # https://ollama.com/library/llama3.3
    ];
  };

  # Increase memory limit for large models (70B+ requires >40GB)
  systemd.services.ollama.serviceConfig.MemoryMax = lib.mkForce "92G";

  # Open WebUI - Web interface for Ollama
  # Access: Tailscale only (http://<Tailscale-IP>:3080)
  services.open-webui = {
    enable = true;
    package = unstablePkgs.open-webui; # Use latest from nixpkgs-unstable
    host = "0.0.0.0"; # Listen on all interfaces including Tailscale
    port = 3080;
    openFirewall = false; # Block LAN access, allow Tailscale only
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      # Web search (uses DuckDuckGo by default, no API key needed)
      ENABLE_RAG_WEB_SEARCH = "True";
      RAG_WEB_SEARCH_ENGINE = "duckduckgo";
    };
  };
}
