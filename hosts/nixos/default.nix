{
  config,
  lib,
  pkgs,
  username,
  unstablePkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use systemd-boot
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 30;
    editor = true;
    consoleMode = "keep";
    # Dual-boot with Arch Linux
    # "zz-" prefix ensures Arch entry sorts after NixOS entries alphabetically
    extraEntries = {
      "zz-arch.conf" = ''
        title Arch Linux
        linux /vmlinuz-linux
        initrd /amd-ucode.img
        initrd /initramfs-linux.img
        options rd.luks.name=47d5b5a8-226d-4574-bcda-0fc32efbdf59=luks-linux rd.lvm.vg=vg_linux root=/dev/mapper/vg_linux-arch rootflags=subvol=@ rw rd.break
      '';
    };
  };

  boot.initrd = {
    kernelModules = [ "amdgpu" ];
    services.lvm.enable = true;
    # Enable systemd in initrd for TPM2 LUKS unlock
    systemd.enable = true;
    # LUKS encryption with TPM2 auto-unlock
    luks.devices.cryptlvm = {
      device = "/dev/disk/by-uuid/47d5b5a8-226d-4574-bcda-0fc32efbdf59";
      preLVM = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };

  # Workaround: Disable ASPM (Active State Power Management) for MediaTek MT7925
  #
  # ASPM can cause Bluetooth connection instability and firmware communication
  # timeouts on MT7925 Wi-Fi/Bluetooth combo chips.
  #
  # References:
  #   - https://bbs.archlinux.org/viewtopic.php?id=306366
  #   - https://forums.linuxmint.com/viewtopic.php?t=455342
  boot.kernelParams = [
    "mt7925e.disable_aspm=1"
    # Disable USB autosuspend to fix MT7925 Bluetooth connection issues
    # Workaround for br-connection-create-socket error until kernel 6.17+
    # Reference: https://forums.linuxmint.com/viewtopic.php?t=455342
    "usbcore.autosuspend=-1"
    # AMD P-State driver for better CPU power management
    # Reference: https://wiki.archlinux.org/title/CPU_frequency_scaling#amd_pstate
    "amd_pstate=active"
  ];

  # Apple Magic Keyboard: F1-F12 as default function keys
  # fnmode: 0 = disabled, 1 = Fn key pressed = F1-F12, 2 = Fn key pressed = media keys
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  nixpkgs.config.allowUnfree = true;

  # Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Time zone and locale
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Bluetooth (with MT7925 workarounds)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
  services.blueman.enable = true;

  # Workaround: MediaTek MT7925 Bluetooth is soft-blocked on boot with kernel 6.12+
  #
  # Symptoms:
  #   - `rfkill list` shows "Soft blocked: yes" for Bluetooth
  #   - `bluetoothctl show` returns "No default controller available"
  #   - journalctl shows "Bluetooth: hci0: Execution of wmt command timed out"
  #
  # This service runs `rfkill unblock bluetooth` before bluetooth.service starts.
  #
  # References:
  #   - https://discourse.nixos.org/t/bluetooth-is-soft-blocked-on-startup-6-12/60222
  #   - https://bbs.archlinux.org/viewtopic.php?id=310216
  #   - https://github.com/ublue-os/bazzite/issues/3337
  systemd.services.bluetooth-rfkill-unblock = {
    description = "Unblock Bluetooth via rfkill";
    wantedBy = [ "bluetooth.service" ];
    before = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
    };
  };

  # Keyboard
  services.xserver.xkb.layout = "us";

  # xremap needs uinput access
  hardware.uinput.enable = true;

  # Hyprland
  programs.hyprland.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Steam Remote Play
    dedicatedServer.openFirewall = true; # Steam dedicated server
    # Proton for Windows games
    extraCompatPackages = with pkgs; [
      proton-ge-bin # GloriousEggroll's custom Proton (better compatibility)
    ];
  };
  programs.gamemode.enable = true; # Performance optimization for games

  # XDG Desktop Portal for screen sharing in Discord/Slack
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland # Screen sharing for Hyprland
      xdg-desktop-portal-gtk # File dialogs
    ];
  };

  # greetd login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
  };

  # Tailscale VPN
  services.tailscale.enable = true;

  # Ollama - Local LLM runtime with AMD ROCm GPU acceleration
  services.ollama = {
    enable = true;
    package = unstablePkgs.ollama; # Use latest from nixpkgs-unstable
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

  # Navidrome music streaming server
  # Access: Tailscale only (http://<Tailscale-IP>:4533)
  services.navidrome = {
    enable = true;
    openFirewall = false; # Block access from LAN
    settings = {
      Address = "0.0.0.0"; # Tailscale
      Port = 4533;
      MusicFolder = "/mnt/shared/Media/Music";
      ScanSchedule = "@every 1h";
      EnableTranscodingConfig = true;
      DefaultTheme = "Dark";
    };
  };

  # Prometheus - Metrics collection and storage
  # Access: Tailscale only (http://<Tailscale-IP>:9090)
  services.prometheus = {
    enable = true;
    port = 9090;
    retentionTime = "30d"; # 1 month retention

    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "systemd"
          "processes"
          "textfile"
        ];
        extraFlags = [
          "--collector.textfile.directory=/var/lib/prometheus-node-exporter"
        ];
      };
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:9100" ];
          }
        ];
      }
      {
        job_name = "process";
        static_configs = [
          {
            targets = [ "localhost:9256" ];
          }
        ];
      }
    ];
  };

  # Process exporter - Per-process CPU/memory monitoring
  services.prometheus.exporters.process = {
    enable = true;
    port = 9256;
    settings.process_names = [
      # Ollama LLM
      {
        name = "{{.Comm}}";
        comm = [ "ollama" ];
      }
      # Grafana
      {
        name = "{{.Comm}}";
        comm = [ "grafana" ];
      }
      # Prometheus
      {
        name = "{{.Comm}}";
        comm = [ "prometheus" ];
      }
      # Navidrome
      {
        name = "{{.Comm}}";
        comm = [ "navidrome" ];
      }
      # Open WebUI
      {
        name = "open-webui";
        cmdline = [ ".*open-webui.*" ];
      }
      # Node exporter
      {
        name = "{{.Comm}}";
        comm = [ "node_exporter" ];
      }
      # systemd services (not monitoring PID 1 - includes all child processes)
      {
        name = "{{.Comm}}";
        comm = [
          "systemd-journal"
          "systemd-udevd"
          "systemd-logind"
          "systemd-oomd"
        ];
      }
      # Network
      {
        name = "{{.Comm}}";
        comm = [ "NetworkManager" ];
      }
      # Desktop
      {
        name = "{{.Comm}}";
        comm = [
          "Hyprland"
          "waybar"
          "pipewire"
        ];
      }
    ];
  };

  # Grafana - Metrics visualization dashboard
  # Access: Tailscale only (http://<Tailscale-IP>:3081)
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0"; # Listen on all interfaces for Tailscale
        http_port = 3081;
      };
      analytics.reporting_enabled = false;
    };
    provision = {
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:9090";
          isDefault = true;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "NixOS";
          options.path = "/etc/grafana/dashboards";
        }
      ];
    };
  };

  # Grafana dashboard for system and GPU monitoring
  environment.etc."grafana/dashboards/system-overview.json" = {
    text = builtins.toJSON {
      annotations.list = [ ];
      editable = true;
      fiscalYearStartMonth = 0;
      graphTooltip = 0;
      links = [ ];
      panels = [
        # ===== Section 1: CPU/Memory Usage =====
        # Row: System Overview
        {
          type = "row";
          title = "System Overview";
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 0;
          };
          collapsed = false;
        }
        # CPU Usage Gauge
        {
          type = "gauge";
          title = "CPU Usage";
          gridPos = {
            h = 6;
            w = 6;
            x = 0;
            y = 1;
          };
          fieldConfig = {
            defaults = {
              color.mode = "thresholds";
              max = 100;
              min = 0;
              thresholds.mode = "absolute";
              thresholds.steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 60;
                }
                {
                  color = "red";
                  value = 80;
                }
              ];
              unit = "percent";
            };
          };
          options = {
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showThresholdLabels = false;
            showThresholdMarkers = true;
          };
          targets = [
            {
              expr = "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)";
              refId = "A";
            }
          ];
        }
        # Memory Usage
        {
          type = "gauge";
          title = "Memory Usage";
          gridPos = {
            h = 6;
            w = 6;
            x = 6;
            y = 1;
          };
          fieldConfig = {
            defaults = {
              color.mode = "thresholds";
              max = 100;
              min = 0;
              thresholds.mode = "absolute";
              thresholds.steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 60;
                }
                {
                  color = "red";
                  value = 80;
                }
              ];
              unit = "percent";
            };
          };
          options = {
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showThresholdLabels = false;
            showThresholdMarkers = true;
          };
          targets = [
            {
              expr = "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100";
              refId = "A";
            }
          ];
        }
        # Disk Usage (NixOS root)
        {
          type = "gauge";
          title = "Disk (/)";
          gridPos = {
            h = 6;
            w = 3;
            x = 12;
            y = 1;
          };
          fieldConfig = {
            defaults = {
              color.mode = "thresholds";
              max = 100;
              min = 0;
              thresholds.mode = "absolute";
              thresholds.steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 70;
                }
                {
                  color = "red";
                  value = 85;
                }
              ];
              unit = "percent";
            };
          };
          options = {
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showThresholdLabels = false;
            showThresholdMarkers = true;
          };
          targets = [
            {
              expr = "100 - ((node_filesystem_avail_bytes{mountpoint=\"/\"} / node_filesystem_size_bytes{mountpoint=\"/\"}) * 100)";
              refId = "A";
            }
          ];
        }
        # Disk Usage (shared volume)
        {
          type = "gauge";
          title = "Disk (shared)";
          gridPos = {
            h = 6;
            w = 3;
            x = 15;
            y = 1;
          };
          fieldConfig = {
            defaults = {
              color.mode = "thresholds";
              max = 100;
              min = 0;
              thresholds.mode = "absolute";
              thresholds.steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 70;
                }
                {
                  color = "red";
                  value = 85;
                }
              ];
              unit = "percent";
            };
          };
          options = {
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showThresholdLabels = false;
            showThresholdMarkers = true;
          };
          targets = [
            {
              expr = "100 - ((node_filesystem_avail_bytes{mountpoint=\"/mnt/shared\"} / node_filesystem_size_bytes{mountpoint=\"/mnt/shared\"}) * 100)";
              refId = "A";
            }
          ];
        }
        # CPU Temperature
        {
          type = "gauge";
          title = "CPU Temperature";
          gridPos = {
            h = 6;
            w = 6;
            x = 18;
            y = 1;
          };
          fieldConfig = {
            defaults = {
              color.mode = "thresholds";
              max = 100;
              min = 0;
              thresholds.mode = "absolute";
              thresholds.steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 60;
                }
                {
                  color = "orange";
                  value = 75;
                }
                {
                  color = "red";
                  value = 85;
                }
              ];
              unit = "celsius";
            };
          };
          options = {
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showThresholdLabels = false;
            showThresholdMarkers = true;
          };
          targets = [
            {
              expr = "node_hwmon_temp_celsius{chip=~\".*k10temp.*|pci0000:00_0000:00:18_3\",sensor=\"temp1\"}";
              refId = "A";
            }
          ];
        }
        # CPU Usage History
        {
          type = "timeseries";
          title = "CPU Usage History";
          gridPos = {
            h = 8;
            w = 8;
            x = 0;
            y = 7;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              max = 100;
              min = 0;
              unit = "percent";
            };
          };
          options = {
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              expr = "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)";
              legendFormat = "CPU";
              refId = "A";
            }
          ];
        }
        # Memory Usage History
        {
          type = "timeseries";
          title = "Memory Usage History";
          gridPos = {
            h = 8;
            w = 8;
            x = 8;
            y = 7;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              unit = "bytes";
            };
          };
          options = {
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              expr = "node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes";
              legendFormat = "Used";
              refId = "A";
            }
            {
              expr = "node_memory_MemAvailable_bytes";
              legendFormat = "Available";
              refId = "B";
            }
          ];
        }
        # CPU Temperature History
        {
          type = "timeseries";
          title = "CPU Temperature History";
          gridPos = {
            h = 8;
            w = 8;
            x = 16;
            y = 7;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              unit = "celsius";
            };
          };
          options = {
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              expr = "node_hwmon_temp_celsius{chip=~\".*k10temp.*|pci0000:00_0000:00:18_3\",sensor=\"temp1\"}";
              legendFormat = "CPU Temp";
              refId = "A";
            }
          ];
        }
        # ===== Section 2: Process Metrics =====
        # Row: Processes
        {
          type = "row";
          title = "Process Metrics";
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 15;
          };
          collapsed = false;
        }
        # Process CPU Usage
        {
          type = "timeseries";
          title = "Process CPU Usage";
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 16;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              unit = "percentunit";
            };
          };
          options = {
            legend = {
              calcs = [ "last" ];
              displayMode = "table";
              placement = "right";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              expr = "sum by (groupname) (rate(namedprocess_namegroup_cpu_seconds_total{mode!=\"idle\"}[5m]))";
              legendFormat = "{{groupname}}";
              refId = "A";
            }
          ];
        }
        # Process Memory Usage
        {
          type = "timeseries";
          title = "Process Memory Usage";
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 16;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              unit = "bytes";
            };
          };
          options = {
            legend = {
              calcs = [ "last" ];
              displayMode = "table";
              placement = "right";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              expr = "namedprocess_namegroup_memory_bytes{memtype=\"resident\"}";
              legendFormat = "{{groupname}}";
              refId = "A";
            }
          ];
        }
        # ===== Section 3: GPU =====
        # Row: AMD GPU
        {
          type = "row";
          title = "AMD GPU (Strix Halo)";
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 24;
          };
          collapsed = false;
        }
        # GPU Temperature Gauge
        {
          type = "gauge";
          title = "GPU Temperature";
          gridPos = {
            h = 6;
            w = 6;
            x = 12;
            y = 25;
          };
          fieldConfig = {
            defaults = {
              color.mode = "thresholds";
              max = 100;
              min = 0;
              thresholds.mode = "absolute";
              thresholds.steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 60;
                }
                {
                  color = "orange";
                  value = 75;
                }
                {
                  color = "red";
                  value = 85;
                }
              ];
              unit = "celsius";
            };
          };
          options = {
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showThresholdLabels = false;
            showThresholdMarkers = true;
          };
          targets = [
            {
              expr = "amdgpu_temperature_celsius";
              refId = "A";
            }
          ];
        }
        # GPU Usage Gauge
        {
          type = "gauge";
          title = "GPU Usage";
          gridPos = {
            h = 6;
            w = 6;
            x = 0;
            y = 25;
          };
          fieldConfig = {
            defaults = {
              color.mode = "thresholds";
              max = 100;
              min = 0;
              thresholds.mode = "absolute";
              thresholds.steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 60;
                }
                {
                  color = "red";
                  value = 80;
                }
              ];
              unit = "percent";
            };
          };
          options = {
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showThresholdLabels = false;
            showThresholdMarkers = true;
          };
          targets = [
            {
              expr = "amdgpu_gpu_usage_percent";
              refId = "A";
            }
          ];
        }
        # VRAM Usage Gauge
        {
          type = "gauge";
          title = "VRAM Usage";
          gridPos = {
            h = 6;
            w = 6;
            x = 6;
            y = 25;
          };
          fieldConfig = {
            defaults = {
              color.mode = "thresholds";
              max = 100;
              min = 0;
              thresholds.mode = "absolute";
              thresholds.steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 60;
                }
                {
                  color = "red";
                  value = 80;
                }
              ];
              unit = "percent";
            };
          };
          options = {
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            showThresholdLabels = false;
            showThresholdMarkers = true;
          };
          targets = [
            {
              expr = "(amdgpu_vram_used_bytes / amdgpu_vram_total_bytes) * 100";
              refId = "A";
            }
          ];
        }
        # GPU Power Stat
        {
          type = "stat";
          title = "GPU Power";
          gridPos = {
            h = 6;
            w = 6;
            x = 18;
            y = 25;
          };
          fieldConfig = {
            defaults = {
              color.mode = "thresholds";
              thresholds.mode = "absolute";
              thresholds.steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 50;
                }
                {
                  color = "red";
                  value = 100;
                }
              ];
              unit = "watt";
            };
          };
          options = {
            reduceOptions = {
              calcs = [ "lastNotNull" ];
              fields = "";
              values = false;
            };
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            textMode = "auto";
          };
          targets = [
            {
              expr = "amdgpu_power_watts";
              refId = "A";
            }
          ];
        }
        # GPU Temperature History
        {
          type = "timeseries";
          title = "GPU Temperature History";
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 31;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              unit = "celsius";
            };
          };
          options = {
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              expr = "amdgpu_temperature_celsius";
              legendFormat = "Temperature";
              refId = "A";
            }
          ];
        }
        # GPU Usage History
        {
          type = "timeseries";
          title = "GPU Usage History";
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 31;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              max = 100;
              min = 0;
              unit = "percent";
            };
          };
          options = {
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              expr = "amdgpu_gpu_usage_percent";
              legendFormat = "GPU Usage";
              refId = "A";
            }
          ];
        }
        # VRAM Usage History
        {
          type = "timeseries";
          title = "VRAM Usage History";
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 39;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              unit = "bytes";
            };
          };
          options = {
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              expr = "amdgpu_vram_used_bytes";
              legendFormat = "Used";
              refId = "A";
            }
            {
              expr = "amdgpu_vram_total_bytes - amdgpu_vram_used_bytes";
              legendFormat = "Free";
              refId = "B";
            }
          ];
        }
        # GPU Power History
        {
          type = "timeseries";
          title = "GPU Power History";
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 39;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              unit = "watt";
            };
          };
          options = {
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              expr = "amdgpu_power_watts";
              legendFormat = "Power";
              refId = "A";
            }
          ];
        }
        # ===== Section 4: Network =====
        # Network Traffic
        {
          type = "timeseries";
          title = "Network Traffic";
          gridPos = {
            h = 8;
            w = 24;
            x = 0;
            y = 47;
          };
          fieldConfig = {
            defaults = {
              color.mode = "palette-classic";
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisLabel = "";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 10;
                gradientMode = "none";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "linear";
                lineWidth = 1;
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking.group = "A";
                stacking.mode = "none";
                thresholdsStyle.mode = "off";
              };
              unit = "Bps";
            };
          };
          options = {
            legend = {
              calcs = [ ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              maxHeight = 600;
              mode = "single";
              sort = "none";
            };
          };
          targets = [
            {
              expr = "rate(node_network_receive_bytes_total{device!~\"lo|veth.*|docker.*|br-.*\"}[5m])";
              legendFormat = "Receive {{device}}";
              refId = "A";
            }
            {
              expr = "rate(node_network_transmit_bytes_total{device!~\"lo|veth.*|docker.*|br-.*\"}[5m])";
              legendFormat = "Transmit {{device}}";
              refId = "B";
            }
          ];
        }
      ];
      refresh = "10s";
      schemaVersion = 39;
      tags = [
        "system"
        "gpu"
      ];
      templating.list = [ ];
      time = {
        from = "now-1h";
        to = "now";
      };
      timepicker = { };
      timezone = "browser";
      title = "System Overview";
      uid = "nixos-system-overview";
      version = 1;
    };
  };

  # AMD GPU metrics exporter script
  environment.etc."prometheus/amdgpu-metrics.sh" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      OUTPUT_FILE="/var/lib/prometheus-node-exporter/amdgpu.prom"

      # Get GPU metrics using rocm-smi
      TEMP=$(${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showtemp --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.card0."Temperature (Sensor edge) (C)" // "0"')
      GPU_USE=$(${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showuse --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.card0."GPU use (%)" // "0"')
      VRAM_USED=$(${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showmeminfo vram --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.card0."VRAM Total Used Memory (B)" // "0"')
      VRAM_TOTAL=$(${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showmeminfo vram --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.card0."VRAM Total Memory (B)" // "0"')
      POWER=$(${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi --showpower --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.card0."Current Socket Graphics Package Power (W)" // "0"')

      cat > "$OUTPUT_FILE" << EOF
      # HELP amdgpu_temperature_celsius GPU temperature in celsius
      # TYPE amdgpu_temperature_celsius gauge
      amdgpu_temperature_celsius $TEMP
      # HELP amdgpu_gpu_usage_percent GPU usage percentage
      # TYPE amdgpu_gpu_usage_percent gauge
      amdgpu_gpu_usage_percent $GPU_USE
      # HELP amdgpu_vram_used_bytes VRAM used in bytes
      # TYPE amdgpu_vram_used_bytes gauge
      amdgpu_vram_used_bytes $VRAM_USED
      # HELP amdgpu_vram_total_bytes VRAM total in bytes
      # TYPE amdgpu_vram_total_bytes gauge
      amdgpu_vram_total_bytes $VRAM_TOTAL
      # HELP amdgpu_power_watts GPU power consumption in watts
      # TYPE amdgpu_power_watts gauge
      amdgpu_power_watts $POWER
      EOF
    '';
  };

  # Systemd service to export AMD GPU metrics
  systemd.services.amdgpu-metrics = {
    description = "Export AMD GPU metrics for Prometheus";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/prometheus/amdgpu-metrics.sh";
    };
  };

  # Timer to run AMD GPU metrics exporter every 15 seconds
  systemd.timers.amdgpu-metrics = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "15s";
    };
  };

  # Security / PAM
  security.pam.services = {
    hyprlock = { };
  };

  security.rtkit.enable = true;

  # TPM2 support for LUKS automatic unlock
  #
  # Allows automatic LUKS decryption using TPM2 chip, eliminating the need
  # for password input at boot (useful when Bluetooth keyboard is unavailable).
  #
  # After `make switch`, run:
  #   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-uuid/<uuid>
  #
  # References:
  #   - https://jnsgr.uk/2024/04/nixos-secure-boot-tpm-fde/
  #   - https://discourse.nixos.org/t/tpm2-luks-unlock-not-working/52342
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Temp cleanup
  boot.tmp.cleanOnBoot = true;

  # AMD GPU (Strix Halo / RDNA 3.5)
  # Reference: https://wiki.nixos.org/wiki/AMD_GPU
  hardware.graphics = {
    enable = true;
    # 32-bit application support (Steam, Wine, etc.)
    enable32Bit = true;
    # OpenCL support via ROCm
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  # HIP support for AMD GPU (many applications hardcode /opt/rocm/hip path)
  # Also create directory for Prometheus textfile collector
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    "d /var/lib/prometheus-node-exporter 0755 root root -"
  ];

  # Shell configuration
  programs.fish.enable = true;

  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    group = username;
    extraGroups = [
      "wheel"
      "input"
      "uinput"
      "video" # Webcam access for Discord/Slack video calls
      "audio" # Audio device access
      "optical" # CD/DVD drive access
      "cdrom" # CD/DVD drive access
    ];
    shell = pkgs.fish;
  };

  users.groups.${username} = { };

  # Allow passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    # Core (used with sudo)
    curl
    wget
    git
    openssh
    htop
    tmux
    vim
    neovim

    # Utils
    unzip
    zip
    tree
    ripgrep
    fd
    fzf
    bat
    eza
    delta
    usbutils
    pciutils
    tpm2-tools
    nixfmt-tree # Recursive nix formatter

    # Hyprland system dependencies (need hardware access or system integration)
    dunst
    brightnessctl
    playerctl
    networkmanagerapplet # nm-applet
    blueman
    udiskie
    hyprlock
    hypridle

    # GPU stuff
    vulkan-tools
    mesa

    # AMD GPU monitoring
    amdgpu_top # TUI for AMDGPU usage (like nvidia-smi)
    radeontop # Classic AMD GPU monitor
    rocmPackages.rocm-smi # ROCm System Management Interface
    rocmPackages.rocminfo # GFX version info (rocminfo | grep gfx)
    clinfo # OpenCL info

    # Webcam
    v4l-utils # Webcam tools (v4l2-ctl)
  ];

  # Fonts (must use fonts.packages, not environment.systemPackages)
  fonts.packages = with pkgs; [
    cica-font
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    liberation_ttf
    nerd-fonts.symbols-only # For waybar icons
    font-awesome_6 # For waybar icons
  ];

  system.stateVersion = "24.11";
}
