-- UI Widgets Module
-- Provides reusable UI components for terminal-based interfaces

local term = require("terminal")
local gamestate = require("game")

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
    
    term.write_at(row, 1, "[", "fg_white")
    
    for i = 1, max_heat do
        if i <= heat then
            term.write_colored("|", "fg_red")
        else
            term.write_colored("|", "fg_white")
        end
    end
    
    term.write_colored("] " .. heat .. "/" .. max_heat, gamestate.get_heat_color(game))
    term.write_at(row, 20, " - ", "fg_white")
    term.write_at(row, 23, gamestate.get_heat_message(game), heat > 7 and "fg_bright_red" or "fg_white")
end

-- Widget: Menu item
function widgets.menu_item(row, number, text)
    term.write_at(row, 1, tostring(number), "fg_bright_cyan")
    term.write_at(row, 2, ". " .. text, "fg_white")
end

-- Widget: Menu item with highlight support (vertical layout)
function widgets.menu_item_highlighted(row, number, text, is_selected)
    local highlight_width = 60  -- Width of highlight background
    
    if is_selected then
        -- Draw highlighted background
        term.write_at(row, 1, "> ", "fg_bright_yellow")
        term.write_at(row, 3, text, "fg_bright_white", "bg_blue")
        -- Fill rest of line with background color for full highlight
        local padding = string.rep(" ", highlight_width - #text)
        term.write_colored(padding, "fg_white", "bg_blue")
        term.reset()
    else
        -- Draw unselected item and clear to end of line
        term.write_at(row, 1, "  ", "fg_white")
        term.write_at(row, 3, text, "fg_white")
        -- Fill rest of line with spaces to clear any previous highlight
        local padding = string.rep(" ", highlight_width - #text)
        term.write_colored(padding, "fg_white", "bg_black")
        term.reset()
    end
end

-- Widget: Horizontal menu items
-- Renders menu items horizontally on a single row with 2-space padding between items
function widgets.horizontal_menu(row, col, actions, selected_index)
    term.move_to(row, col)  -- Position cursor
    
    for i, action in ipairs(actions) do
        if i == selected_index then
            -- Draw highlighted item
            term.write_colored(action, "fg_bright_white", "bg_blue")
        else
            -- Draw unselected item
            term.write_colored(action, "fg_white")
        end
        
        -- Add 2-space padding between items (except after the last item)
        if i < #actions then
            term.write_colored("  ", "fg_white")
        end
    end
    
    term.reset()
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

return widgets
