#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- Main screen dashboard with widget-based UI

local term = require("terminal")
local gamestate = require("game")
local widgets = require("ui")

-- Initialize game state
local game = gamestate.new()

-- Dashboard configuration
local DASHBOARD_WIDTH = 120
local NARROW_WIDTH = 80

-- Dashboard Sections
local sections = {}

-- Header section
function sections.header(start_row)
    local win = widgets.window(start_row, 1, DASHBOARD_WIDTH, 5, nil, "fg_bright_yellow")
    
    -- Title centered in window
    widgets.title(start_row + 2, "PORTS OF CALL: SHADOW FLEET - TEXT PROTOTYPE", DASHBOARD_WIDTH)
    
    return win:next_row()
end

-- Status line
function sections.status_line(start_row)
    local win = widgets.window(start_row, 1, DASHBOARD_WIDTH, 4, "STATUS", "fg_cyan")
    
    local heat_desc = gamestate.get_heat_description(game)
    
    win:write_at(1, 1, "[", "fg_white")
    win:write_colored("Dark Terminal v0.1", "fg_cyan")
    win:write_colored("] - ", "fg_white")
    win:write_colored("Rogue Operator Mode", "fg_yellow")
    win:write_colored(" | Heat: ", "fg_white")
    win:write_colored(heat_desc, gamestate.get_heat_color(game))
    
    win:write_at(2, 1, game.location, "fg_bright_cyan")
    win:write_colored(" - " .. game.date .. " | Rubles: ", "fg_white")
    win:write_colored(widgets.format_number(game.rubles), "fg_bright_yellow")
    win:write_colored(" | Oil Stock: ", "fg_white")
    win:write_colored(game.oil_stock .. "k bbls", "fg_bright_white")
    
    return win:next_row()
end

-- Fleet status section
function sections.fleet_status(start_row)
    -- Calculate box height based on number of ships
    local box_height = 4 + (#game.fleet * 3) + 2
    
    local win = widgets.window(start_row, 1, DASHBOARD_WIDTH, box_height, "FLEET STATUS", "fg_green")
    local rel_row = 1
    
    for i, ship in ipairs(game.fleet) do
        -- Ship header line
        win:write_at(rel_row, 1, i .. '. TANKER "', "fg_white")
        win:write_colored(ship.name, "fg_bright_cyan")
        win:write_colored('" (Age: ' .. ship.age .. 'y, Hull: ', "fg_white")
        
        -- Hull percentage
        local hull_color = ship.hull >= 70 and "fg_green" or (ship.hull >= 50 and "fg_yellow" or "fg_red")
        win:write_colored(ship.hull .. "%", hull_color)
        win:write_colored(", Fuel: ", "fg_white")
        
        -- Fuel percentage
        local fuel_color = ship.fuel >= 70 and "fg_green" or (ship.fuel >= 30 and "fg_yellow" or "fg_red")
        win:write_colored(ship.fuel .. "%", fuel_color)
        win:write_colored(") - " .. ship.status, "fg_white")
        
        if ship.location then
            win:write_colored(": ", "fg_white")
            win:write_colored(ship.location, "fg_bright_white")
        end
        rel_row = rel_row + 1
        
        -- Cargo line
        win:write_at(rel_row, 3, "Cargo: ", "fg_white")
        win:write_colored(ship.cargo, "fg_bright_white")
        win:write_colored(" | Route: " .. ship.route, "fg_white")
        if ship.eta then
            win:write_colored(" | ETA: ", "fg_white")
            win:write_colored(ship.eta, "fg_yellow")
        end
        rel_row = rel_row + 1
        
        -- Risk line
        win:write_at(rel_row, 3, "Risk: ", "fg_white")
        local risk_color = ship.risk == "None" and "fg_green" or 
                          (ship.risk:match("LOW") and "fg_yellow" or "fg_bright_yellow")
        win:write_colored(ship.risk, risk_color)
        rel_row = rel_row + 1
    end
    
    rel_row = rel_row + 1
    local stats = gamestate.get_fleet_stats(game)
    
    win:write_at(rel_row, 1, "Total Fleet: ", "fg_white")
    win:write_colored(stats.total .. "/" .. stats.max, "fg_bright_white")
    win:write_colored(" | Avg Age: " .. stats.avg_age .. "y | Uninsured Losses: " .. stats.uninsured_losses, "fg_white")
    
    return win:next_row()
end

-- Market snapshot section
function sections.market_snapshot(start_row)
    local win = widgets.window(start_row, 1, DASHBOARD_WIDTH, 6, "MARKET SNAPSHOT", "fg_yellow")
    
    win:write_at(1, 1, "Crude Price Cap: ", "fg_white")
    win:write_colored("$" .. game.market.crude_price_cap .. "/bbl", "fg_bright_yellow")
    win:write_colored(" | Shadow Markup: ", "fg_white")
    win:write_colored("+" .. game.market.shadow_markup_percent .. "%", "fg_bright_green")
    win:write_colored(" (", "fg_white")
    win:write_colored("$" .. game.market.shadow_price .. "/bbl", "fg_bright_yellow")
    win:write_colored(" to India/China)", "fg_white")
    
    win:write_at(2, 1, "Demand: ", "fg_white")
    win:write_colored(game.market.demand, "fg_bright_green")
    win:write_colored(" (Baltic Exports: ", "fg_white")
    win:write_colored(game.market.baltic_exports .. "M bbls/day", "fg_bright_white")
    win:write_colored(") | Sanctions Alert: ", "fg_white")
    win:write_colored(game.market.sanctions_alert, "fg_red")
    
    win:write_at(3, 1, 'News Ticker: "', "fg_white")
    win:write_colored(game.market.news, "fg_yellow")
    win:write_colored('"', "fg_white")
    
    return win:next_row()
end

-- Active events section
function sections.active_events(start_row)
    -- Ensure minimum height for box even if no events
    local num_events = math.max(#game.events, 1)
    local box_height = 3 + num_events
    
    local win = widgets.window(start_row, 1, DASHBOARD_WIDTH, box_height, "ACTIVE EVENTS", "fg_magenta")
    
    if #game.events == 0 then
        win:write_at(1, 1, "(No active events)", "fg_white")
    else
        local rel_row = 1
        for _, event in ipairs(game.events) do
            win:write_at(rel_row, 1, "• ", "fg_white")
            local event_color = event.type == "Pending" and "fg_yellow" or "fg_green"
            win:write_colored(event.type, event_color)
            win:write_colored(": " .. event.description, "fg_white")
            rel_row = rel_row + 1
        end
    end
    
    return win:next_row()
end

-- Heat meter section
function sections.heat_meter_section(start_row)
    local win = widgets.window(start_row, 1, NARROW_WIDTH, 5, "HEAT METER", "fg_red")
    
    -- Use the heat meter widget but adjust for window coordinates
    local heat = game.heat
    local max_heat = game.heat_max
    
    win:write_at(1, 1, "[", "fg_white")
    
    for i = 1, max_heat do
        if i <= heat then
            win:write_colored("|", "fg_red")
        else
            win:write_colored("|", "fg_white")
        end
    end
    
    win:write_colored("] " .. heat .. "/" .. max_heat, gamestate.get_heat_color(game))
    win:write_at(1, 23, " - ", "fg_white")
    win:write_at(1, 26, gamestate.get_heat_message(game), heat > 7 and "fg_bright_red" or "fg_white")
    
    return win:next_row()
end

-- Quick actions menu
function sections.quick_actions(start_row)
    local win = widgets.window(start_row, 1, DASHBOARD_WIDTH, 11, "QUICK ACTIONS (Enter 1-8 or 'q' to quit)", "fg_bright_cyan")
    
    local actions = {
        "Fleet (View/Buy/Upgrade/Scrap)",
        "Route (Plot Ghost Path/Load Cargo)",
        "Trade (Sell/Launder Oil)",
        "Evade (Spoof AIS/Flag Swap/Bribe)",
        "Events (Resolve Pending Dilemmas)",
        "Market (Check Prices/Speculate/Auction Dive)",
        "Status (Quick Recap/News Refresh)",
        "Help (Command Details)"
    }
    
    for i, action in ipairs(actions) do
        widgets.menu_item(win.content_row + i - 1, win.content_col, i, action)
    end
    
    return win:next_row()
end

-- Main dashboard render function
local function render_dashboard()
    term.clear()
    term.hide_cursor()
    
    local row = 1
    row = sections.header(row)
    row = sections.status_line(row)
    row = sections.fleet_status(row)
    row = sections.market_snapshot(row)
    row = sections.active_events(row)
    row = sections.heat_meter_section(row)
    row = sections.quick_actions(row)
    
    -- Input prompt
    term.write_at(row, 1, "> YOUR MOVE (1-8): ", "fg_bright_green")
    term.show_cursor()
end

-- Main game loop
local function main()
    while true do
        render_dashboard()
        local input = io.read()
        
        if input == "q" or input == "Q" then
            term.clear()
            term.show_cursor()
            print("Thank you for playing Shadow Fleet!")
            break
        elseif tonumber(input) and tonumber(input) >= 1 and tonumber(input) <= 8 then
            term.clear()
            print("Menu option " .. input .. " not yet implemented.")
            print("Press Enter to return to dashboard...")
            io.read()
        end
    end
end

-- Run the game
main()
