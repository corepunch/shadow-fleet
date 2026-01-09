-- Terminal Framework for Shadow Fleet
-- Provides cursor control, color management, and screen manipulation functions

local terminal = {}

-- ANSI Escape Sequences
local ESC = string.char(27)
local CSI = ESC .. "["

-- Color codes for foreground (30-37, 90-97)
terminal.colors = {
    -- Standard colors (foreground)
    fg_black = 30,
    fg_red = 31,
    fg_green = 32,
    fg_yellow = 33,
    fg_blue = 34,
    fg_magenta = 35,
    fg_cyan = 36,
    fg_white = 37,
    
    -- Bright colors (foreground)
    fg_bright_black = 90,
    fg_bright_red = 91,
    fg_bright_green = 92,
    fg_bright_yellow = 93,
    fg_bright_blue = 94,
    fg_bright_magenta = 95,
    fg_bright_cyan = 96,
    fg_bright_white = 97,
    
    -- Standard colors (background)
    bg_black = 40,
    bg_red = 41,
    bg_green = 42,
    bg_yellow = 43,
    bg_blue = 44,
    bg_magenta = 45,
    bg_cyan = 46,
    bg_white = 47,
    
    -- Bright colors (background)
    bg_bright_black = 100,
    bg_bright_red = 101,
    bg_bright_green = 102,
    bg_bright_yellow = 103,
    bg_bright_blue = 104,
    bg_bright_magenta = 105,
    bg_bright_cyan = 106,
    bg_bright_white = 107,
}

-- Text styles
terminal.styles = {
    reset = 0,
    bold = 1,
    dim = 2,
    italic = 3,
    underline = 4,
    blink = 5,
    reverse = 7,
    hidden = 8,
    strikethrough = 9,
}

-- Constants
terminal.MAX_ANSI_CODE = 255  -- Maximum value for a single ANSI color code

-- Current theme ("dark" or "light")
terminal.current_theme = "dark"

-- Theme configurations
terminal.themes = {
    dark = {
        bg = "bg_black",
        fg = "fg_white"
    },
    light = {
        bg = "bg_bright_white",
        fg = "fg_black"
    }
}

-- Set the current theme
function terminal.set_theme(theme_name)
    if terminal.themes[theme_name] then
        terminal.current_theme = theme_name
    else
        error("Unknown theme: " .. tostring(theme_name))
    end
end

-- Get current theme background color
function terminal.get_theme_bg()
    return terminal.themes[terminal.current_theme].bg
end

-- Get current theme foreground color
function terminal.get_theme_fg()
    return terminal.themes[terminal.current_theme].fg
end

-- Clear the entire screen
-- Sets theme background before clearing to ensure consistent background color
function terminal.clear()
    terminal.set_bg(terminal.get_theme_bg())
    io.write(CSI .. "2J")
    io.flush()
end

-- Clear from cursor to end of screen
function terminal.clear_to_bottom()
    io.write(CSI .. "0J")
    io.flush()
end

-- Clear from cursor to start of screen
function terminal.clear_to_top()
    io.write(CSI .. "1J")
    io.flush()
end

-- Clear the current line
function terminal.clear_line()
    io.write(CSI .. "2K")
    io.flush()
end

-- Move cursor to position (row, col) - 1-indexed
function terminal.move_to(row, col)
    io.write(CSI .. row .. ";" .. col .. "H")
    io.flush()
end

-- Move cursor to home position (1, 1)
function terminal.home()
    io.write(CSI .. "H")
    io.flush()
end

-- Move cursor up by n lines
function terminal.move_up(n)
    n = n or 1
    io.write(CSI .. n .. "A")
    io.flush()
end

-- Move cursor down by n lines
function terminal.move_down(n)
    n = n or 1
    io.write(CSI .. n .. "B")
    io.flush()
end

-- Move cursor forward by n columns
function terminal.move_forward(n)
    n = n or 1
    io.write(CSI .. n .. "C")
    io.flush()
end

-- Move cursor backward by n columns
function terminal.move_backward(n)
    n = n or 1
    io.write(CSI .. n .. "D")
    io.flush()
end

-- Save cursor position
function terminal.save_cursor()
    io.write(ESC .. "7")
    io.flush()
end

-- Restore cursor position
function terminal.restore_cursor()
    io.write(ESC .. "8")
    io.flush()
end

-- Hide cursor
function terminal.hide_cursor()
    io.write(CSI .. "?25l")
    io.flush()
end

-- Show cursor
function terminal.show_cursor()
    io.write(CSI .. "?25h")
    io.flush()
end

-- Set foreground color
function terminal.set_fg(color)
    if type(color) == "string" then
        color = terminal.colors[color] or terminal.colors.fg_white
    end
    io.write(CSI .. color .. "m")
    io.flush()
end

-- Set background color
function terminal.set_bg(color)
    if type(color) == "string" then
        color = terminal.colors[color] or terminal.colors.bg_black
    end
    io.write(CSI .. color .. "m")
    io.flush()
end

-- Set both foreground and background colors
function terminal.set_colors(fg, bg)
    if type(fg) == "string" then
        fg = terminal.colors[fg] or terminal.colors.fg_white
    end
    if type(bg) == "string" then
        bg = terminal.colors[bg] or terminal.colors.bg_black
    end
    io.write(CSI .. fg .. ";" .. bg .. "m")
    io.flush()
end

-- Set text style
function terminal.set_style(style)
    if type(style) == "string" then
        style = terminal.styles[style] or terminal.styles.reset
    end
    io.write(CSI .. style .. "m")
    io.flush()
end

-- Reset all colors and styles
-- Explicitly set theme background to avoid terminal default
function terminal.reset()
    io.write(CSI .. "0m")
    terminal.set_bg(terminal.get_theme_bg())
    io.flush()
end

-- Write text at specific position with optional colors
function terminal.write_at(row, col, text, fg, bg)
    terminal.move_to(row, col)
    if fg or bg then
        if fg and bg then
            terminal.set_colors(fg, bg)
        elseif fg then
            terminal.set_fg(fg)
        elseif bg then
            terminal.set_bg(bg)
        end
    end
    io.write(text)
    io.flush()
end

-- Write colored text at current position
-- Accepts either:
--   1. String color names: write_colored(text, "fg_bright_yellow", "bg_black")
--   2. Two integer color codes: write_colored(text, terminal.colors.fg_bright_yellow, terminal.colors.bg_black)
--   3. Single packed integer (fg << 8) | bg: write_colored(text, (terminal.colors.fg_bright_yellow << 8) | terminal.colors.bg_black)
function terminal.write_colored(text, fg, bg)
    -- If fg is an integer and bg is nil, check if it's a packed color code
    if type(fg) == "number" and bg == nil then
        -- If the value is > MAX_ANSI_CODE, it's likely a packed color code (fg << 8) | bg
        if fg > terminal.MAX_ANSI_CODE then
            local packed = fg
            fg = packed >> 8
            bg = packed & 0xFF
        else
            -- Single color code, default bg to theme background
            bg = terminal.colors[terminal.get_theme_bg()]
        end
    else
        -- Default to theme background if not specified
        bg = bg or terminal.get_theme_bg()
    end
    
    if fg or bg then
        if fg and bg then
            terminal.set_colors(fg, bg)
        elseif fg then
            terminal.set_fg(fg)
        elseif bg then
            terminal.set_bg(bg)
        end
    end
    io.write(text)
    -- Restore default colors based on theme
    terminal.set_colors(terminal.colors[terminal.get_theme_fg()], terminal.colors[terminal.get_theme_bg()])
    io.flush()
end

-- Get terminal size (returns width, height)
-- This is a basic implementation, may not work on all systems
function terminal.get_size()
    -- Default fallback values
    local width, height = 80, 24
    
    -- Try to get size using tput (Unix/Linux/Mac)
    local handle = io.popen("tput cols 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        if result and result ~= "" then
            width = tonumber(result) or width
        end
    end
    
    handle = io.popen("tput lines 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        if result and result ~= "" then
            height = tonumber(result) or height
        end
    end
    
    return width, height
end

-- Enable alternate screen buffer (useful for full-screen apps)
function terminal.enable_alt_screen()
    io.write(CSI .. "?1049h")
    io.flush()
end

-- Disable alternate screen buffer (return to normal screen)
function terminal.disable_alt_screen()
    io.write(CSI .. "?1049l")
    io.flush()
end

-- Draw a box at specified position with width and height
function terminal.draw_box(row, col, width, height, fg, bg)
    local horizontal = string.rep("─", width - 2)
    local space = string.rep(" ", width - 2)
    
    -- Top border
    terminal.write_at(row, col, "┌" .. horizontal .. "┐", fg, bg)
    
    -- Sides
    for i = 1, height - 2 do
        terminal.write_at(row + i, col, "│" .. space .. "│", fg, bg)
    end
    
    -- Bottom border
    terminal.write_at(row + height - 1, col, "└" .. horizontal .. "┘", fg, bg)
end

-- Draw a filled box
function terminal.fill_box(row, col, width, height, char, fg, bg)
    char = char or " "
    local line = string.rep(char, width)
    for i = 0, height - 1 do
        terminal.write_at(row + i, col, line, fg, bg)
    end
end

-- Initialize terminal for game mode
function terminal.init(theme)
    -- Set theme if provided (default is "dark")
    if theme then
        terminal.set_theme(theme)
    end
    -- Clear the screen with theme background
    terminal.clear()
    terminal.hide_cursor()
end

-- Cleanup terminal (restore normal mode)
function terminal.cleanup()
    terminal.reset()
    terminal.show_cursor()
    terminal.move_to(1, 1)
    terminal.clear()
end

-- Predefined color schemes for quick access
-- Schemes adapt to the current theme (dark or light)
terminal.schemes = {
    dark = {
        default = {fg = "fg_white", bg = "bg_black"},
        title = {fg = "fg_bright_yellow", bg = "bg_blue"},
        error = {fg = "fg_bright_red", bg = "bg_black"},
        success = {fg = "fg_bright_green", bg = "bg_black"},
        warning = {fg = "fg_bright_yellow", bg = "bg_black"},
        info = {fg = "fg_bright_cyan", bg = "bg_black"},
        highlight = {fg = "fg_black", bg = "bg_white"},
        menu = {fg = "fg_white", bg = "bg_blue"},
        menu_selected = {fg = "fg_yellow", bg = "bg_blue"},
        ocean = {fg = "fg_bright_white", bg = "bg_blue"},
        danger = {fg = "fg_white", bg = "bg_red"},
    },
    light = {
        default = {fg = "fg_black", bg = "bg_bright_white"},
        title = {fg = "fg_blue", bg = "bg_bright_yellow"},
        error = {fg = "fg_red", bg = "bg_bright_white"},
        success = {fg = "fg_green", bg = "bg_bright_white"},
        warning = {fg = "fg_yellow", bg = "bg_bright_white"},
        info = {fg = "fg_cyan", bg = "bg_bright_white"},
        highlight = {fg = "fg_white", bg = "bg_black"},
        menu = {fg = "fg_black", bg = "bg_cyan"},
        menu_selected = {fg = "fg_blue", bg = "bg_bright_yellow"},
        ocean = {fg = "fg_blue", bg = "bg_bright_cyan"},
        danger = {fg = "fg_white", bg = "bg_red"},
    }
}

-- Get a color scheme for the current theme
function terminal.get_scheme(scheme_name)
    local theme_schemes = terminal.schemes[terminal.current_theme]
    return theme_schemes and theme_schemes[scheme_name] or terminal.schemes.dark.default
end

-- Apply a color scheme based on current theme
function terminal.apply_scheme(scheme_name)
    local scheme = terminal.get_scheme(scheme_name)
    if scheme then
        terminal.set_colors(scheme.fg, scheme.bg)
    end
end

return terminal
