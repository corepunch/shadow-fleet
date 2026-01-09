--- Menu Module
--- Handles menu generation and rendering for BBS Door style interface
---
--- This module provides functions for generating and rendering menus from
--- keymap definitions, with automatic formatting and sorting.
---
--- @module menu

local command_labels = require("command_labels")

local menu = {}

--- Generate formatted menu items from a keymap
--- @param context_keymap table The keymap for a specific context
--- @return table Array of formatted menu items like "(F) Fleet"
function menu.generate_items(context_keymap)
    local items = {}
    
    -- Collect all hotkey-command pairs
    for hotkey, command_id in pairs(context_keymap) do
        local label = command_labels[command_id]
        if label then
            table.insert(items, {
                hotkey = hotkey,
                label = label,
                formatted = "(" .. hotkey .. ") " .. label
            })
        end
    end
    
    -- Sort by hotkey, with special keys at the end
    table.sort(items, function(a, b)
        if a.hotkey == "B" then return false end
        if b.hotkey == "B" then return true end
        if a.hotkey == "Q" then return false end
        if b.hotkey == "Q" then return true end
        if a.hotkey == "?" then return false end
        if b.hotkey == "?" then return true end
        return a.hotkey < b.hotkey
    end)
    
    -- Extract formatted strings
    local formatted = {}
    for _, item in ipairs(items) do
        table.insert(formatted, item.formatted)
    end
    
    return formatted
end

--- Draw a boxed menu with title and items
--- @param title string Menu title
--- @param formatted_items table Array of formatted menu items
--- @param echo_fn function Output function to use
function menu.draw_boxed(title, formatted_items, echo_fn)
    local max_width = #title
    for _, line_text in ipairs(formatted_items) do
        if #line_text > max_width then
            max_width = #line_text
        end
    end
    
    -- Build output efficiently using table.concat
    local parts = {
        title, "\n",
        string.rep("═", max_width), "\n"
    }
    
    for _, line_text in ipairs(formatted_items) do
        table.insert(parts, line_text)
        table.insert(parts, "\n")
    end
    
    table.insert(parts, "\n")
    table.insert(parts, "Enter command: ")
    
    echo_fn(table.concat(parts))
end

--- Print menu from keymap
--- @param title string Menu title
--- @param context_keymap table The keymap for this context
--- @param echo_fn function Output function to use
function menu.print_from_keymap(title, context_keymap, echo_fn)
    local formatted_items = menu.generate_items(context_keymap)
    menu.draw_boxed(title, formatted_items, echo_fn)
end

return menu
