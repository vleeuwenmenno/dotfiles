-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font = wezterm.font("MesloLGS NF")

config.keys = {
    -- Ctrl+K for to clear the terminal
    {
        key = 'k', 
        mods = 'CTRL', 
        action = wezterm.action{ClearScrollback = "ScrollbackAndViewport"}
    },
    -- Ctrl+T for new tab
    {
        key = 't',
        mods = 'CTRL',
        action = wezterm.action{SpawnTab="CurrentPaneDomain"}
    },
    -- Ctrl+W for close tab
    {
        key = 'w',
        mods = 'CTRL',
        action = wezterm.action{CloseCurrentTab={confirm=true}}
    },
    -- Ctrl+s for split horizontal
    {
        key = 's',
        mods = 'CTRL',
        action = wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}
    },
    -- Ctrl+d for split vertical
    {
        key = 'd',
        mods = 'CTRL',
        action = wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}
    },
}

-- Use default titlebar instead of the one provided by wezterm
config.window_frame = {
    inactive_titlebar_bg = '#353535',
    active_titlebar_bg = '#2b2042',
    inactive_titlebar_fg = '#cccccc',
    active_titlebar_fg = '#ffffff',
    inactive_titlebar_border_bottom = '#2b2042',
    active_titlebar_border_bottom = '#2b2042',
    button_fg = '#cccccc',
    button_bg = '#2b2042',
    button_hover_fg = '#ffffff',
    button_hover_bg = '#3b3052',

    font = require('wezterm').font 'Roboto',
    font_size = 12,
}

-- Set the default cursor style to a blinking underscore
config.default_cursor_style = "BlinkingUnderline"
config.initial_rows = 30
config.initial_cols = 120

-- and finally, return the configuration to wezterm
return config
