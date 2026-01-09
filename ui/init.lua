-- UI Widgets Module
-- Provides reusable UI components for text-based interfaces

local gamestate = require("game")

local widgets = {}

-- Widget: Separator line
function widgets.separator(width)
    width = width or 120
    io.write(string.rep("=", width))
    io.flush()
end

-- Widget: Centered title
function widgets.title(text, width)
    width = width or 120
    local padding = math.floor((width - #text) / 2)
    io.write(string.rep(" ", padding) .. text)
    io.flush()
end

-- Widget: Status bar
function widgets.status_bar(left_text, middle_text, right_text, width)
    width = width or 120
    io.write(left_text)
    if middle_text then
        local mid_pos = math.floor((width - #left_text - #middle_text) / 2)
        io.write(string.rep(" ", mid_pos) .. middle_text)
    end
    if right_text then
        -- Add spacing before right text
        io.write(string.rep(" ", width - #left_text - #(middle_text or "") - #right_text) .. right_text)
    end
    io.flush()
end

-- Widget: Section header
function widgets.section_header(text)
    io.write("--- " .. text .. " ---")
    io.flush()
end

-- Widget: Labeled value
function widgets.labeled_value(label, value)
    io.write(label .. tostring(value))
    io.flush()
end

-- Widget: Percentage bar
function widgets.percentage_bar(label, value, max_value)
    max_value = max_value or 100
    local percent = math.floor((value / max_value) * 100)
    io.write(label .. ": " .. percent .. "%")
    io.flush()
end

-- Widget: Heat meter
function widgets.heat_meter(game)
    local heat = game.heat
    local max_heat = game.heat_max
    
    io.write("[")
    
    for i = 1, max_heat do
        io.write("|")
    end
    
    io.write("] " .. heat .. "/" .. max_heat)
    io.write(" - ")
    io.write(gamestate.get_heat_message(game))
    io.flush()
end

-- Widget: Menu item
function widgets.menu_item(number, text)
    io.write(tostring(number) .. ". " .. text)
    io.flush()
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
