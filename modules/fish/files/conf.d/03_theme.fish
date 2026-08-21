# TokyoNight Color Theme for Fish
# From: https://github.com/folke/tokyonight.nvim (MIT License)
#
# fish 4.3 stopped persisting fish_color_* in universal scope, so the
# previous `fish_config theme save` workflow no longer survives restarts.
# Set them globally here instead of relying on universal variables.

# Syntax Highlighting Colors
set -g fish_color_normal c0caf5
set -g fish_color_command 7dcfff
set -g fish_color_keyword bb9af7
set -g fish_color_quote e0af68
set -g fish_color_redirection c0caf5
set -g fish_color_end ff9e64
set -g fish_color_option bb9af7
set -g fish_color_error f7768e
set -g fish_color_param 9d7cd8
set -g fish_color_comment 565f89
set -g fish_color_selection --background=283457
set -g fish_color_search_match --background=283457
set -g fish_color_operator 9ece6a
set -g fish_color_escape bb9af7
set -g fish_color_autosuggestion 565f89

# Completion Pager Colors
set -g fish_pager_color_progress 565f89
set -g fish_pager_color_prefix 7dcfff
set -g fish_pager_color_completion c0caf5
set -g fish_pager_color_description 565f89
set -g fish_pager_color_selected_background --background=283457
