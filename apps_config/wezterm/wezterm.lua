local wezterm = require("wezterm")

config = wezterm.config_builder()
local function is_vim(pane)
	local is_vim_env = pane:get_user_vars().IS_NVIM == "true"
	if is_vim_env == true then
		return true
	end
	-- This gsub is equivalent to POSIX basename(3)
	-- Given "/foo/bar" returns "bar"
	-- Given "c:\\foo\\bar" returns "bar"
	local process_name = string.gsub(pane:get_foreground_process_name(), "(.*[/\\])(.*)", "%2")
	return process_name == "nvim" or process_name == "vim"
end

--- cmd+keys that we want to send to neovim.
local super_vim_keys_map = {
	s = utf8.char(0xAA),
	x = utf8.char(0xAB),
	b = utf8.char(0xAC),
	["."] = utf8.char(0xAD),
	o = utf8.char(0xAF),
}

local function bind_super_key_to_vim(key)
	return {
		key = key,
		mods = "CMD",
		action = wezterm.action_callback(function(win, pane)
			local char = super_vim_keys_map[key]
			if char and is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = char, mods = nil },
				}, pane)
			else
				win:perform_action({
					SendKey = {
						key = key,
						mods = "CMD",
					},
				}, pane)
			end
		end),
	}
end

config = {
	automatically_reload_config = true,
	window_close_confirmation = "NeverPrompt",
	color_scheme = "Nord (Gogh)",
	font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
	font_size = 18,
	window_frame = {
		font = wezterm.font({ family = "Roboto", weight = "Bold" }),
		font_size = 16,
		active_titlebar_bg = "#333333",
		inactive_titlebar_bg = "#333333",
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
		bind_super_key_to_vim("b"),
	},
}

return config
