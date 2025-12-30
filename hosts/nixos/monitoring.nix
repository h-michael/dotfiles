# Monitoring stack: Prometheus, Grafana, exporters, AMD GPU metrics
{
  config,
  lib,
  pkgs,
  ...
}:

{
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

  # Create directory for Prometheus textfile collector
  systemd.tmpfiles.rules = [
    "d /var/lib/prometheus-node-exporter 0755 root root -"
  ];
}
