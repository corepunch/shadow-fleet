--- Configuration Module
--- Centralizes configurable parameters for easy access and testing
---
--- This module provides a single source of truth for configuration values
--- that were previously hardcoded throughout the codebase. This enables:
--- - Easy modification of game parameters
--- - Testing with different configurations
--- - Centralized documentation of game constants
---
--- @module config

local config = {}

--- UI Configuration
config.ui = {
    -- Default width for UI elements (separators, tables, etc.)
    default_width = 120,
    
    -- Column width for ship names in tables
    ship_name_width = 11,
    
    -- Number of decimal places for percentage display
    percentage_decimals = 2,
}

--- Game Configuration
config.game = {
    -- Initial player resources
    initial_rubles = 5000000,
    initial_oil_stock = 0,
    initial_location = "Moscow Safehouse",
    initial_date = "Jan 08, 2026",
    initial_turn = 0,
    
    -- Heat system
    heat_initial = 0,
    heat_max = 10,
    heat_low_threshold = 0,
    heat_medium_threshold = 3,
    heat_high_threshold = 7,
    
    -- Fleet limits
    fleet_max_size = 50,
}

--- Cost Configuration
config.costs = {
    -- Repair cost per hull percentage point
    repair_cost_per_point = 10000,
    
    -- Refuel cost per fuel percentage point
    refuel_cost_per_point = 5000,
}

--- ANSI Color Codes
--- These are used throughout the UI for semantic coloring
config.colors = {
    -- Foreground colors
    fg_black = "\27[30m",
    fg_red = "\27[31m",
    fg_green = "\27[32m",
    fg_yellow = "\27[33m",
    fg_blue = "\27[34m",
    fg_magenta = "\27[35m",
    fg_cyan = "\27[36m",
    fg_white = "\27[37m",
    
    -- Bright foreground colors
    fg_bright_black = "\27[90m",
    fg_bright_red = "\27[91m",
    fg_bright_green = "\27[92m",
    fg_bright_yellow = "\27[93m",
    fg_bright_blue = "\27[94m",
    fg_bright_magenta = "\27[95m",
    fg_bright_cyan = "\27[96m",
    fg_bright_white = "\27[97m",
    
    -- Reset
    reset = "\27[0m",
}

--- Get a configuration value by path
--- @param path string Dot-separated path (e.g., "ui.default_width")
--- @return any The configuration value, or nil if not found
function config.get(path)
    local parts = {}
    for part in path:gmatch("[^.]+") do
        table.insert(parts, part)
    end
    
    local value = config
    for _, part in ipairs(parts) do
        if type(value) ~= "table" then
            return nil
        end
        value = value[part]
    end
    
    return value
end

--- Set a configuration value by path (useful for testing)
--- @param path string Dot-separated path (e.g., "ui.default_width")
--- @param new_value any The new value to set
function config.set(path, new_value)
    local parts = {}
    for part in path:gmatch("[^.]+") do
        table.insert(parts, part)
    end
    
    local table_ref = config
    for i = 1, #parts - 1 do
        local part = parts[i]
        if type(table_ref[part]) ~= "table" then
            table_ref[part] = {}
        end
        table_ref = table_ref[part]
    end
    
    table_ref[parts[#parts]] = new_value
end

return config
