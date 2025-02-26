local wezterm = require ("wezterm")

config = wezterm.config_builder()

config = {
  automatically_reload_config = true,
  window_close_confirmation = "NeverPrompt",
  color_scheme = "Nord (Gogh)",
  font = wezterm.font("JetBrains Mono", {weight = "Bold" }),
  font_size = 18,
  window_frame = {
    font = wezterm.font { family = 'Roboto', weight = 'Bold' },
    font_size = 16,
    active_titlebar_bg = '#333333',
    inactive_titlebar_bg = '#333333',
  },
  keys = {
    -- Map Option + Left to move backward by a word
    {
      key = "LeftArrow",
      mods = "OPT",
      action = wezterm.action.SendString("\x1bb"),
    },
    {
      key = "RightArrow",
      mods = "OPT",
      action = wezterm.action.SendString("\x1bf"),
    },
  }
}

return config
