#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- Main screen dashboard with widget-based UI

local term = require("terminal")

-- Game state
local game = {
    location = "Moscow Safehouse",
    date = "Jan 08, 2026",
    rubles = 5000000,
    oil_stock = 0,
    heat = 0,
    heat_max = 10,
    
    fleet = {
        {
            name = "GHOST-01",
            age = 22,
            hull = 65,
            fuel = 80,
            status = "Docked",
            location = "Ust-Luga (RU)",
            cargo = "Empty",
            route = "Idle",
            risk = "None"
        },
        {
            name = "SHADOW-03",
            age = 18,
            hull = 72,
            fuel = 45,
            status = "At Sea",
            location = nil,
            cargo = "500k bbls Crude",
            route = "Ust-Luga -> STS off Malta",
            eta = "2 days",
            risk = "MED (AIS Spoof Active)"
        }
    },
    
    market = {
        crude_price_cap = 60,
        shadow_markup_percent = 25,
        shadow_price = 75,
        demand = "HIGH",
        baltic_exports = 4.1,
        sanctions_alert = "EU Patrols Up 15%",
        news = "NATO eyes 92 new blacklisted hulls. Stay dark, comrades."
    },
    
    events = {
        {
            type = "Pending",
            description = "Crew Mutiny Risk on GHOST-01 (Resolve? Y/N)"
        },
        {
            type = "Opportunity",
            description = 'Shady Auction - Buy "RUST-07" (Age 28y, 1M bbls cap) for 2M Rubles?'
        }
    }
}

-- UI Widgets Module
local widgets = {}

-- Format number with thousands separator
local function format_number(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

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
    term.write_at(row, 1, "--- " .. text .. " ---", "fg_bright_white")
    term.set_style("bold")
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
function widgets.heat_meter(row, heat, max_heat)
    local bar_length = max_heat
    term.write_at(row, 1, "[", "fg_white")
    
    for i = 1, max_heat do
        if i <= heat then
            term.write_colored("|", "fg_red")
        else
            term.write_colored("|", "fg_white")
        end
    end
    
    local heat_color
    if heat == 0 then
        heat_color = "fg_green"
    elseif heat <= 3 then
        heat_color = "fg_yellow"
    elseif heat <= 7 then
        heat_color = "fg_bright_yellow"
    else
        heat_color = "fg_red"
    end
    
    term.write_colored("] " .. heat .. "/" .. max_heat, heat_color)
    term.write_at(row, 20, " - ", "fg_white")
    
    if heat == 0 then
        term.write_at(row, 23, "No eyes on you yet. One slip, and drones swarm.", "fg_white")
    elseif heat <= 3 then
        term.write_at(row, 23, "Low profile. Keep it that way.", "fg_white")
    elseif heat <= 7 then
        term.write_at(row, 23, "Authorities are watching. Lay low.", "fg_white")
    else
        term.write_at(row, 23, "DANGER! Active pursuit in progress!", "fg_bright_red")
    end
end

-- Widget: Menu item
function widgets.menu_item(row, number, text)
    term.write_at(row, 1, tostring(number), "fg_bright_cyan")
    term.write_at(row, 2, ". " .. text, "fg_white")
end

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
    local heat_desc = game.heat == 0 and "LOW (0/10)" or "MEDIUM (" .. game.heat .. "/10)"
    term.write_at(start_row, 1, "[", "fg_white")
    term.write_colored("Dark Terminal v0.1", "fg_cyan")
    term.write_colored("] - ", "fg_white")
    term.write_colored("Rogue Operator Mode", "fg_yellow")
    term.write_colored(" | Heat: ", "fg_white")
    term.write_colored(heat_desc, game.heat == 0 and "fg_green" or "fg_yellow")
    
    start_row = start_row + 1
    term.write_colored(game.location, "fg_bright_cyan")
    term.write_colored(" - " .. game.date .. " | Rubles: ", "fg_white")
    term.write_colored(format_number(game.rubles), "fg_bright_yellow")
    term.write_colored(" | Oil Stock: ", "fg_white")
    term.write_colored(game.oil_stock .. "k bbls", "fg_bright_white")
    
    return start_row + 2
end

-- Fleet status section
function sections.fleet_status(start_row)
    widgets.section_header(start_row, "FLEET STATUS")
    local row = start_row + 1
    
    for i, ship in ipairs(game.fleet) do
        -- Ship header line
        term.write_at(row, 1, i .. '. TANKER "', "fg_white")
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
        term.write_at(row, 3, "Cargo: ", "fg_white")
        term.write_colored(ship.cargo, "fg_bright_white")
        term.write_colored(" | Route: " .. ship.route, "fg_white")
        if ship.eta then
            term.write_colored(" | ETA: ", "fg_white")
            term.write_colored(ship.eta, "fg_yellow")
        end
        row = row + 1
        
        -- Risk line
        term.write_at(row, 3, "Risk: ", "fg_white")
        local risk_color = ship.risk == "None" and "fg_green" or 
                          (ship.risk:match("LOW") and "fg_yellow" or "fg_bright_yellow")
        term.write_colored(ship.risk, risk_color)
        row = row + 1
    end
    
    row = row + 1
    local total_age = 0
    for _, ship in ipairs(game.fleet) do
        total_age = total_age + ship.age
    end
    local avg_age = #game.fleet > 0 and math.floor(total_age / #game.fleet) or 0
    
    term.write_at(row, 1, "Total Fleet: ", "fg_white")
    term.write_colored(#game.fleet .. "/50", "fg_bright_white")
    term.write_colored(" | Avg Age: " .. avg_age .. "y | Uninsured Losses: 0", "fg_white")
    
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
    widgets.heat_meter(start_row + 1, game.heat, game.heat_max)
    return start_row + 3
end

-- Quick actions menu
function sections.quick_actions(start_row)
    widgets.section_header(start_row, "QUICK ACTIONS (Enter 1-8 or 'q' to quit)")
    local row = start_row + 1
    
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
    
    return row + 2
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
    
    widgets.separator(row, 120)
    row = row + 1
    
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
