#!/usr/bin/env lua

-- Shadow Fleet - Text-based Strategy Game
-- Main screen dashboard

local term = require("terminal")

-- Game state
local game = {
    -- Player resources
    location = "Moscow Safehouse",
    date = "Jan 08, 2026",
    rubles = 5000000,
    oil_stock = 0,
    
    -- Heat level (0-10, represents scrutiny from authorities)
    heat = 0,
    heat_max = 10,
    
    -- Fleet data
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
    
    -- Market data
    market = {
        crude_price_cap = 60,
        shadow_markup_percent = 25,
        shadow_price = 75,
        demand = "HIGH",
        baltic_exports = 4.1,
        sanctions_alert = "EU Patrols Up 15%",
        news = "NATO eyes 92 new blacklisted hulls. Stay dark, comrades."
    },
    
    -- Active events
    events = {
        {
            type = "Pending",
            description = "Crew Mutiny Risk on GHOST-01 (Resolve? Y/N)"
        },
        {
            type = "Opportunity",
            description = "Shady Auction - Buy \"RUST-07\" (Age 28y, 1M bbls cap) for 2M Rubles?"
        }
    }
}

-- Calculate fleet statistics
local function get_fleet_stats()
    local total_ships = #game.fleet
    local total_age = 0
    for _, ship in ipairs(game.fleet) do
        total_age = total_age + ship.age
    end
    local avg_age = total_ships > 0 and math.floor(total_age / total_ships) or 0
    
    return {
        total = total_ships,
        max = 50,
        avg_age = avg_age,
        uninsured_losses = 0
    }
end

-- Get heat level description
local function get_heat_description()
    if game.heat == 0 then
        return "LOW (0/10)"
    elseif game.heat <= 3 then
        return "MEDIUM (" .. game.heat .. "/10)"
    elseif game.heat <= 7 then
        return "HIGH (" .. game.heat .. "/10)"
    else
        return "CRITICAL (" .. game.heat .. "/10)"
    end
end

-- Get heat meter color
local function get_heat_color()
    if game.heat == 0 then
        return term.colors.fg_green
    elseif game.heat <= 3 then
        return term.colors.fg_yellow
    elseif game.heat <= 7 then
        return term.colors.fg_orange
    else
        return term.colors.fg_red
    end
end

-- Draw heat meter bar
local function draw_heat_meter()
    term.write("[")
    for i = 1, game.heat_max do
        if i <= game.heat then
            term.fg(term.colors.fg_red)
            term.write("|")
            term.reset()
        else
            term.write("|")
        end
    end
    term.write("] ")
    term.fg(get_heat_color())
    term.write(game.heat .. "/" .. game.heat_max)
    term.reset()
    term.write(" - ")
    if game.heat == 0 then
        term.write("No eyes on you yet. One slip, and drones swarm.")
    elseif game.heat <= 3 then
        term.write("Low profile. Keep it that way.")
    elseif game.heat <= 7 then
        term.write("Authorities are watching. Lay low.")
    else
        term.write("DANGER! Active pursuit in progress!")
    end
end

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

-- Render the main dashboard
local function render_dashboard()
    term.clear()
    term.hide_cursor()
    
    local row = 1
    
    -- Header
    term.move_to(row, 1)
    term.write("============================================================")
    row = row + 1
    
    term.move_to(row, 1)
    term.write("          ")
    term.bold()
    term.fg(term.colors.fg_bright_red)
    term.write("PORTS OF CALL: SHADOW FLEET - TEXT PROTOTYPE")
    term.reset()
    row = row + 1
    
    term.move_to(row, 1)
    term.write("============================================================")
    row = row + 1
    
    -- Status line
    term.move_to(row, 1)
    term.write("[")
    term.fg(term.colors.fg_cyan)
    term.write("Dark Terminal v0.1")
    term.reset()
    term.write("] - ")
    term.fg(term.colors.fg_yellow)
    term.write("Rogue Operator Mode")
    term.reset()
    term.write(" | Heat: ")
    term.fg(get_heat_color())
    term.write(get_heat_description())
    term.reset()
    row = row + 1
    
    -- Location and resources
    term.move_to(row, 1)
    term.fg(term.colors.fg_bright_cyan)
    term.write(game.location)
    term.reset()
    term.write(" - " .. game.date .. " | Rubles: ")
    term.fg(term.colors.fg_bright_yellow)
    term.write(format_number(game.rubles))
    term.reset()
    term.write(" | Oil Stock: ")
    term.fg(term.colors.fg_bright_white)
    term.write(game.oil_stock .. "k bbls")
    term.reset()
    row = row + 2
    
    -- Fleet Status Section
    term.move_to(row, 1)
    term.bold()
    term.fg(term.colors.fg_bright_white)
    term.write("--- FLEET STATUS ---")
    term.reset()
    row = row + 1
    
    for i, ship in ipairs(game.fleet) do
        term.move_to(row, 1)
        term.write(i .. ". TANKER \"")
        term.fg(term.colors.fg_bright_cyan)
        term.write(ship.name)
        term.reset()
        term.write("\" (Age: " .. ship.age .. "y, Hull: ")
        
        -- Color code hull condition
        if ship.hull >= 70 then
            term.fg(term.colors.fg_green)
        elseif ship.hull >= 50 then
            term.fg(term.colors.fg_yellow)
        else
            term.fg(term.colors.fg_red)
        end
        term.write(ship.hull .. "%")
        term.reset()
        
        term.write(", Fuel: ")
        if ship.fuel >= 70 then
            term.fg(term.colors.fg_green)
        elseif ship.fuel >= 30 then
            term.fg(term.colors.fg_yellow)
        else
            term.fg(term.colors.fg_red)
        end
        term.write(ship.fuel .. "%")
        term.reset()
        
        term.write(") - " .. ship.status .. ": ")
        if ship.location then
            term.fg(term.colors.fg_bright_white)
            term.write(ship.location)
            term.reset()
        end
        row = row + 1
        
        term.move_to(row, 1)
        term.write("   Cargo: ")
        term.fg(term.colors.fg_bright_white)
        term.write(ship.cargo)
        term.reset()
        term.write(" | Route: ")
        term.write(ship.route)
        if ship.eta then
            term.write(" | ETA: ")
            term.fg(term.colors.fg_yellow)
            term.write(ship.eta)
            term.reset()
        end
        row = row + 1
        
        term.move_to(row, 1)
        term.write("   Risk: ")
        if ship.risk == "None" then
            term.fg(term.colors.fg_green)
        elseif ship.risk:match("LOW") then
            term.fg(term.colors.fg_yellow)
        else
            term.fg(term.colors.fg_orange)
        end
        term.write(ship.risk)
        term.reset()
        row = row + 1
    end
    
    row = row + 1
    local stats = get_fleet_stats()
    term.move_to(row, 1)
    term.write("Total Fleet: ")
    term.fg(term.colors.fg_bright_white)
    term.write(stats.total .. "/" .. stats.max)
    term.reset()
    term.write(" | Avg Age: " .. stats.avg_age .. "y | Uninsured Losses: " .. stats.uninsured_losses)
    row = row + 2
    
    -- Market Snapshot Section
    term.move_to(row, 1)
    term.bold()
    term.fg(term.colors.fg_bright_white)
    term.write("--- MARKET SNAPSHOT ---")
    term.reset()
    row = row + 1
    
    term.move_to(row, 1)
    term.write("Crude Price Cap: ")
    term.fg(term.colors.fg_bright_yellow)
    term.write("$" .. game.market.crude_price_cap .. "/bbl")
    term.reset()
    term.write(" | Shadow Markup: ")
    term.fg(term.colors.fg_bright_green)
    term.write("+" .. game.market.shadow_markup_percent .. "%")
    term.reset()
    term.write(" (")
    term.fg(term.colors.fg_bright_yellow)
    term.write("$" .. game.market.shadow_price .. "/bbl")
    term.reset()
    term.write(" to India/China)")
    row = row + 1
    
    term.move_to(row, 1)
    term.write("Demand: ")
    term.fg(term.colors.fg_bright_green)
    term.write(game.market.demand)
    term.reset()
    term.write(" (Baltic Exports: ")
    term.fg(term.colors.fg_bright_white)
    term.write(game.market.baltic_exports .. "M bbls/day")
    term.reset()
    term.write(") | Sanctions Alert: ")
    term.fg(term.colors.fg_red)
    term.write(game.market.sanctions_alert)
    term.reset()
    row = row + 1
    
    term.move_to(row, 1)
    term.write("News Ticker: \"")
    term.fg(term.colors.fg_yellow)
    term.write(game.market.news)
    term.reset()
    term.write("\"")
    row = row + 2
    
    -- Active Events Section
    term.move_to(row, 1)
    term.bold()
    term.fg(term.colors.fg_bright_white)
    term.write("--- ACTIVE EVENTS ---")
    term.reset()
    row = row + 1
    
    for _, event in ipairs(game.events) do
        term.move_to(row, 1)
        term.write("- ")
        if event.type == "Pending" then
            term.fg(term.colors.fg_yellow)
        else
            term.fg(term.colors.fg_green)
        end
        term.write(event.type)
        term.reset()
        term.write(": " .. event.description)
        row = row + 1
    end
    row = row + 1
    
    -- Heat Meter Section
    term.move_to(row, 1)
    term.bold()
    term.fg(term.colors.fg_bright_white)
    term.write("--- HEAT METER ---")
    term.reset()
    row = row + 1
    
    term.move_to(row, 1)
    draw_heat_meter()
    row = row + 2
    
    -- Quick Actions Menu
    term.move_to(row, 1)
    term.bold()
    term.fg(term.colors.fg_bright_white)
    term.write("--- QUICK ACTIONS (Enter 1-8 or 'q' to quit) ---")
    term.reset()
    row = row + 1
    
    local actions = {
        "1. Fleet (View/Buy/Upgrade/Scrap)",
        "2. Route (Plot Ghost Path/Load Cargo)",
        "3. Trade (Sell/Launder Oil)",
        "4. Evade (Spoof AIS/Flag Swap/Bribe)",
        "5. Events (Resolve Pending Dilemmas)",
        "6. Market (Check Prices/Speculate/Auction Dive)",
        "7. Status (Quick Recap/News Refresh)",
        "8. Help (Command Details)"
    }
    
    for _, action in ipairs(actions) do
        term.move_to(row, 1)
        local num = action:match("^(%d+)")
        term.fg(term.colors.fg_bright_cyan)
        term.write(num)
        term.reset()
        term.write(action:sub(2))
        row = row + 1
    end
    row = row + 1
    
    -- Bottom separator
    term.move_to(row, 1)
    term.write("============================================================")
    row = row + 1
    
    -- Prompt
    term.move_to(row, 1)
    term.fg(term.colors.fg_bright_green)
    term.write("> YOUR MOVE (1-8): ")
    term.reset()
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
            -- Placeholder for menu handling
            term.clear()
            print("Menu option " .. input .. " not yet implemented.")
            print("Press Enter to return to dashboard...")
            io.read()
        else
            -- Invalid input, just redraw
        end
    end
end

-- Run the game
main()
