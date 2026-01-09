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
        -- Calculate position for centered middle text
        local left_len = #left_text
        local mid_len = #middle_text
        local right_len = right_text and #right_text or 0
        local available_space = width - left_len - mid_len - right_len
        local left_padding = math.max(0, math.floor(available_space / 2))
        io.write(string.rep(" ", left_padding) .. middle_text)
    end
    if right_text then
        -- Calculate remaining space for right text
        local used_len = #left_text
        if middle_text then
            local mid_len = #middle_text
            local left_padding = math.max(0, math.floor((width - #left_text - mid_len - #right_text) / 2))
            used_len = used_len + left_padding + mid_len
        end
        local right_padding = math.max(0, width - used_len - #right_text)
        io.write(string.rep(" ", right_padding) .. right_text)
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
        if i <= heat then
            io.write("█")  -- Filled heat bar (solid block)
        else
            io.write("░")  -- Empty heat bar (25% dithered)
        end
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

-- Widget: Generic table generator
-- Renders a table with headers, separators, and data rows
-- @param columns table - Array of column definitions: {{title="Name", value_fn=function(row), width=11}, ...}
-- @param data table - Array of data rows to display
-- @param options table - Optional settings {title="Table Title", footer_fn=function(), output_fn=function(str)}
function widgets.table_generator(columns, data, options)
    options = options or {}
    local output_fn = options.output_fn or io.write
    
    -- Print optional title
    if options.title then
        output_fn(options.title .. "\n")
    end
    
    -- Build format string (reused for all rows)
    local format_str = ""
    local separator_values = {}
    local header_values = {}
    
    for i, col in ipairs(columns) do
        format_str = format_str .. "%-" .. col.width .. "s"
        if i < #columns then
            format_str = format_str .. " "
        end
        table.insert(separator_values, string.rep("-", col.width))
        table.insert(header_values, col.title)
    end
    format_str = format_str .. "\n"
    
    -- Print table header
    output_fn(string.format(format_str, table.unpack(header_values)))
    
    -- Print column separators
    output_fn(string.format(format_str, table.unpack(separator_values)))
    
    -- Print data rows
    for _, row in ipairs(data) do
        local row_values = {}
        
        for _, col in ipairs(columns) do
            -- Get value from the value function
            local value = col.value_fn(row)
            table.insert(row_values, tostring(value))
        end
        
        output_fn(string.format(format_str, table.unpack(row_values)))
    end
    
    -- Print optional footer
    if options.footer_fn then
        output_fn("\n")
        options.footer_fn()
    end
    
    -- Flush only if using default io.write
    if output_fn == io.write then
        io.flush()
    end
end

return widgets
