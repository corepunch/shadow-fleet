#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- Main screen dashboard with widget-based UI

local term = require("terminal")
local gamestate = require("game")
local widgets = require("ui")

-- Initialize game state
local game = gamestate.new()

-- Dashboard Sections
local sections = {}

-- Header section
function sections.header(start_row)
    -- Draw header box
    local box_width = 120
    local box_height = 5
    term.draw_box(start_row, 1, box_width, box_height, "fg_bright_yellow", "bg_black")
    
    -- Title
    widgets.title(start_row + 2, "PORTS OF CALL: SHADOW FLEET - TEXT PROTOTYPE", box_width)
    
    return start_row + box_height
end

-- Status line
function sections.status_line(start_row)
    -- Draw status box
    local box_width = 120
    local box_height = 4
    widgets.info_box(start_row, 1, box_width, box_height, "STATUS", "fg_cyan")
    
    local row = start_row + 1
    local heat_desc = gamestate.get_heat_description(game)
    
    term.write_at(row, 3, "[", "fg_white")
    term.write_colored("Dark Terminal v0.1", "fg_cyan")
    term.write_colored("] - ", "fg_white")
    term.write_colored("Rogue Operator Mode", "fg_yellow")
    term.write_colored(" | Heat: ", "fg_white")
    term.write_colored(heat_desc, gamestate.get_heat_color(game))
    
    row = row + 1
    term.write_at(row, 3, game.location, "fg_bright_cyan")
    term.write_colored(" - " .. game.date .. " | Rubles: ", "fg_white")
    term.write_colored(widgets.format_number(game.rubles), "fg_bright_yellow")
    term.write_colored(" | Oil Stock: ", "fg_white")
    term.write_colored(game.oil_stock .. "k bbls", "fg_bright_white")
    
    return start_row + box_height + 1
end

-- Fleet status section
function sections.fleet_status(start_row)
    -- Calculate box height based on number of ships
    local box_height = 4 + (#game.fleet * 3) + 2
    local box_width = 120
    
    local row = widgets.info_box(start_row, 1, box_width, box_height, "FLEET STATUS", "fg_green")
    
    for i, ship in ipairs(game.fleet) do
        -- Ship header line
        term.write_at(row, 3, i .. '. TANKER "', "fg_white")
        term.write_colored(ship.name, "fg_bright_cyan")
        term.write_colored('" (Age: ' .. ship.age .. 'y, Hull: ', "fg_white")
        
        -- Hull percentage
        local hull_color = ship.hull >= 70 and "fg_green" or (ship.hull >= 50 and "fg_yellow" or "fg_red")
        term.write_colored(ship.hull .. "%", hull_color)
        term.write_colored(", Fuel: ", "fg_white")
        
        -- Fuel percentage
        local fuel_color = ship.fuel >= 70 and "fg_green" or (ship.fuel >= 30 and "fg_yellow" or "fg_red")
        term.write_colored(ship.fuel .. "%", fuel_color)
        term.write_colored(") - " .. ship.status, "fg_white")
        
        if ship.location then
            term.write_colored(": ", "fg_white")
            term.write_colored(ship.location, "fg_bright_white")
        end
        row = row + 1
        
        -- Cargo line
        term.write_at(row, 5, "Cargo: ", "fg_white")
        term.write_colored(ship.cargo, "fg_bright_white")
        term.write_colored(" | Route: " .. ship.route, "fg_white")
        if ship.eta then
            term.write_colored(" | ETA: ", "fg_white")
            term.write_colored(ship.eta, "fg_yellow")
        end
        row = row + 1
        
        -- Risk line
        term.write_at(row, 5, "Risk: ", "fg_white")
        local risk_color = ship.risk == "None" and "fg_green" or 
                          (ship.risk:match("LOW") and "fg_yellow" or "fg_bright_yellow")
        term.write_colored(ship.risk, risk_color)
        row = row + 1
    end
    
    row = row + 1
    local stats = gamestate.get_fleet_stats(game)
    
    term.write_at(row, 3, "Total Fleet: ", "fg_white")
    term.write_colored(stats.total .. "/" .. stats.max, "fg_bright_white")
    term.write_colored(" | Avg Age: " .. stats.avg_age .. "y | Uninsured Losses: " .. stats.uninsured_losses, "fg_white")
    
    return start_row + box_height + 1
end

-- Market snapshot section
function sections.market_snapshot(start_row)
    local box_height = 6
    local box_width = 120
    local row = widgets.info_box(start_row, 1, box_width, box_height, "MARKET SNAPSHOT", "fg_yellow")
    
    term.write_at(row, 3, "Crude Price Cap: ", "fg_white")
    term.write_colored("$" .. game.market.crude_price_cap .. "/bbl", "fg_bright_yellow")
    term.write_colored(" | Shadow Markup: ", "fg_white")
    term.write_colored("+" .. game.market.shadow_markup_percent .. "%", "fg_bright_green")
    term.write_colored(" (", "fg_white")
    term.write_colored("$" .. game.market.shadow_price .. "/bbl", "fg_bright_yellow")
    term.write_colored(" to India/China)", "fg_white")
    row = row + 1
    
    term.write_at(row, 3, "Demand: ", "fg_white")
    term.write_colored(game.market.demand, "fg_bright_green")
    term.write_colored(" (Baltic Exports: ", "fg_white")
    term.write_colored(game.market.baltic_exports .. "M bbls/day", "fg_bright_white")
    term.write_colored(") | Sanctions Alert: ", "fg_white")
    term.write_colored(game.market.sanctions_alert, "fg_red")
    row = row + 1
    
    term.write_at(row, 3, 'News Ticker: "', "fg_white")
    term.write_colored(game.market.news, "fg_yellow")
    term.write_colored('"', "fg_white")
    
    return start_row + box_height + 1
end

-- Active events section
function sections.active_events(start_row)
    -- Ensure minimum height for box even if no events
    local num_events = math.max(#game.events, 1)
    local box_height = 3 + num_events
    local box_width = 120
    local row = widgets.info_box(start_row, 1, box_width, box_height, "ACTIVE EVENTS", "fg_magenta")
    
    if #game.events == 0 then
        term.write_at(row, 3, "(No active events)", "fg_white")
    else
        for _, event in ipairs(game.events) do
            term.write_at(row, 3, "• ", "fg_white")
            local event_color = event.type == "Pending" and "fg_yellow" or "fg_green"
            term.write_colored(event.type, event_color)
            term.write_colored(": " .. event.description, "fg_white")
            row = row + 1
        end
    end
    
    return start_row + box_height + 1
end

-- Heat meter section
function sections.heat_meter_section(start_row)
    local box_height = 5
    local box_width = 80
    local row = widgets.info_box(start_row, 1, box_width, box_height, "HEAT METER", "fg_red")
    
    widgets.heat_meter(row, game)
    
    return start_row + box_height + 1
end

-- Quick actions menu
function sections.quick_actions(start_row)
    local box_height = 11
    local box_width = 120
    local row = widgets.info_box(start_row, 1, box_width, box_height, "QUICK ACTIONS (Enter 1-8 or 'q' to quit)", "fg_bright_cyan")
    
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
        widgets.menu_item(row, i, action)
        row = row + 1
    end
    
    return start_row + box_height + 1
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
