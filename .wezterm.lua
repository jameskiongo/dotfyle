local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- config.font = wezterm.font("MesloGS Nerd Font Mono")
--
-- config.color_scheme = "Blazer"
config.color_scheme = "Brogrammer"
config.enable_tab_bar = false

config.window_background_opacity = 0.85
config.macos_window_background_blur = 10
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 50,
	right = 50,
	top = 50,
	bottom = 50,
}
-- config.cursor_style = "BlinkingBlock"

config.font_size = 13.0
return config
