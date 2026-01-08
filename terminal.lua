-- Terminal framework for text-based UI
-- Provides cursor positioning, color management, and screen clearing

local terminal = {}

-- ANSI escape codes
local ESC = string.char(27)
local CSI = ESC .. "["

-- Clear screen and move cursor to home
function terminal.clear()
    io.write(CSI .. "2J" .. CSI .. "H")
    io.flush()
end

-- Move cursor to specific position (1-indexed, row, col)
function terminal.move_to(row, col)
    io.write(string.format(CSI .. "%d;%dH", row, col))
    io.flush()
end

-- Set foreground color (0-255)
function terminal.fg(color)
    io.write(string.format(CSI .. "38;5;%dm", color))
end

-- Set background color (0-255)
function terminal.bg(color)
    io.write(string.format(CSI .. "48;5;%dm", color))
end

-- Reset all attributes
function terminal.reset()
    io.write(CSI .. "0m")
    io.flush()
end

-- Set bold text
function terminal.bold()
    io.write(CSI .. "1m")
end

-- Set dim text
function terminal.dim()
    io.write(CSI .. "2m")
end

-- Set underline
function terminal.underline()
    io.write(CSI .. "4m")
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

-- Predefined color constants (256-color palette)
terminal.colors = {
    -- Basic 16 colors
    fg_black = 0,
    fg_red = 1,
    fg_green = 2,
    fg_yellow = 3,
    fg_blue = 4,
    fg_magenta = 5,
    fg_cyan = 6,
    fg_white = 7,
    fg_bright_black = 8,
    fg_bright_red = 9,
    fg_bright_green = 10,
    fg_bright_yellow = 11,
    fg_bright_blue = 12,
    fg_bright_magenta = 13,
    fg_bright_cyan = 14,
    fg_bright_white = 15,
    
    -- Background colors
    bg_black = 0,
    bg_red = 1,
    bg_green = 2,
    bg_yellow = 3,
    bg_blue = 4,
    bg_magenta = 5,
    bg_cyan = 6,
    bg_white = 7,
    bg_bright_black = 8,
    bg_bright_red = 9,
    bg_bright_green = 10,
    bg_bright_yellow = 11,
    bg_bright_blue = 12,
    bg_bright_magenta = 13,
    bg_bright_cyan = 14,
    bg_bright_white = 15,
    
    -- Extended colors for game theme
    fg_orange = 208,
    fg_dark_red = 124,
    fg_dark_green = 22,
    fg_dark_blue = 17,
    fg_dark_yellow = 136,
    fg_gray = 240,
    fg_light_gray = 250,
}

-- Write text at current cursor position
function terminal.write(text)
    io.write(text)
    io.flush()
end

-- Write text at specific position
function terminal.write_at(row, col, text)
    terminal.move_to(row, col)
    io.write(text)
    io.flush()
end

-- Write colored text at current position
function terminal.write_colored(text, fg_color, bg_color)
    if fg_color then terminal.fg(fg_color) end
    if bg_color then terminal.bg(bg_color) end
    io.write(text)
    terminal.reset()
    io.flush()
end

-- Get terminal size (returns rows, cols)
function terminal.size()
    -- Try to get terminal size using tput
    local handle = io.popen("tput lines 2>/dev/null")
    local rows = handle:read("*a")
    handle:close()
    
    handle = io.popen("tput cols 2>/dev/null")
    local cols = handle:read("*a")
    handle:close()
    
    rows = tonumber(rows) or 24
    cols = tonumber(cols) or 80
    
    return rows, cols
end

return terminal
