-- UI Widgets Module
-- Provides reusable UI components for terminal-based interfaces

local term = require("terminal")
local gamestate = require("game")
local Window = require("ui.window")

local widgets = {}

-- Widget: Separator line
function widgets.separator(row, width)
    width = width or 120
    term.write_at(row, 1, string.rep("=", width), "fg_white")
end

-- Widget: Centered title
function widgets.title(row, text, width)
    width = width or 120
    local padding = math.floor((width - #text) / 2)
    term.write_at(row, padding, text, "fg_bright_red")
end

-- Widget: Status bar
function widgets.status_bar(row, left_text, middle_text, right_text, width)
    width = width or 120
    term.write_at(row, 1, left_text, "fg_cyan")
    if middle_text then
        local mid_pos = math.floor((width - #middle_text) / 2)
        term.write_at(row, mid_pos, middle_text, "fg_yellow")
    end
    if right_text then
        term.write_at(row, width - #right_text, right_text, "fg_bright_yellow")
    end
end

-- Widget: Section header
function widgets.section_header(row, text)
    term.set_style("bold")
    term.write_at(row, 1, "--- " .. text .. " ---", "fg_bright_white")
    term.reset()
end

-- Widget: Labeled value (with color highlighting for value)
function widgets.labeled_value(row, col, label, value, value_color)
    term.write_at(row, col, label, "fg_white")
    local value_col = col + #label
    term.write_at(row, value_col, tostring(value), value_color or "fg_bright_white")
end

-- Widget: Color-coded percentage bar
function widgets.percentage_bar(row, col, label, value, max_value)
    max_value = max_value or 100
    local percent = math.floor((value / max_value) * 100)
    local color
    if percent >= 70 then
        color = "fg_green"
    elseif percent >= 50 then
        color = "fg_yellow"
    else
        color = "fg_red"
    end
    
    term.write_at(row, col, label .. ": ", "fg_white")
    term.write_colored(percent .. "%", color)
end

-- Widget: Heat meter
function widgets.heat_meter(row, game)
    local heat = game.heat
    local max_heat = game.heat_max
    
    term.write_at(row, 3, "[", "fg_white")
    
    for i = 1, max_heat do
        if i <= heat then
            term.write_colored("|", "fg_red")
        else
            term.write_colored("|", "fg_white")
        end
    end
    
    term.write_colored("] " .. heat .. "/" .. max_heat, gamestate.get_heat_color(game))
    term.write_at(row, 25, " - ", "fg_white")
    term.write_at(row, 28, gamestate.get_heat_message(game), heat > 7 and "fg_bright_red" or "fg_white")
end

-- Widget: Menu item (displays a numbered menu option)
function widgets.menu_item(row, col, number, text)
    term.write_at(row, col, tostring(number), "fg_bright_cyan")
    term.write_at(row, col + 1, ". " .. text, "fg_white")
end

-- Utility: Format number with thousands separator
function widgets.format_number(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Convenience function to create and draw a window
function widgets.window(row, col, width, height, title, border_color, bg_color)
    local win = Window.new(row, col, width, height, title, border_color, bg_color)
    win:draw_border()
    return win
end

-- Widget: Information box with title and border (legacy compatibility)
-- Draws a box at specified position with title and returns the row where content should start
function widgets.info_box(row, col, width, height, title, border_color)
    border_color = border_color or "fg_cyan"
    
    -- Draw the box
    term.draw_box(row, col, width, height, border_color, "bg_black")
    
    -- Draw title if provided
    if title then
        term.write_at(row, col + 2, "[ " .. title .. " ]", "fg_bright_white", "bg_black")
    end
    
    -- Return the starting row for content (inside the box)
    return row + 1
end

-- Widget: Stat box - displays a labeled value in a small box
function widgets.stat_box(row, col, width, label, value, value_color, border_color)
    border_color = border_color or "fg_white"
    value_color = value_color or "fg_bright_white"
    
    -- Draw small box (3 rows tall)
    term.draw_box(row, col, width, 3, border_color, "bg_black")
    
    -- Draw label centered on first line (ensure non-negative padding)
    local label_padding = math.max(0, math.floor((width - #label - 2) / 2))
    term.write_at(row + 1, col + 1 + label_padding, label, "fg_white", "bg_black")
    
    -- Draw value centered on second line (ensure non-negative padding)
    local value_str = tostring(value)
    local value_padding = math.max(0, math.floor((width - #value_str - 2) / 2))
    term.write_at(row + 2, col + 1 + value_padding, value_str, value_color, "bg_black")
end

return widgets
