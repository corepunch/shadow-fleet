--- UI Widgets Module
--- Provides reusable UI components for text-based interfaces
---
--- This module contains a collection of widgets for rendering terminal-based
--- UI elements including separators, tables, status bars, and formatted output.
---
--- @module ui

local widgets = {}

--- Widget: Separator line
--- @param width number Optional width (default 120)
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
        local left_len = #left_text
        local mid_len = #middle_text
        local right_len = right_text and #right_text or 0
        local available_space = width - left_len - mid_len - right_len
        local left_padding = math.max(0, math.floor(available_space / 2))
        io.write(string.rep(" ", left_padding) .. middle_text)
    end
    if right_text then
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
    local gamestate = require("game")
    local heat = game.heat
    local max_heat = game.heat_max
    
    local parts = {"["}
    for i = 1, max_heat do
        table.insert(parts, i <= heat and "█" or "░")
    end
    table.insert(parts, "] ")
    table.insert(parts, tostring(heat))
    table.insert(parts, "/")
    table.insert(parts, tostring(max_heat))
    table.insert(parts, " - ")
    table.insert(parts, gamestate.get_heat_message(game))
    
    io.write(table.concat(parts))
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
    while true do
        local new_formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
        formatted = new_formatted
    end
    return formatted
end

-- Utility: Format percentage value (handles both integers and floats)
-- @param value number - The percentage value (0-100)
-- @return string - Formatted percentage string (e.g., "65.00%" or "71.81%")
function widgets.format_percentage(value)
    -- Format with 2 decimal places for consistency
    return string.format("%.2f%%", value)
end

-- Utility: Format ship info string
-- @param ship table - Ship data with name, age, hull, fuel, status
-- @return string - Formatted ship info line
function widgets.format_ship_info(ship)
    return string.format(
        "Age: %dy, Hull: %s, Fuel: %s, Status: %s",
        ship.age,
        widgets.format_percentage(ship.hull),
        widgets.format_percentage(ship.fuel),
        ship.status
    )
end

-- Utility: Format hull and fuel status
-- @param hull number - Hull percentage value
-- @param fuel number - Fuel percentage value
-- @return string - Formatted hull/fuel status string
function widgets.format_hull_fuel(hull, fuel)
    return string.format("Hull: %s  Fuel: %s",
        widgets.format_percentage(hull),
        widgets.format_percentage(fuel)
    )
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
    
    -- Build format string and header data
    local format_parts = {}
    local separator_values = {}
    local header_values = {}
    
    for i, col in ipairs(columns) do
        table.insert(format_parts, "%-" .. col.width .. "s")
        if i < #columns then
            table.insert(format_parts, " ")
        end
        table.insert(separator_values, string.rep("-", col.width))
        table.insert(header_values, col.title)
    end
    
    local format_str = table.concat(format_parts) .. "\n"
    
    -- Print table header and separator
    output_fn(string.format(format_str, table.unpack(header_values)))
    output_fn(string.format(format_str, table.unpack(separator_values)))
    
    -- Print data rows
    for _, row in ipairs(data) do
        local row_values = {}
        for _, col in ipairs(columns) do
            local value = col.value_fn(row)
            table.insert(row_values, value == nil and "-" or tostring(value))
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

-- Widget: Detailed ship information panel (Ports of Call style)
-- Shows comprehensive ship data in a vertical format
-- @param ship table - Ship data
-- @param output_fn function - Output function (default: io.write)
function widgets.ship_detail_panel(ship, output_fn)
    output_fn = output_fn or io.write
    local world = require("game.world")
    
    local lines = {}
    table.insert(lines, string.format("Schiff: %s\n", ship.name))
    table.insert(lines, string.format("vOn: %s\n", world.port_name(ship.origin_id) or "-"))
    table.insert(lines, string.format("mit: %s\n", world.format_cargo(ship.cargo)))
    table.insert(lines, string.format("Zustand: %s\n", widgets.format_percentage(ship.hull)))
    table.insert(lines, string.format("Bunker: %s\n", widgets.format_percentage(ship.fuel)))
    table.insert(lines, string.format("Alter: %dy\n", ship.age))
    table.insert(lines, string.format("Kapazität: %dk bbls\n", ship.capacity or 0))
    
    if ship.destination_id then
        table.insert(lines, string.format("Nach: %s\n", world.port_name(ship.destination_id)))
        table.insert(lines, string.format("ETA: %s\n", world.format_eta(ship.eta) or "-"))
    end
    
    if ship.risk and ship.risk ~= "none" then
        table.insert(lines, string.format("Risiko: %s\n", world.format_risk_with_threats(ship.risk, ship.threats)))
    end
    
    output_fn(table.concat(lines))
    
    -- Flush only if using default io.write
    if output_fn == io.write then
        io.flush()
    end
end

-- Widget: Detailed port information panel (Ports of Call style)
-- Shows comprehensive port data
-- @param port_id string - Port identifier
-- @param output_fn function - Output function (default: io.write)
function widgets.port_detail_panel(port_id, output_fn)
    output_fn = output_fn or io.write
    local world = require("game.world")
    
    local port = world.get_port(port_id)
    if not port then
        output_fn("Port not found\n")
        if output_fn == io.write then
            io.flush()
        end
        return
    end
    
    local lines = {}
    table.insert(lines, string.format("%s\n", port.name))
    table.insert(lines, string.format("Region: %s\n", port.region))
    table.insert(lines, string.format("Typ: %s\n", port.type))
    table.insert(lines, string.format("Ölpreis: $%d/bbl\n", port.oil_price))
    
    -- Get available routes from this port
    local destinations = world.get_destinations(port.id)
    table.insert(lines, string.format("Routen: %d\n", #destinations))
    
    output_fn(table.concat(lines))
    
    -- Flush only if using default io.write
    if output_fn == io.write then
        io.flush()
    end
end

return widgets
