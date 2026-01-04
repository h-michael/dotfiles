{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = "(0, 400)";
        height = "(0, 300)";
        origin = "top-right";
        offset = "(30, 50)";
        scale = 0;
        notification_limit = 20;

        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corner_radius = 5;

        icon_corner_radius = 5;
        indicate_hidden = "yes";
        transparency = 0;
        separator_height = 2;
        padding = 16;
        horizontal_padding = 16;
        text_icon_padding = 0;
        frame_width = 3;
        gap_size = 5;
        separator_color = "frame";
        sort = "yes";

        font = "Noto Sans CJK JP 14, Symbols Nerd Font Mono 14";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";

        enable_recursive_icon_lookup = true;
        icon_theme = "Adwaita";
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 64;

        sticky_history = "yes";
        history_length = 20;

        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst:";
        browser = "${pkgs.xdg-utils}/bin/xdg-open";

        always_run_script = true;

        title = "Dunst";
        class = "Dunst";

        corner_radius = 10;
        ignore_dbusclose = false;

        force_xwayland = false;
        force_xinerama = false;

        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      experimental = {
        per_monitor_dpi = false;
      };

      urgency_low = {
        background = "#1a1a1aee";
        foreground = "#ffffff";
        frame_color = "#595959aa";
        timeout = 5;
      };

      urgency_normal = {
        background = "#1a1a1aee";
        foreground = "#ffffff";
        frame_color = "#33ccffee";
        timeout = 5;
      };

      urgency_critical = {
        background = "#1a1a1aee";
        foreground = "#ffffff";
        frame_color = "#ff5555ee";
        timeout = 0;
      };
    };
  };
}
