# LLM services: Ollama + llama.cpp (router mode) + Open WebUI
{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  # Ollama - Local LLM runtime with AMD ROCm GPU acceleration
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama-rocm; # ROCm-enabled build from nixpkgs-unstable
    environmentVariables = {
      # Flash Attention: Improves memory efficiency and speeds up long context
      OLLAMA_FLASH_ATTENTION = "1";
      # KV cache quantization: Reduces VRAM footprint (q8_0 = 8-bit quantization)
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      # Route rocBLAS GEMM through hipBLASLt (ROCm 7.2 includes tuned gfx1151 kernels)
      ROCBLAS_USE_HIPBLASLT = "1";
      # Limit parallel slots to avoid multiplying KV cache allocations for single-user use
      OLLAMA_NUM_PARALLEL = "2";
      # Allow a main LLM and an embedding model to stay loaded together
      OLLAMA_MAX_LOADED_MODELS = "2";
      # Keep large models loaded longer between interactive turns
      OLLAMA_KEEP_ALIVE = "15m";
    };
    loadModels = [
      "gpt-oss:120b" # https://ollama.com/library/gpt-oss
      "qwen3-embedding:4b" # https://ollama.com/library/qwen3-embedding
    ];
  };

  # Increase memory limit for large models (70B+ requires >40GB)
  systemd.services.ollama.serviceConfig.MemoryMax = lib.mkForce "92G";

  # llama.cpp server in router mode (on-demand multi-model loading, OpenAI-compatible API)
  # Access: Tailscale only (http://<Tailscale-IP>:8080)
  services.llama-cpp = {
    enable = true;
    package = pkgs.unstable.llama-cpp-vulkan;
    host = "0.0.0.0"; # Listen on all interfaces including Tailscale
    port = 8080;
    openFirewall = false; # Block LAN access, allow Tailscale only
    extraFlags = [
      "--models-max"
      "2"
    ];
    modelsPreset = {
      "*" = {
        flash-attn = "on";
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        parallel = "1";
        n-gpu-layers = "999";
        load-mode = "none";
        jinja = "on";
        fit = "on";
      };
      "qwen3.6-35b-a3b" = {
        hf-repo = "unsloth/Qwen3.6-35B-A3B-GGUF";
        hf-file = "Qwen3.6-35B-A3B-UD-Q6_K_XL.gguf";
        ctx-size = "131072";
      };
      "qwen3-coder-next" = {
        hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
        hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
        ctx-size = "131072";
      };
      "qwen3.5-122b-a10b" = {
        hf-repo = "unsloth/Qwen3.5-122B-A10B-GGUF";
        hf-file = "UD-Q4_K_XL/Qwen3.5-122B-A10B-UD-Q4_K_XL-00001-of-00003.gguf";
        ctx-size = "32768";
      };
      "gemma-4-26b-a4b" = {
        hf-repo = "unsloth/gemma-4-26B-A4B-it-GGUF";
        hf-file = "gemma-4-26B-A4B-it-UD-Q6_K_XL.gguf";
        ctx-size = "131072";
      };
      "qwen3.6-35b-a3b-abliterated" = {
        hf-repo = "huihui-ai/Huihui-Qwen3.6-35B-A3B-abliterated-MTP-GGUF";
        hf-file = "Huihui-Qwen3.6-35B-A3B-abliterated-ggml-model-Q6_K.gguf";
        ctx-size = "131072";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/shared/llama-cpp 2775 root render -"
  ];

  systemd.services.llama-cpp.serviceConfig = {
    Environment = lib.mkForce [
      "LLAMA_CACHE=/mnt/shared/llama-cpp"
      "ROCBLAS_USE_HIPBLASLT=1"
    ];
    SupplementaryGroups = [
      "render"
      "video"
    ];
    ReadWritePaths = [ "/mnt/shared/llama-cpp" ];
    # Upstream module sets ProcSubset=pid, which hides /proc/cpuinfo and /proc/meminfo
    # needed by ROCm runtime and llama-server --fit.
    ProcSubset = lib.mkForce "all";
    UMask = "0007";
    MemoryMax = "92G";
  };

  # Open WebUI - Web interface for Ollama and llama-server
  # Access: Tailscale only (http://<Tailscale-IP>:3080)
  services.open-webui = {
    enable = true;
    package = pkgs.unstable.open-webui; # Use latest from nixpkgs-unstable
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
      # Connect to local llama-server router mode (OpenAI-compatible endpoint)
      # Note: Open WebUI persists these into webui.db on first start; existing
      # installations also need Admin UI updates for Connections and Documents.
      OPENAI_API_BASE_URL = "http://127.0.0.1:${toString config.services.llama-cpp.port}/v1";
      OPENAI_API_KEY = "sk-local-no-key";
      RAG_EMBEDDING_ENGINE = "ollama";
      RAG_EMBEDDING_MODEL = "qwen3-embedding:4b";
    };
  };
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    config.services.open-webui.port
    config.services.llama-cpp.port
  ];

  # Provide ROCm llama.cpp CLI tools alongside non-colliding Vulkan wrappers for A/B benchmarking.
  environment.systemPackages = [
    pkgs.unstable.llama-cpp-rocm
    (pkgs.writeShellScriptBin "llama-bench-vulkan" ''
      exec ${pkgs.unstable.llama-cpp-vulkan}/bin/llama-bench "$@"
    '')
    (pkgs.writeShellScriptBin "llama-server-vulkan" ''
      exec ${pkgs.unstable.llama-cpp-vulkan}/bin/llama-server "$@"
    '')
  ];

  home-manager.users.${username}.home.packages = [ pkgs.lmstudio ];
}
