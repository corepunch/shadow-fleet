#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- Main screen dashboard with widget-based UI

local term = require("terminal")
local gamestate = require("game")
local widgets = require("ui")
local input = require("terminal.input")

-- Initialize game state
local game = gamestate.new()

-- Dashboard Sections
local sections = {}

-- Header section
function sections.header(start_row)
    widgets.separator(start_row, 120)
    widgets.title(start_row + 1, "PORTS OF CALL: SHADOW FLEET - TEXT PROTOTYPE", 120)
    widgets.separator(start_row + 2, 120)
    return start_row + 3
end

-- Status line
function sections.status_line(start_row)
    local heat_desc = gamestate.get_heat_description(game)
    term.write_at(start_row, 1, "[", "fg_white")
    term.write_colored("Dark Terminal v0.1", "fg_cyan")
    term.write_colored("] - ", "fg_white")
    term.write_colored("Rogue Operator Mode", "fg_yellow")
    term.write_colored(" | Heat: ", "fg_white")
    term.write_colored(heat_desc, gamestate.get_heat_color(game))
    
    start_row = start_row + 1
    term.write_colored(game.location, "fg_bright_cyan")
    term.write_colored(" - " .. game.date .. " | Rubles: ", "fg_white")
    term.write_colored(widgets.format_number(game.rubles), "fg_bright_yellow")
    term.write_colored(" | Oil Stock: ", "fg_white")
    term.write_colored(game.oil_stock .. "k bbls", "fg_bright_white")
    
    return start_row + 2
end

-- Fleet status section
function sections.fleet_status(start_row)
    widgets.section_header(start_row, "FLEET STATUS")
    local row = start_row + 1
    
    -- Table header
    term.write_at(row, 1, "Name", "fg_white")
    term.write_at(row, 12, "Age", "fg_white")
    term.write_at(row, 17, "Hull", "fg_white")
    term.write_at(row, 23, "Fuel", "fg_white")
    term.write_at(row, 29, "Status", "fg_white")
    term.write_at(row, 40, "Cargo", "fg_white")
    term.write_at(row, 58, "Origin", "fg_white")
    term.write_at(row, 80, "Destination", "fg_white")
    term.write_at(row, 104, "ETA", "fg_white")
    term.write_at(row, 112, "Risk", "fg_white")
    row = row + 1
    
    -- Header separator - ASCII grid drawing
    -- Build the separator line with proper box-drawing characters
    -- Columns: Name(11) | Age(5) | Hull(6) | Fuel(6) | Status(11) | Cargo(18) | Origin(22) | Destination(24) | ETA(8) | Risk(...)
    local separator = "├" .. string.rep("─", 10) .. "┼" .. string.rep("─", 4) .. "┼" .. string.rep("─", 5) .. "┼" .. string.rep("─", 5) .. "┼" .. string.rep("─", 10) .. "┼" .. string.rep("─", 17) .. "┼" .. string.rep("─", 21) .. "┼" .. string.rep("─", 23) .. "┼" .. string.rep("─", 7) .. "┼" .. string.rep("─", 7) .. "┤"
    term.write_at(row, 1, separator, "fg_white")
    row = row + 1
    
    -- Table rows
    for i, ship in ipairs(game.fleet) do
        -- Name column
        term.write_at(row, 1, ship.name, "fg_bright_cyan")
        
        -- Age column
        term.write_at(row, 12, ship.age .. "y", "fg_white")
        
        -- Hull column with color coding
        local hull_color = ship.hull >= 70 and "fg_green" or (ship.hull >= 50 and "fg_yellow" or "fg_red")
        term.write_at(row, 17, ship.hull .. "%", hull_color)
        
        -- Fuel column with color coding
        local fuel_color = ship.fuel >= 70 and "fg_green" or (ship.fuel >= 30 and "fg_yellow" or "fg_red")
        term.write_at(row, 23, ship.fuel .. "%", fuel_color)
        
        -- Status column
        term.write_at(row, 29, ship.status, "fg_white")
        
        -- Cargo column
        term.write_at(row, 40, ship.cargo, "fg_bright_white")
        
        -- Origin column (shows current location for docked ships, departure port for at-sea ships)
        if ship.origin then
            term.write_at(row, 58, ship.origin, "fg_bright_white")
        else
            term.write_at(row, 58, "-", "fg_white")
        end
        
        -- Destination column (if present)
        if ship.destination then
            term.write_at(row, 80, ship.destination, "fg_white")
        else
            term.write_at(row, 80, "-", "fg_white")
        end
        
        -- ETA column (if present)
        if ship.eta then
            term.write_at(row, 104, ship.eta, "fg_yellow")
        else
            term.write_at(row, 104, "-", "fg_white")
        end
        
        -- Risk column with color coding
        local risk_color = ship.risk == "None" and "fg_green" or 
                          (ship.risk:match("LOW") or ship.risk:match("MED")) and "fg_yellow" or "fg_bright_yellow"
        term.write_at(row, 112, ship.risk, risk_color)
        
        row = row + 1
    end
    
    row = row + 1
    local stats = gamestate.get_fleet_stats(game)
    
    term.write_at(row, 1, "Total Fleet: ", "fg_white")
    term.write_colored(stats.total .. "/" .. stats.max, "fg_bright_white")
    term.write_colored(" | Avg Age: " .. stats.avg_age .. "y | Uninsured Losses: " .. stats.uninsured_losses, "fg_white")
    
    return row + 2
end

-- Market snapshot section
function sections.market_snapshot(start_row)
    widgets.section_header(start_row, "MARKET SNAPSHOT")
    local row = start_row + 1
    
    term.write_at(row, 1, "Crude Price Cap: ", "fg_white")
    term.write_colored("$" .. game.market.crude_price_cap .. "/bbl", "fg_bright_yellow")
    term.write_colored(" | Shadow Markup: ", "fg_white")
    term.write_colored("+" .. game.market.shadow_markup_percent .. "%", "fg_bright_green")
    term.write_colored(" (", "fg_white")
    term.write_colored("$" .. game.market.shadow_price .. "/bbl", "fg_bright_yellow")
    term.write_colored(" to India/China)", "fg_white")
    row = row + 1
    
    term.write_at(row, 1, "Demand: ", "fg_white")
    term.write_colored(game.market.demand, "fg_bright_green")
    term.write_colored(" (Baltic Exports: ", "fg_white")
    term.write_colored(game.market.baltic_exports .. "M bbls/day", "fg_bright_white")
    term.write_colored(") | Sanctions Alert: ", "fg_white")
    term.write_colored(game.market.sanctions_alert, "fg_red")
    row = row + 1
    
    term.write_at(row, 1, 'News Ticker: "', "fg_white")
    term.write_colored(game.market.news, "fg_yellow")
    term.write_colored('"', "fg_white")
    
    return row + 2
end

-- Active events section
function sections.active_events(start_row)
    widgets.section_header(start_row, "ACTIVE EVENTS")
    local row = start_row + 1
    
    for _, event in ipairs(game.events) do
        term.write_at(row, 1, "- ", "fg_white")
        local event_color = event.type == "Pending" and "fg_yellow" or "fg_green"
        term.write_colored(event.type, event_color)
        term.write_colored(": " .. event.description, "fg_white")
        row = row + 1
    end
    
    return row + 2
end

-- Heat meter section
function sections.heat_meter_section(start_row)
    widgets.section_header(start_row, "HEAT METER")
    widgets.heat_meter(start_row + 1, game)
    return start_row + 3
end

-- Menu structure with submenus
local menu_structure = {
    {
        name = "Fleet",
        submenus = {"View", "Buy", "Upgrade", "Scrap", "Back"}
    },
    {
        name = "Route",
        submenus = {"Plot Ghost Path", "Load Cargo", "Back"}
    },
    {
        name = "Trade",
        submenus = {"Sell", "Launder Oil", "Back"}
    },
    {
        name = "Evade",
        submenus = {"Spoof AIS", "Flag Swap", "Bribe", "Back"}
    },
    {
        name = "Events",
        submenus = {"Resolve Pending Dilemmas", "Back"}
    },
    {
        name = "Market",
        submenus = {"Check Prices", "Speculate", "Auction Dive", "Back"}
    },
    {
        name = "Status",
        submenus = {"Quick Recap", "News Refresh", "Back"}
    },
    {
        name = "Help",
        submenus = {"Command Details", "Back"}
    }
}

-- Quick actions menu
function sections.quick_actions(start_row, selected_index)
    widgets.section_header(start_row, "QUICK ACTIONS (Use ↑↓ arrows to select, Enter to confirm, 'q' to quit)")
    local row = start_row + 1
    
    local actions = {}
    for _, menu in ipairs(menu_structure) do
        table.insert(actions, menu.name)
    end
    
    for i, action in ipairs(actions) do
        widgets.menu_item_highlighted(row, i, action, i == selected_index)
        row = row + 1
    end
    
    return row + 2, actions  -- Return actions list for partial updates
end

-- Update only specific menu items without full redraw
function sections.update_menu_items(start_row, prev_index, new_index, actions)
    local row = start_row + 1  -- Skip header
    
    -- Redraw the previously selected item (now unselected)
    if prev_index and prev_index >= 1 and prev_index <= #actions then
        widgets.menu_item_highlighted(row + prev_index - 1, prev_index, actions[prev_index], false)
    end
    
    -- Redraw the newly selected item
    if new_index >= 1 and new_index <= #actions then
        widgets.menu_item_highlighted(row + new_index - 1, new_index, actions[new_index], true)
    end
end

-- Main dashboard render function with selected menu index
local function render_dashboard(selected_index)
    selected_index = selected_index or 1
    term.clear()
    term.hide_cursor()
    
    local row = 1
    row = sections.header(row)
    row = sections.status_line(row)
    row = sections.market_snapshot(row)
    row = sections.active_events(row)
    row = sections.heat_meter_section(row)
    
    local menu_start_row = row
    row, actions = sections.quick_actions(row, selected_index)
    
    widgets.separator(row, 120)
    row = row + 1
    
    term.write_at(row, 1, "> USE ARROW KEYS TO SELECT, PRESS ENTER TO CONFIRM", "fg_bright_green")
    
    return menu_start_row, actions
end

-- Render submenu screen
local function render_submenu(menu_index, selected_index)
    selected_index = selected_index or 1
    term.clear()
    term.hide_cursor()
    
    local menu = menu_structure[menu_index]
    local row = 1
    
    row = sections.header(row)
    row = sections.status_line(row)
    
    -- Show fleet status only in Fleet submenu
    if menu.name == "Fleet" then
        row = sections.fleet_status(row)
    end
    
    -- Submenu header
    local menu_start_row = row
    widgets.section_header(row, menu.name:upper() .. " MENU (Use ↑↓ arrows to select, Enter to confirm)")
    row = row + 1
    
    -- Submenu items
    for i, item in ipairs(menu.submenus) do
        widgets.menu_item_highlighted(row, i, item, i == selected_index)
        row = row + 1
    end
    
    row = row + 2
    widgets.separator(row, 120)
    row = row + 1
    
    term.write_at(row, 1, "> USE ARROW KEYS TO SELECT, PRESS ENTER TO CONFIRM", "fg_bright_green")
    
    return menu_start_row, menu.submenus
end

-- Handle a submenu action selection (extracted to avoid duplication)
-- Returns: should_exit (boolean), submenu_start_row (number or nil), submenu_actions (table or nil)
local function handle_submenu_action(menu_index, submenu_index, submenu_actions)
    local selected_action = submenu_actions[submenu_index]
    if selected_action == "Back" then
        -- Return to main menu
        return true
    else
        -- Handle submenu action
        input.restore_mode()
        term.clear()
        term.show_cursor()
        print("Action '" .. selected_action .. "' not yet implemented.")
        print("Press Enter to return to submenu...")
        io.read()
        input.set_raw_mode()
        local submenu_start_row, new_submenu_actions = render_submenu(menu_index, submenu_index)
        return false, submenu_start_row, new_submenu_actions
    end
end

-- Handle submenu navigation (extracted to avoid duplication)
local function handle_submenu_navigation(menu_index)
    local submenu_index = 1
    local num_submenu_options = #menu_structure[menu_index].submenus
    local submenu_start_row, submenu_actions = render_submenu(menu_index, submenu_index)
    
    -- Submenu loop
    while true do
        local submenu_key = input.read_key()
        local prev_submenu_index = submenu_index
        
        if submenu_key == input.keys.Q then
            -- Return to main menu
            return true  -- needs_full_redraw
        elseif submenu_key == input.keys.UP then
            submenu_index = submenu_index - 1
            if submenu_index < 1 then
                submenu_index = num_submenu_options
            end
        elseif submenu_key == input.keys.DOWN then
            submenu_index = submenu_index + 1
            if submenu_index > num_submenu_options then
                submenu_index = 1
            end
        elseif submenu_key == input.keys.ENTER then
            local should_exit, new_start_row, new_actions = handle_submenu_action(menu_index, submenu_index, submenu_actions)
            if should_exit then
                return true  -- needs_full_redraw
            else
                submenu_start_row = new_start_row
                submenu_actions = new_actions
            end
        elseif submenu_key:match('[1-9]') then
            local num = tonumber(submenu_key)
            if num <= num_submenu_options then
                submenu_index = num
                local should_exit, new_start_row, new_actions = handle_submenu_action(menu_index, submenu_index, submenu_actions)
                if should_exit then
                    return true  -- needs_full_redraw
                else
                    submenu_start_row = new_start_row
                    submenu_actions = new_actions
                end
            end
        end
        
        -- Update submenu display
        if prev_submenu_index ~= submenu_index then
            sections.update_menu_items(submenu_start_row, prev_submenu_index, submenu_index, submenu_actions)
        end
    end
end

-- Main game loop
local function main()
    local selected_index = 1
    local num_options = 8
    local menu_start_row = nil  -- Will be set after first render
    local actions = nil  -- Will store menu actions list
    
    -- Set terminal to raw mode once before the loop
    input.set_raw_mode()
    
    -- Use xpcall to ensure terminal is restored even on error
    local function game_loop()
        -- Initial full render
        menu_start_row, actions = render_dashboard(selected_index)
        
        while true do
            local key = input.read_key()
            local prev_index = selected_index
            local needs_full_redraw = false
            
            if key == input.keys.Q then
                term.clear()
                term.show_cursor()
                print("Thank you for playing Shadow Fleet!")
                break
            elseif key == input.keys.UP then
                selected_index = selected_index - 1
                if selected_index < 1 then
                    selected_index = num_options
                end
            elseif key == input.keys.DOWN then
                selected_index = selected_index + 1
                if selected_index > num_options then
                    selected_index = 1
                end
            elseif key == input.keys.ENTER then
                -- Enter submenu
                needs_full_redraw = handle_submenu_navigation(selected_index)
            elseif key:match('[1-8]') then
                -- Still support direct number input for convenience
                selected_index = tonumber(key)
                -- Enter submenu directly
                needs_full_redraw = handle_submenu_navigation(selected_index)
            end
            
            -- Update display
            if needs_full_redraw then
                -- Full redraw after submenu
                menu_start_row, actions = render_dashboard(selected_index)
            elseif prev_index ~= selected_index then
                -- Partial update for arrow key navigation
                sections.update_menu_items(menu_start_row, prev_index, selected_index, actions)
            end
        end
    end
    
    local function error_handler(err)
        -- Ensure terminal is restored on error
        input.restore_mode()
        term.cleanup()
        return debug.traceback(err, 2)
    end
    
    local success, err = xpcall(game_loop, error_handler)
    
    -- Always restore terminal mode on exit
    input.restore_mode()
    
    if not success then
        print("\nError occurred: " .. tostring(err))
    end
end

-- Run the game
main()
