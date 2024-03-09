-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Font
config.font = wezterm.font_with_fallback({
    'Cica',
    'PlemolJP Console',
  })
config.font_size = 14.0

config.color_scheme = 'Jellybeans'


config.enable_tab_bar = false

-- and finally, return the configuration to wezterm
return config
